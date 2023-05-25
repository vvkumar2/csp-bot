import database, notifications, utils, stock

# Calculate profit for each strike price and store in dictionary
def calculate_profit(trade_data):
    profit = {}

    for trade in trade_data:
        strike_price = trade['strike_price']
        quantity = trade['quantity']
        bid_price = trade['bid_price']

        if strike_price not in profit:
            profit[strike_price] = [0, 0]
        profit[strike_price][0] += 100 * quantity * bid_price
        profit[strike_price][1] += quantity

    for key in profit:
        profit[key][0] -= profit[key][1] * 0.65

    return profit

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
    profit_data = calculate_profit(trade_data)
    message = "Weekly Summary:\n"

    for strike in profit_data:
        if strike > underlying_price:
            message += f"Strike: {strike}, Quantity: {profit_data[strike][1]}. ASSIGNED.\n"
        else:
            message += f"Strike: {strike}, Quantity: {profit_data[strike][1]}, Profit: {profit_data[strike][0]:.2f}\n"

    if not notifications.send_notification(profit=False, message=message):
        utils.write_error("Failed to send notification")
        exit()
    else:
        print (message)
        print("Sent notification")
    