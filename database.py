import dotenv
import os
from supabase import create_client
import pandas as pd

# Load environment variables
dotenv.load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Connect to Supabase
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

# Global variables
MAX_DAY_QUANTITY = 20
MAX_WEEK_QUANTITY = 40

def get_all_trade_info():
    current_day = pd.Timestamp.today()
    current_week = current_day.week
    data, count = supabase.table('all_trade_info').select("*").eq("week_num", current_week).execute()
    return data[1]

def add_to_database(current_date, expiry_date, quantity, bid_price):
    # Get day and week data from Supabase
    day_data, day_count = supabase.table('daily_trade_quantity').select("quantity").eq("sell_date", current_date.isoformat()).execute()
    week_data, week_count = supabase.table('weekly_trade_quantity').select("quantity").eq("week_num", current_date.week).execute()

    # Check if day or week data exists in Supabase
    if not week_data[1]:
        supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        supabase.table('weekly_trade_quantity').insert({"week_num": current_date.week, "quantity": quantity}).execute()
        supabase.table('all_trade_info').insert({"week_num": current_date.week, "sell_date": current_date.isoformat(), "expiration_date": expiry_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        print(f"Added to database: sold {quantity} options")
        return True
    
    day_quantity = day_data[1][0]['quantity'] if day_data[1] else 0
    week_quantity = week_data[1][0]['quantity']

    # Check if quantity is greater than MAX_DAY_QUANTITY or MAX_WEEK_QUANTITY
    if week_quantity >= MAX_WEEK_QUANTITY or day_quantity >= MAX_DAY_QUANTITY:
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
        if not day_data[1]:
            supabase.table('daily_trade_quantity').insert({"sell_date": current_date.isoformat(), "quantity": quantity}).execute()
        else:
            supabase.table('daily_trade_quantity').update({"quantity": day_total_sold}).eq("sell_date", current_date.isoformat()).execute()
        supabase.table('all_trade_info').insert({"week_num": current_date.week, "sell_date": current_date.isoformat(), "expiration_date": expiry_date.isoformat(), "bid_price": bid_price, "quantity": quantity}).execute()
        print(f"Added to database: sold {quantity} options")
        return True
    return False
