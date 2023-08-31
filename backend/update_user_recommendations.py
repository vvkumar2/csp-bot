import requests
import logging
import db_operations

logging.basicConfig(level=logging.INFO)

# Initialize Firebase Admin SDK
db = db_operations.initialize_firestore()
if db is None:
    logging.error("Failed to initialize Firestore database. Exiting...")
    exit()

# Fetch stocks from Firestore
users = db_operations.fetch_users_from_firestore(db)
if users is None:
    logging.error("Failed to fetch user data. Exiting...")
    exit()

for user in users:
    user_data = user.to_dict()
    stock_list = user_data.get('stock_list', [])

    # For each stock in the user's stock_list
    for stock in stock_list:
        # Prepare data for POST request
        data = {
            'user_id': user.id,
            'stock_ticker': stock['ticker'],
            'target_delta': float(stock['delta']),
            'capital': float(stock['max_holdings']),
            'max_price': float(stock['max_price']),
            'strategy': stock['strategy'].lower()
        }

        # Send POST request to Flask server
        try:
            logging.info(f"Sending POST request: {data}")
            response = requests.post('http://trading-env.eba-pyibygm7.us-east-2.elasticbeanstalk.com/recommendation', json=data)
            response_data = response.json()
            if response.status_code == 200:
                logging.info(response_data)
            else:
                logging.warning(f"Received non-200 status code: {response.status_code}. Response: {response_data}")
        except requests.RequestException as req_err:
            logging.error(f"Error sending POST request: {req_err}")
        except Exception as e:
            logging.error(f"Unexpected error: {e}")
