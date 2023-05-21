# TODO: Leave computer open, asleep overnight

import yfinance as yf
import pandas as pd
import math
import urllib.parse as urllib
import http.client as httplib
import ssl
import dotenv
import os
from supabase import create_client, Client

# Load environment variables
dotenv.load_dotenv()
PUSHOVER_API_KEY = os.getenv("PUSHOVER_API_KEY")
PUSHOVER_USER_KEY = os.getenv("PUSHOVER_USER_KEY")
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Connect to Supabase
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_KEY")
supabase = create_client(url, key)

# Global variables
MAX_DAY_QUANTITY = 20
MAX_WEEK_QUANTITY = 40

# Round to nearest 0.5
def round_price(num):
    whole_num = math.floor(num)
    decimal = num - whole_num
    if decimal <= 0.5:
        return whole_num
    else:
        return whole_num + 0.5
    
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
    if day == 'Monday':
        if percent_change <= -0.01 or bid >= 0.06:
            return 15
        return 0
    elif day == 'Tuesday':
        if percent_change <= -0.01 or bid >= 0.05:
            return 12
        return 0
    elif day == 'Wednesday':
        if percent_change <= -0.01 or bid >= 0.04:
            return 8
        return 0
    elif day == 'Thursday':
        if percent_change <= -0.01 or bid >= 0.04:
            return 5
        return 0
    elif day == 'Friday':
        if percent_change <= -0.01 or bid >= 0.03:
            return 3
        return 0
    else:
        return 0

def add_to_database(current_date, expiry_date, quantity, bid_price):
    # Get day and week data from Supabase
    day_data, day_count = supabase.table('daily_trade_quantity').select("quantity").eq("sell_date", current_date.isoformat()).execute()
    week_data, week_count = supabase.table('weekly_trade_quantity').select("quantity").eq("week_num", current_date.week).execute()

    # Check if day or week data exists in Supabase
    if week_data[1] == []:
        supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        supabase.table('weekly_trade_quantity').insert({"week_num": current_date.week, "quantity": quantity}).execute()
        supabase.table('all_trade_info').insert({"sell_date": current_date.isoformat(), "expiration_date": expiry_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        print(f"Added to database: sold {quantity} options")
        return True
    if day_data[1] == []:
        day_quantity = 0
    else:
        day_quantity = day_data[1][0]['quantity']
    
    week_quantity = week_data[1][0]['quantity']

    # Check if quantity is greater than MAX_DAY_QUANTITY or MAX_WEEK_QUANTITY
    if week_quantity >= MAX_WEEK_QUANTITY:
        quantity = 0
    if day_quantity >= MAX_DAY_QUANTITY:
        quantity = 0

    # Check if quantity is greater than MAX_DAY_QUANTITY or MAX_WEEK_QUANTITY after adding new quantity
    week_total_sold = quantity + week_quantity
    if week_total_sold > MAX_WEEK_QUANTITY:
        quantity = MAX_WEEK_QUANTITY - week_quantity
        week_total_sold = MAX_WEEK_QUANTITY

    day_total_sold = quantity + day_quantity
    if day_total_sold > MAX_DAY_QUANTITY:
        quantity = MAX_DAY_QUANTITY - day_quantity
        day_total_sold = MAX_DAY_QUANTITY
        week_total_sold = quantity + week_quantity


    # Insert all trade info data into Supabase 
    if quantity > 0:
        supabase.table('weekly_trade_quantity').update({"quantity": week_total_sold}).eq("week_num", current_date.week).execute()
        if day_data[1] == []:
            supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        else:
            supabase.table('daily_trade_quantity').update({"quantity": day_total_sold}).eq("sell_date", current_date.isoformat()).execute()
        supabase.table('all_trade_info').insert({"sell_date": current_date.isoformat(), "expiration_date": expiry_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        print(f"Added to database: sold {quantity} options")
        return True
    return False

# Write to output
def write_stock_details(stock_price, strike_price, bid_price, expiration_date_pd):
    print("\nCURRENT DETAILS:")
    print("----------------------------")
    print(f"Current Price: {stock_price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Percent Change: {percent_change}\n")

def write_selling_details(expiration_date_pd, price, strike_price, bid_price, options_amount):
    print("\nSELLING DETAILS:")
    print("----------------------------")
    print(f"Expiration Date: {expiration_date_pd}")
    print(f"Share Price: {price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Amount: {options_amount}\n")

def write_error(error):
    print(f"ERROR: {error}")
    
# Get current date
current_day = pd.Timestamp.today()
current_date = current_day.day_name()
current_time = current_day.time()
valid_exp_date = current_day.date() + pd.Timedelta(days=5)

# Get the data for the stock
sofi = yf.Ticker("SOFI")
price = sofi.info['currentPrice']
strike_price = min(round_price(price - 0.08), 5.5)

# Get the open price from 30 minutes ago
if pd.Timestamp("06:30:00").time() <= current_time < pd.Timestamp("06:59:00").time():
    sofi_history = sofi.history(period="2d", interval="1d")
    last_close = sofi_history.iloc[-2]['Close']
elif pd.Timestamp("06:59:00").time() <= current_time < pd.Timestamp("12:00:00").time():
    sofi_history = sofi.history(period="1d", interval="30m")
    last_close = sofi_history.iloc[-2]['Open']
else:
    write_error("Invalid Time")
    exit()

# Calculate percent change rounded to 4 decimal places
percent_change = round((price - last_close) / last_close, 4)

# Get the expiration date and check if it is valid
expiration_date = sofi.options[0]
expiration_date_pd = (pd.to_datetime(expiration_date).date())
if valid_exp_date < expiration_date_pd:
    write_error("Invalid Expiration Date")
    exit()

# Get the option chain for the expiration date
opt = sofi.option_chain(expiration_date).puts

# Get the row containing the strike price
row = opt.loc[opt['strike'] == strike_price]

# Get the bid price
bid_price = row['bid'].values[0]
write_stock_details(price, strike_price, bid_price, expiration_date_pd)

# Check bid price
trade_allowed = check_bid_price(current_date, bid_price)
if trade_allowed == 1:
    write_error("Bid Price Too Low")
    exit()
elif trade_allowed == 2:
    write_error("Invalid Day")
    exit()

# Calculate how many options to sell
options_amount = calculate_options_amount(current_date, bid_price, percent_change)

# Check if there are enough options to sell
if options_amount == 0:
    write_error("Didn't meet conditions to sell")
    exit()

# What options to sell (including date, strike, bid, amount)
write_selling_details(expiration_date_pd, price, strike_price, bid_price, options_amount)

# Check if we can add to the database (if we haven't sold too many options)
if add_to_database(current_day, expiration_date_pd, options_amount, bid_price):
    # Send a notification to my phone
    conn = httplib.HTTPSConnection("api.pushover.net:443", context=ssl._create_unverified_context())
    conn.request("POST", "/1/messages.json",
    urllib.urlencode({
        "token": PUSHOVER_API_KEY,
        "user": PUSHOVER_USER_KEY,
        "message": f"SOFI 0{expiration_date_pd.month}/{expiration_date_pd.day}/{expiration_date.year} {strike_price:.2f} P\nSTO {options_amount} @ Limit {bid_price}, Day",
    }), { "Content-type": "application/x-www-form-urlencoded" })
    conn.getresponse()
    print("Sent notification")
else:
    write_error("Too many options sold")
    exit()



# TODO: If selling options: add date sold, strike price, expiration date, amount sold, bid price to supabase
        # Also add to a different database, the date and amount sold
        
# TODO: Check how many you sold today, if you sold more than 20 or more than max 40, don't sell anymore

# TODO: Actually sell the options


