import requests
import logging
import db_operations
import datetime
import dotenv
import os
from utils import request_handler

logging.basicConfig(level=logging.INFO)

dotenv.load_dotenv()
TRADIER_API_KEY = os.getenv('TRADIER_API_KEY')
headers = {
        'Authorization': f'Bearer {TRADIER_API_KEY}',
        'Accept': 'application/json'
    }

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

    # Remove stocks from added_recs_list that have an expiry date (dd/MM) past the current date and also update "is_sold" to true if the option has gaiend 30% or lost 50%
    new_added_recs_list = []
    for rec in added_recs_list:
        expiry = datetime.datetime.strptime(rec['expiry_date'], "%m/%d")
        expiry = expiry.replace(year=current_year)  # Assume expiry is for the current year

        if expiry.date() >= today.date():
            if rec['is_sold'] == False:
                # check the option from tradier and caluclate gain/loss and then update the is_sold field
                # Calculate the strike price based on the delta
                response = request_handler('https://api.tradier.com/v1/markets/options/chains',
                params={'symbol': rec["ticker"], 'expiration': expiry}, headers=headers)

                if not response or 'options' not in response or 'option' not in response['options']:
                    logging.error(f"Unexpected JSON structure in response for options: {response}")
                    continue
                
                matched_option = None
                all_options = response['options']['option']
                for option in all_options:
                    if option['strike'] == rec['strike_price'] and option['option_type'].lower() == 'put':
                        matched_option = option
                        break
                
                if matched_option is None:
                    logging.error(f"Could not find option with strike price {rec['strike_price']} for stock {rec['ticker']}")
                    continue

                current_price = matched_option['bid']
                gain_loss = (rec["bid_price"] - current_price)/rec["bid_price"]
                if gain_loss >= 0.3 or gain_loss <= -0.5:
                    rec['is_sold'] = True
                    rec['profit_loss'] = gain_loss * 100
                    new_added_recs_list.append(rec)
                else:
                    new_added_recs_list.append(rec)
        else:
            if rec['is_expired'] == True and rec['is_sold'] == True:
                continue

            rec['is_sold'] = True
            rec['is_expired'] = True
            
            # Get current price of the stock
            response = request_handler('https://api.tradier.com/v1/markets/quotes', params={'symbols': rec["ticker"], 'greeks': 'false'}, headers=headers)

            if not response or 'quotes' not in response or 'quote' not in response['quotes']:
                logging.error(f"Unexpected JSON structure in response for current price: {response}")
                continue

            current_price = response['quotes']['quote']['last']

            if current_price <= rec['strike_price']:
                rec['expiration_status'] = 'ITM'
            else:
                rec['expiration_status'] = 'OTM'

            new_added_recs_list.append(rec)
            

    # Add new recommendations to Firestore
    if new_recommendations_list:
        db_operations.replace_recommendation_list_in_db(db, user.id, new_recommendations_list)
        new_recommendations_list = []

    # Add new added recommendations to Firestore
    if new_added_recs_list:
        db_operations.replace_added_recommendation_list_in_db(db, user.id, new_added_recs_list)
        new_added_recs_list = []

