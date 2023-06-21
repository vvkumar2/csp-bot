import pandas as pd

# Get current date details
def get_date():
    current_day = pd.Timestamp.today()
    current_date = current_day.day_name()
    current_time = current_day.time()
    valid_exp_date = current_day.date() + pd.Timedelta(days=5)

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