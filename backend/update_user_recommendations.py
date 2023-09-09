import requests
import logging
import db_operations
import datetime

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

# Initialize list of recommendations
new_recommendations_list = []

# For each user in the database
for user in users:
    user_data = user.to_dict()
    stock_list = user_data.get('stock_list', [])
    added_recs_list = user_data.get('added_recommendations_list', [])

    # For each stock in the user's stock_list
    for stock in stock_list:
        # Prepare data for POST request
        data = {
            'stock_ticker': stock['ticker'],
            'target_delta': 0.15 if stock['strategy'].lower() == 'conservative' else 0.23 if stock['strategy'].lower() == 'balanced' else 0.35,
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
                new_recommendations_list.append(response_data['data'])
            else:
                logging.warning(f"Received non-200 status code: {response.status_code}. Response: {response_data}")
        except requests.RequestException as req_err:
            logging.error(f"Error sending POST request: {req_err}")
        except Exception as e:
            logging.error(f"Unexpected error: {e}")

    # Get today's date
        today = datetime.datetime.now()
        current_year = today.year

    # Remove stocks from added_recs_list that have an expiry date (dd/MM) past the current date
    new_added_recs_list = []
    for rec in added_recs_list:
        expiry = datetime.datetime.strptime(rec['expiry_date'], "%m/%d")
        expiry = expiry.replace(year=current_year)  # Assume expiry is for the current year

        if expiry.date() >= today.date():
            new_added_recs_list.append(rec)


    # Add new recommendations to Firestore
    if new_recommendations_list:
        db_operations.replace_recommendation_list_in_db(db, user.id, new_recommendations_list)
        new_recommendations_list = []

    # Add new added recommendations to Firestore
    if new_added_recs_list:
        db_operations.replace_added_recommendation_list_in_db(db, user.id, new_added_recs_list)
        new_added_recs_list = []

