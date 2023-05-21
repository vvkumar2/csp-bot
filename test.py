import yfinance as yf
import pandas as pd
import dotenv
import os
from supabase import create_client, Client
import json

# Load environment variables
dotenv.load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Connect to Supabase
url = os.environ.get("SUPABASE_URL")
key = os.environ.get("SUPABASE_KEY")
supabase = create_client(url, key)

# Global variables
MAX_DAY_QUANTITY = 20
MAX_WEEK_QUANTITY = 40

# Variables
quantity = 8
bid_price = 0.04
non_current_date = pd.Timestamp.today().date() + pd.Timedelta(days=1)
current_date = pd.Timestamp.today()

def add_to_database(current_date, non_current_date, quantity, bid_price):
    # Get day and week data from Supabase
    day_data, day_count = supabase.table('daily_trade_quantity').select("quantity").eq("sell_date", current_date.isoformat()).execute()
    week_data, week_count = supabase.table('weekly_trade_quantity').select("quantity").eq("week_num", current_date.week).execute()

    # Check if day or week data exists in Supabase
    if week_data[1] == []:
        supabase.table('all_trade_info').insert({"sell_date": current_date.isoformat(), "expiration_date": non_current_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        supabase.table('weekly_trade_quantity').insert({"week_num": current_date.week, "quantity": quantity}).execute()
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


    # Insert all trade info data into Supabase 
    if quantity > 0:
        supabase.table('weekly_trade_quantity').update({"quantity": week_total_sold}).eq("week_num", current_date.week).execute()
        if day_data[1] == []:
            supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        else:
            supabase.table('daily_trade_quantity').update({"quantity": day_total_sold}).eq("sell_date", current_date.isoformat()).execute()
        supabase.table('all_trade_info').insert({"sell_date": current_date.isoformat(), "expiration_date": non_current_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        print("Added to all databases")
        return True
    return False

if __name__ == "__main__":
    print(add_to_database(current_date, non_current_date, quantity, bid_price))