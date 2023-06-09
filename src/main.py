import database
import notifications
import utils
import stock

# Get the info from json file
stock_params = utils.get_json_info("parameters.json")

# Loop through each stock
for stock_name, stock_info in stock_params.items():
    # Get current date
    current_day, current_date, current_time, valid_exp_date = utils.get_date()

    # Get stock details
    price, strike_price, bid_price, expiration_date_pd, percent_change = stock.get_stock_details(current_time, valid_exp_date, stock_info)

    # Print details of stock (price, strike, bid, expiration date, percent change)
    utils.write_stock_details(stock_info["symbol"], price, strike_price, bid_price, expiration_date_pd, percent_change)

    # Check bid price
    trade_allowed = stock.check_bid_price(current_date, bid_price, stock_info)
    if trade_allowed == 1:
        utils.write_error("Bid Price Too Low")
        continue
    elif trade_allowed == 2:
        utils.write_error("Invalid Day")
        continue

    # Calculate how many options to sell
    options_amount = stock.calculate_options_amount(current_date, bid_price, percent_change, strike_price, stock_info)
    if options_amount == 0:
        utils.write_error("Didn't meet conditions to sell")
        continue

    # Print details of option (date, price, strike, bid, quantity)
    utils.write_selling_details(stock_info["symbol"], expiration_date_pd, price, strike_price, bid_price, options_amount)

    # TODO: Add to database
    # if not database.add_to_database(stock_info["symbol"], current_day, expiration_date_pd, options_amount, strike_price, bid_price):
    #     utils.write_error("Too many options sold")
    #     exit()

    # Send notification
    if not notifications.send_notification(expiration_date_pd=expiration_date_pd, strike_price=strike_price, options_amount=options_amount, bid_price=bid_price, profit=False, stock_info=stock_info["symbol"]):
        utils.write_error("Failed to send notification")
        exit()

    print("Sent notification")

# TODO: Actually sell the options


