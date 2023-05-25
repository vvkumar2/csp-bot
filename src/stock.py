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
def get_stock_details(ticker, current_time, valid_exp_date):
    # Get the ticker details
    ticker_details = yf.Ticker(ticker)

    # Get the current price and calculate the strike price
    price = ticker_details.info['currentPrice']
    strike_price = min(round_price(price - PRICE_TO_STRIKE_DIFFERENCE), MAX_STRIKE_PRICE)

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
def check_bid_price(day, bid):
    conditions = {
        'Monday': bid >= 0.05,
        'Tuesday': bid >= 0.04,
        'Wednesday': bid >= 0.03,
        'Thursday': bid >= 0.03,
        'Friday': bid >= 0.03,
    }

    if day in conditions.keys():
        if conditions[day]:
            return 0
        else:
            return 1
    else:
        return 2

# Calculate how many options to sell based on the day and bid price
def calculate_options_amount(day, bid, percent_change):
    options_amounts = {
        'Monday': 15 if percent_change <= PERCENT_CHANGE_THRESHOLD or bid >= 0.06 else (10 if percent_change <= PERCENT_CHANGE_THRESHOLD/2 and bid >= 0.05 else 0),
        'Tuesday': 12 if percent_change <= PERCENT_CHANGE_THRESHOLD or bid >= 0.05 else (5 if percent_change <= PERCENT_CHANGE_THRESHOLD/2 and bid >= 0.04 else 0),
        'Wednesday': 8 if percent_change <= PERCENT_CHANGE_THRESHOLD or bid >= 0.04 else 0,
        'Thursday': 5 if percent_change <= PERCENT_CHANGE_THRESHOLD or bid >= 0.04 else 0,
        'Friday': 3 if percent_change <= PERCENT_CHANGE_THRESHOLD or bid >= 0.03 else 0,
    }
    return options_amounts.get(day, 0)
