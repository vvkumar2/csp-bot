import database, notifications, utils, stock
import pandas as pd

# Calculate profit for each strike price and store in dictionary
def calculate_profit(trade_data):
    profit_data = {}
    total_quantity = 0
    collateral = 0
    average_bid = 0

    for trade in trade_data:
        strike_price = trade['strike_price']
        quantity = trade['quantity']
        bid_price = trade['bid_price']

        if strike_price not in profit_data:
            profit_data[strike_price] = [0, 0]
        profit_data[strike_price][0] += 100 * quantity * bid_price
        profit_data[strike_price][1] += quantity
        total_quantity += quantity

    for key in profit_data:
        profit_data[key][0] -= profit_data[key][1] * 0.65
        collateral += profit_data[key][1] * key * 100
        average_bid += profit_data[key][0]

    average_bid = round(average_bid/total_quantity, 2)
    total_profit = 0
    for strike in profit_data:
        total_profit += profit_data[strike][0]

    return profit_data, total_profit, average_bid, total_quantity, collateral

# Get all trade information from database
def get_all_trade_info():
    try:
        data = database.get_all_trade_info()
        return data
    except Exception as e:
        print(f"Error retrieving trade information: {str(e)}")
        return []

# Calculate profit and send notification with total profit and quantity
if __name__ == "__main__":
    underlying_price = stock.get_underlying_price("SOFI")
    trade_data = get_all_trade_info()
    profit_data, total_profit, average_bid, total_quantity, collateral = calculate_profit(trade_data)
    
    message = f"You made ${total_profit:.2f} this week!\n\nDetails:\n"

    for strike in profit_data:
        if strike > underlying_price:
            message += f"Strike: ${strike:.2f}, Quantity: {profit_data[strike][1]}. ASSIGNED.\n"
        else:
            message += f"Strike: ${strike:.2f}, Quantity: {profit_data[strike][1]}, Profit: ${profit_data[strike][0]:.2f}\n"

    # Add to database
    current_day = pd.Timestamp.today()
    roi = round(total_profit / collateral * 100, 2)
    if not database.add_weekly_profit_data(current_day, average_bid, total_quantity, total_profit, collateral, roi):
        utils.write_error("Failed to add weekly profit data to database")
    else:
        # Send notification
        # if not notifications.send_notification(profit=True, message=message):
        #     utils.write_error("Failed to send notification")
        #     exit()
        # else:
        #     print (message)
        print("Sent notification")