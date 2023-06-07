import pandas as pd
import json

# Constants
PERCENT_CHANGE_THRESHOLD = -0.01
PRICE_TO_STRIKE_DIFFERENCE = 0.08
MAX_STRIKE_PRICE = 5.5


def get_json_info(filename):
    with open(filename) as file:
        json_data = file.read()

    # Parse the JSON data
    parsed_data = json.loads(json_data)

    # Store data in the correct data structures
    stock_data = {}

    for stock_name, stock_info in parsed_data.items():
        symbol = stock_info["symbol"]
        price_to_strike_diff = stock_info["price_to_strike_diff"]
        max_strike = stock_info["max_strike"]
        percent_change_threshold = stock_info["percent_change_threshold"]
        target_bid = stock_info["target_bid_price"]

        stock_data[stock_name] = {
            "symbol": symbol,
            "price_to_strike_diff": price_to_strike_diff,
            "max_strike": max_strike,
            "percent_change_threshold": percent_change_threshold,
            "target_bid_price": target_bid
        }

    # Print the stored data
    for stock_name, stock_info in stock_data.items():
        print(f"Symbol: {stock_info['symbol']}")
        print(f"Price to Strike Difference: {stock_info['price_to_strike_diff']}")
        print(f"Max Strike: {stock_info['max_strike']}")
        print(f"Percent Change Threshold: {stock_info['percent_change_threshold']}")
        print(f"Target Bid: {stock_info['target_bid_price']}")
        print()
    
    return stock_data



# Get current date details
def get_date():
    current_day = pd.Timestamp.today()
    current_date = current_day.day_name()
    current_time = current_day.time()
    valid_exp_date = current_day.date() + pd.Timedelta(days=5)

    return current_day, current_date, current_time, valid_exp_date

# Write to output
def write_stock_details(symbol, stock_price, strike_price, bid_price, expiration_date_pd, percent_change):
    print("\nCURRENT DETAILS: {symbol}}")
    print("----------------------------")
    print(f"Current Price: {stock_price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Percent Change: {percent_change}\n")

def write_selling_details(symbol, expiration_date_pd, price, strike_price, bid_price, options_amount):
    print("\nSELLING DETAILS: {symbol}}")
    print("----------------------------")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Share Price: {price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Amount: {options_amount}\n")

def write_error(error):
    print(f"ERROR: {error}")