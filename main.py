import yfinance as yf
import pandas as pd
import math
import urllib.parse as urllib
import http.client as httplib
import ssl
import dotenv
import os

# Load environment variables
dotenv.load_dotenv()
PUSHOVER_API_KEY = os.getenv("PUSHOVER_API_KEY")
PUSHOVER_USER_KEY = os.getenv("PUSHOVER_USER_KEY")


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
        'Friday': bid >= 0.03
    }

    if day in conditions.keys():
        if conditions[day]:
            return 0
        else:
            return 1
    else:
        return 2

# TODO: Keep track of average selling price for the week
# Calculate how many options to sell based on the day and bid price
def calculate_options_amount(day, bid):
    if day == 'Monday':
        return 10
    elif day == 'Tuesday':
        # if averaging up
        if bid >= 0.05:
            return 10
        # if averaging down
        else:
            return 5
    elif day == 'Wednesday':
        # if averaging up
        if bid >= 0.05:
            return 8
        # if averaging down
        else:
            return 5
    elif day == 'Thursday':
        # if averaging up
        if bid >= 0.04:
            return 3
        # if averaging down
        else:
            return 0
    elif day == 'Friday':
        # if averaging up
        if bid >= 0.04:
            return 3
        # if averaging down
        else:
            return 0


# Write to output
def write_stock_details(stock_price, strike_price, bid_price, expiration_date_pd):
    print("\nCURRENT DETAILS:")
    print("----------------------------")
    print(f"Current Price: {stock_price}")
    print(f"Strike Price: {strike_price}")
    print(f"Bid Price: {bid_price}")
    print(f"Expiration Date: {expiration_date_pd}\n")

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
valid_exp_date = pd.Timestamp.today().date() + pd.Timedelta(days=5)
current_date = pd.Timestamp.today().day_name()

# Get the data for the stock
sofi = yf.Ticker("SOFI")
price = sofi.info['currentPrice']
strike_price = min(round_price(price - 0.12), 5.5)

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
options_amount = calculate_options_amount(current_date, bid_price)

# What options to sell (including date, strike, bid, amount)
write_selling_details(expiration_date_pd, price, strike_price, bid_price, options_amount)

# Send a notification to my phone
conn = httplib.HTTPSConnection("api.pushover.net:443", context=ssl._create_unverified_context())
conn.request("POST", "/1/messages.json",
  urllib.urlencode({
    "token": PUSHOVER_API_KEY,
    "user": PUSHOVER_USER_KEY,
    "message": "SOFI {expiration_date_pd.month}/{expiration_date_pd-day} {strike_price}P STO {options_amount} @ {bid_price}",
  }), { "Content-type": "application/x-www-form-urlencoded" })
conn.getresponse()


# TODO: Run job every 30 minutes, check if price is rising or falling

# TODO: If price falling: wait for the drop and then sell, if price rising: sell the puts immediately

# TODO: Actually sell the options