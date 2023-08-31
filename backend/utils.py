import requests
import pandas as pd
import math
import logging
import dotenv
import os

# Setup logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Load environment variables
dotenv.load_dotenv()
TRADIER_API_KEY = os.getenv('TRADIER_API_KEY')
if not TRADIER_API_KEY:
    logging.error("TRADIER_API_KEY not found in environment variables.")
    exit(1)


# Get stock details
def request_handler(url, params={}, headers={}):
    try:
        response = requests.get(url, params=params, headers=headers)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        logging.error(f"Error fetching data from {url}: {e}")
        return None


# Select the option with the highest delta
def put_delta_select(data, current_price, target_delta, max_price):
    highest_delta = 0
    selected_option = None
    for option in data['options']['option']:
        if ("Put" in option['description'] and -1*option['greeks']['delta'] < target_delta and 
            -1*option['greeks']['delta'] >= highest_delta and option['strike'] <= max_price and 
            option['strike'] <= current_price):
            highest_delta = -1 * option['greeks']['delta']
            selected_option = option
    return selected_option


# Get stock details
def fetch_stock_details(valid_exp_date, stock_ticker, target_delta, max_price):
    headers = {
        'Authorization': f'Bearer {TRADIER_API_KEY}',
        'Accept': 'application/json'
    }

    # Get the current price
    response = request_handler('https://api.tradier.com/v1/markets/quotes',
        params={'symbols': stock_ticker, 'greeks': 'false'},
        headers=headers)

    if not response or 'quotes' not in response or 'quote' not in response['quotes']:
        logging.error(f"Unexpected JSON structure in response for current price: {response}")
        return None

    current_price = response['quotes']['quote']['last']

    # Get the expiration date
    response = request_handler('https://api.tradier.com/v1/markets/options/expirations',
        params={'symbol': stock_ticker, 'includeAllRoots': 'true', 'strikes': 'true'},
        headers=headers)

    if not response or 'expirations' not in response or 'expiration' not in response['expirations']:
        logging.error(f"Unexpected JSON structure in response for expiration dates: {response}")
        return None

    expiration_dates = response['expirations']['expiration']
    expiration_date = pd.to_datetime(expiration_dates[0]['date']).date()

    if not (valid_exp_date[0] <= expiration_date <= valid_exp_date[1]):
        logging.info(f"Expiration Date: {expiration_date}")
        logging.info(f"Range: {valid_exp_date[0]} - {valid_exp_date[1]}")
        logging.error("Invalid Expiration Date")
        return None

    # Calculate the strike price based on the delta
    response = request_handler('https://api.tradier.com/v1/markets/options/chains',
        params={'symbol': stock_ticker, 'expiration': expiration_date, 'greeks': 'true'},
        headers=headers)

    if not response or 'options' not in response or 'option' not in response['options']:
        logging.error(f"Unexpected JSON structure in response for option chains: {response}")
        return None

    selected_option = put_delta_select(response, current_price, target_delta, max_price)
    if not selected_option:
        logging.error("No Options Available for Selected Delta")
        return None

    bid_price = selected_option['bid']
    strike_price = selected_option['strike']

    return current_price, strike_price, bid_price, expiration_date
    

# Check if the bid price is within the threshold
def check_bid_price(current_date, bid_price, strike_price, strategy):
    bid_ratio = (bid_price * 100) / strike_price
    
    bid_ratio_conditions = {
        "aggressive": [0.5, 0.5, 0.4, 0.4, 0.35],
        "balanced": [0.4, 0.4, 0.3, 0.3, 0.25],
        "conservative": [0.3, 0.3, 0.25, 0.25, 0.15]
    }

    ratio_thresholds = {
        "Monday": 0,
        "Tuesday": 1,
        "Wednesday": 2,
        "Thursday": 3,
        "Friday": 4
    }

    if current_date not in ratio_thresholds:
        logging.error(f"Invalid date: {current_date}. Expected one of {', '.join(ratio_thresholds.keys())}.")
        return 2

    current_day_index = ratio_thresholds[current_date]
    if bid_ratio >= bid_ratio_conditions.get(strategy, [])[current_day_index]:
        return 0
    else:
        return 1
    

# Multiplier for capital based on strategy
def determine_option_quantity(strike_price, capital, strategy):
    strategy_multiplier = {
        "aggressive": 1,
        "balanced": 0.8,
        "conservative": 0.6
    }

    multiplier = strategy_multiplier.get(strategy)
    if not multiplier:
        logging.error(f"Invalid strategy: {strategy}. Expected one of {', '.join(strategy_multiplier.keys())}.")
        return 0

    adjusted_capital = capital * multiplier
    normalized_quantity = adjusted_capital / (strike_price * 100)
    return math.floor(normalized_quantity)


# Get current date details
def get_current_date():
    try:
        current_day = pd.Timestamp.today()
        current_date = current_day.day_name()
        valid_exp_date = (current_day.date() + pd.Timedelta(days=1), current_day.date() + pd.Timedelta(days=7))

        return current_date, valid_exp_date
    except Exception as e:
        logging.error(f"Error fetching date details: {e}")
        return None, None


# Write details to log
def log_stock_details(symbol, stock_price, strike_price, bid_price, expiration_date_pd, percent_change):
    logging.info(f"""
    CURRENT DETAILS: {symbol}
    ----------------------------
    Current Price: {stock_price}
    Strike Price: {strike_price}
    Bid Price: {bid_price}
    Expiration Date: {expiration_date_pd}
    Percent Change: {percent_change}
    """)

# Write details to log
def log_selling_details(symbol, expiration_date_pd, price, strike_price, bid_price, options_amount):
    logging.info(f"""
    SELLING DETAILS: {symbol}
    ----------------------------
    Expiration Date: {expiration_date_pd}
    Share Price: {price}
    Strike Price: {strike_price}
    Bid Price: {bid_price}
    Amount: {options_amount}
    """)

# Write details to log
def log_error(error):
    logging.error(f"ERROR: {error}")