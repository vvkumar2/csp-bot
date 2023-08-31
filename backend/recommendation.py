import utils
import logging

logging.basicConfig(level=logging.INFO)

def generate_recommendation(stock_ticker, available_capital, desired_delta, max_option_price, investment_strategy):
    """Generate a recommendation based on the given inputs."""
    # Input validation
    if not stock_ticker or not isinstance(available_capital, (int, float)) or not isinstance(desired_delta, (int, float)) \
            or not isinstance(max_option_price, (int, float)) or not investment_strategy:
        logging.error("Invalid input parameters.")
        return
    
    try:
        # Fetch the current date and valid expiration date
        current_weekday, valid_expiry_date = utils.get_current_date()
    except Exception as e:
        logging.error(f"Error fetching current date: {e}")
        return

    try:
        # Fetch stock details like current price, strike price, etc.
        current_price, strike_price, option_bid_price, option_expiry_date = utils.fetch_stock_details(
            valid_expiry_date, stock_ticker, desired_delta, max_option_price)
    except Exception as e:
        logging.error(f"Error fetching stock details: {e}")
        return


     # Validate the bid price based on the investment strategy and the current day
    is_trade_allowed = utils.check_bid_price(current_weekday, option_bid_price, strike_price, investment_strategy)
    
    if is_trade_allowed == 1:
        logging.error("Bid Price Too Low")
        return
    elif is_trade_allowed == 2:
        logging.error("Invalid Day for Trade")
        return
    
    # Calculate the quantity of options to sell based on available capital and strategy
    number_of_options = utils.determine_option_quantity(strike_price, available_capital, investment_strategy)
    
    if number_of_options <= 0:
        logging.error("Insufficient capital for the trade")
        return

    # Log the details of the recommended option
    utils.log_selling_details(stock_ticker, option_expiry_date, current_price, strike_price, option_bid_price, number_of_options)

    # Construct the recommendation details
    recommendation_details = {
        "bid_price": option_bid_price,
        "delta": desired_delta,
        "expiry_date": option_expiry_date.strftime('%B %d, %Y at 12:00:00 AM UTC-4'),
        "option_quantity": str(number_of_options),
        "strike_price": strike_price,
        "ticker": stock_ticker
    }

    return recommendation_details