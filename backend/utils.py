import requests
import pandas as pd
import math
import utils
import dotenv
import os

dotenv.load_dotenv()
TRADIER_API_KEY = os.getenv('TRADIER_API_KEY')

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


def get_stock_details(valid_exp_date, stock_ticker, target_delta, max_price):
    # Get the current price
    response = requests.get('https://api.tradier.com/v1/markets/quotes',
        params={'symbols': f'{stock_ticker}', 'greeks': 'false'},
        headers={'Authorization': f'Bearer {TRADIER_API_KEY}', 'Accept': 'application/json'}
    )
    json_response = response.json()
    current_price = json_response['quotes']['quote']['last']

    # Get the expiration date
    response = requests.get('https://api.tradier.com/v1/markets/options/expirations',
        params={'symbol': f'{stock_ticker}', 'includeAllRoots': 'true', 'strikes': 'true'},
        headers={'Authorization': f'Bearer {TRADIER_API_KEY}', 'Accept': 'application/json'}
    )
    json_response = response.json()
    expiration_dates = json_response['expirations']['expiration']
    expiration_date = pd.to_datetime(expiration_dates[0]['date']).date()
    print(expiration_date)

    # Check if the expiration date is valid
    if expiration_date > valid_exp_date:
        utils.write_error("Invalid Expiration Date")
        exit()

    # Calculate the strike price based on the delta
    response = requests.get('https://api.tradier.com/v1/markets/options/chains',
        params={'symbol': f'{stock_ticker}', 'expiration': f'{expiration_date}', 'greeks': 'true'},
        headers={'Authorization': f'Bearer {TRADIER_API_KEY}', 'Accept': 'application/json'}
    )
    json_response = response.json()

    selected_option = put_delta_select(json_response, current_price, target_delta, max_price)
    if selected_option is None:
        utils.write_error("No Options Available for Selected Delta")
        exit()
    # print(selected_option)
    
    bid_price = selected_option['bid']
    strike_price = selected_option['strike']

    # print(current_price, strike_price, bid_price, expiration_date)
    return current_price, strike_price, bid_price, expiration_date
    

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

    # print (current_date, bid_ratio, bid_ratio_conditions[strategy][ratio_thresholds[current_date]])

    if current_date in ratio_thresholds:
        current_day_index = ratio_thresholds[current_date]
        if bid_ratio >= bid_ratio_conditions[strategy][current_day_index]:
            # Bid price meets the condition
            return 0
        else:
            # Bid price does not meet the condition
            return 1
    else:
        # Invalid date
        return 2


def calculate_options_amount(strike_price, capital, strategy):
    # Adjust capital based on strategy
    if strategy == "aggressive":
        adjusted_capital = capital
    elif strategy == "balanced":
        adjusted_capital = capital * 0.8
    elif strategy == "conservative":
        adjusted_capital = capital * 0.6

    # Calculate the normalized quantity
    normalized_quantity = adjusted_capital / (strike_price * 100)
    return math.floor(normalized_quantity)


# Get current date details
def get_date():
    current_day = pd.Timestamp.today() + pd.Timedelta(days=1)
    current_date = current_day.day_name()
    current_time = current_day.time() 
    valid_exp_date = current_day.date() + pd.Timedelta(days=4)

    return current_day, current_date, current_time, valid_exp_date

# Write to output
def write_stock_details(symbol, stock_price, strike_price, bid_price, expiration_date_pd, percent_change):
    print(f"\nCURRENT DETAILS: {symbol}")
    print("----------------------------")
    print(f"Current Price: {stock_price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Percent Change: {percent_change}\n")

def write_selling_details(symbol, expiration_date_pd, price, strike_price, bid_price, options_amount):
    print(f"\nSELLING DETAILS: {symbol}")
    print("----------------------------")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Share Price: {price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Amount: {options_amount}\n")

def write_error(error):
    print(f"ERROR: {error}")