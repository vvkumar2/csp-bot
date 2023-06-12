import database, notifications, utils, stock
import pandas as pd

# Calculate profit for each strike price and store in dictionary
def calculate_profit(trade_data):
    profit_data = {}

    # split trade_data up by unique symbol
    symbols = []
    for trade in trade_data:
        symbol = trade['symbol']
        if symbol not in symbols:
            symbols.append(symbol)
        
    for symbol in symbols:
        symbol_data = []
        for trade in trade_data:
            if trade['symbol'] == symbol:
                symbol_data.append(trade)
        profit_data[symbol] = calculate_profit_helper(symbol_data)

    return profit_data

# Helper function for calculate_profit
def calculate_profit_helper(trade_data):
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


# Main function to calculate profit
if __name__ == "__main__":
    # underlying_price = stock.get_underlying_price("SOFI")
    trade_data = database.get_all_trade_info()
    profit_data = calculate_profit(trade_data)
    total_profit = 0
    total_collateral = 0
    message = ""

    # iterate through profit data to print each symbol's profit for each strike price
    for symbol in profit_data:
        total_profit += profit_data[symbol][1]
        total_collateral += profit_data[symbol][4]
        for key, value in profit_data[symbol][0].items():
            message += f"{symbol} - Strike: {key}, Profit: {value[0]}, Quantity: {value[1]}\n"
        print("\n")

    message_prepend = f"You made ${total_profit:.2f} this week!\n\nDetails:\n"
    message = message_prepend + message

    print(message)

    # Add to database
    current_day = pd.Timestamp.today()
    for symbol in profit_data:
        roi = round(profit_data[symbol][1] / profit_data[symbol][4] * 100, 2)
        if not database.add_weekly_profit_data(symbol, current_day, profit_data[symbol][2], profit_data[symbol][3], profit_data[symbol][1], profit_data[symbol][4], roi):
            utils.write_error("\nFailed to add weekly profit data to database")
            exit()
    
    # Send notification
    if not notifications.send_notification(profit=True, message=message):
        utils.write_error("\nFailed to send notification")
        exit()
    else:
        print("\nNotification sent successfully")
