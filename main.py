import pandas as pd
import database
import notifications
import utils
import stock

# Get current date
current_day, current_date, current_time, valid_exp_date = utils.get_date()

# Get stock details
price, strike_price, bid_price, expiration_date_pd, percent_change = stock.get_stock_details("SOFI", current_time, valid_exp_date)

# Print details of stock (price, strike, bid, expiration date, percent change)
utils.write_stock_details(price, strike_price, bid_price, expiration_date_pd, percent_change)

# Check bid price
trade_allowed = stock.check_bid_price(current_date, bid_price)
if trade_allowed == 1:
    utils.write_error("Bid Price Too Low")
    exit()
elif trade_allowed == 2:
    utils.write_error("Invalid Day")
    exit()

# Calculate how many options to sell
options_amount = stock.calculate_options_amount(current_date, bid_price, percent_change)
if options_amount == 0:
    utils.write_error("Didn't meet conditions to sell")
    exit()

# Print details of option (date, price, strike, bid, quantity)
utils.write_selling_details(expiration_date_pd, price, strike_price, bid_price, options_amount)

# Add to database
if not database.add_to_database(current_day, expiration_date_pd, options_amount, bid_price):
    utils.write_error("Too many options sold")
    exit()

# Send notification
if not notifications.send_notification(expiration_date_pd, strike_price, options_amount, bid_price):
    utils.write_error("Failed to send notification")
    exit()

print("Sent notification")
    


# TODO: Figure out how to run cron job even when computer is asleep

# TODO: Actually sell the options


