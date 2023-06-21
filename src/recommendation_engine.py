import stock_helper
import utils

def recommendation (stock_ticker, capital, target_delta, max_price, strategy):
    # Get current date
    current_day, current_date, current_time, valid_exp_date = utils.get_date()

    # Get stock details
    price, strike_price, bid_price, expiration_date_pd = stock_helper.get_stock_details(valid_exp_date, stock_ticker, target_delta, max_price)

    # Check bid price
    trade_allowed = stock_helper.check_bid_price(current_date, bid_price, strike_price, strategy)
    if trade_allowed == 1:
        utils.write_error("Bid Price Too Low")
        return
    elif trade_allowed == 2:
        utils.write_error("Invalid Day")
        return
    
    # Calculate how many options to sell
    options_amount = stock_helper.calculate_options_amount(strike_price, capital, strategy)
    if options_amount == 0:
        utils.write_error("Not enough capital")
        return

    # Print details of option (date, price, strike, bid, quantity)
    utils.write_selling_details(stock_ticker, expiration_date_pd, price, strike_price, bid_price, options_amount)

    # TODO: Add to database


if __name__ == "__main__":
    recommendation("AAPL", 2000, .9, 190, "balanced")