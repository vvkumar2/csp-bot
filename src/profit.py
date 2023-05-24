import database, notifications, utils

def calculate_total_profit():
    data = database.get_all_trade_info()
    total_profit = 0
    total_quantity = 0
    for row in data:
        total_profit += 100 * row['quantity'] * row['bid_price']
        total_quantity += row['quantity']
    total_profit -= total_quantity * 0.65
    return total_profit, total_quantity

if __name__ == "__main__":
    total_profit, total_quantity = calculate_total_profit()
    if not notifications.send_notification(options_amount=total_quantity, profit=total_profit):
        utils.write_error("Failed to send notification")
        exit()
    print(f"Sent notification. Profit: {total_profit:.2f}")