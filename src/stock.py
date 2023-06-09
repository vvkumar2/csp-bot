import yfinance as yf
import pandas as pd
import math
import utils

# Constants
PRICE_TO_STRIKE_DIFFERENCE = 0.08
MAX_STRIKE_PRICE = 5.5
PERCENT_CHANGE_THRESHOLD = -0.01

# Get stock price
def get_underlying_price(ticker):
    ticker_details = yf.Ticker(ticker)
    return ticker_details.info['currentPrice']

# Get stock details
def get_stock_details(current_time, valid_exp_date, stock_info):
    # Get the ticker details
    ticker_details = yf.Ticker(stock_info["symbol"])

    # Get the current price and calculate the strike price
    price = ticker_details.info['currentPrice']
    strike_price = min(round_price(price - stock_info["price_to_strike_diff"]), stock_info["max_strike"])

    # Get the open price from 30 minutes ago  
    if pd.Timestamp("06:30:00").time() <= current_time < pd.Timestamp("06:59:00").time():
        sofi_history = ticker_details.history(period="2d", interval="1d")
        last_close = sofi_history.iloc[-2]['Close']
    elif pd.Timestamp("06:59:00").time() <= current_time < pd.Timestamp("12:00:00").time():
        sofi_history = ticker_details.history(period="1d", interval="30m")
        last_close = sofi_history.iloc[-2]['Open']
    else:
        utils.write_error("Invalid Time")
        exit()

    # Calculate percent change rounded to 4 decimal places
    percent_change = round((price - last_close) / last_close, 4)

    # Get the expiration date and check if it is valid
    expiration_date = ticker_details.options[0]
    expiration_date_pd = (pd.to_datetime(expiration_date).date())
    if valid_exp_date < expiration_date_pd:
        utils.write_error("Invalid Expiration Date")
        exit()

    # Get the option chain for the expiration date
    opt = ticker_details.option_chain(expiration_date).puts

    # Get the row containing the strike price
    row = opt.loc[opt['strike'] == strike_price]

    # Get the bid price
    bid_price = row['bid'].values[0]

    return price, strike_price, bid_price, expiration_date_pd, percent_change


# Round to nearest 0.5
def round_price(num):
    return math.floor(num * 2) / 2
    
# Check if the bid price is high enough to sell
def check_bid_price(day, bid, stock_info):
    conditions = {
        'Monday': bid >= stock_info["target_bid_price"][0],
        'Tuesday': bid >= stock_info["target_bid_price"][1],
        'Wednesday': bid >= stock_info["target_bid_price"][2],
        'Thursday': bid >= stock_info["target_bid_price"][3],
        'Friday': bid >= stock_info["target_bid_price"][4],
    }

    if day in conditions.keys():
        if conditions[day]:
            return 0
        else:
            return 1
    else:
        return 2

# Calculate how many options to sell based on the day and bid price
def calculate_options_amount(day, bid, percent_change, strike_price, stock_info):
    options_amounts = {
        'Monday': 15 if percent_change <= stock_info["percent_change_threshold"] or bid >= stock_info["target_bid_price"][0]*1.15 and strike_price <= stock_info["max_strike"]*.9 else (10 if percent_change <= stock_info["percent_change_threshold"]/2 else 0),

        'Tuesday': 12 if percent_change <= stock_info["percent_change_threshold"] or bid >= stock_info["target_bid_price"][1]*1.15 and strike_price <= stock_info["max_strike"]*.9 else (5 if percent_change <= stock_info["percent_change_threshold"]/2 else 0),

        'Wednesday': 8 if percent_change <= stock_info["percent_change_threshold"] or bid >= stock_info["target_bid_price"][2]*1.15 and strike_price <= stock_info["max_strike"]*.9 else (5 if percent_change <= stock_info["percent_change_threshold"]/2 else 0),

        'Thursday': 5 if percent_change <= stock_info["percent_change_threshold"]/2 or bid >= stock_info["target_bid_price"][3]*1.15 and strike_price <= stock_info["max_strike"]*.9 else 0,

        'Friday': 3 if percent_change <= stock_info["percent_change_threshold"]/2 or bid >= stock_info["target_bid_price"][4]*1.15 and strike_price <= stock_info["max_strike"]*.9 else 0,
    }
    
    return options_amounts.get(day, 0)
