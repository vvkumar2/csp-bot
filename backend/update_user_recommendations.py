import requests
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin SDK
cred = credentials.Certificate('./put-mate-firebase-key.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Fetch stocks from Firestore
users_ref = db.collection('users')
users = users_ref.get()

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
            # ... add other necessary fields
        }

        
        # Send POST request to Flask server
        try:
            print('Sending POST request: ' + str(data) + '\n')
            response = requests.post('http://trading-env.eba-pyibygm7.us-east-2.elasticbeanstalk.com/recommendation', json=data)
            print(response.json())
        except Exception as e:
            print('Error sending POST request')
            print(e)

        
        
        # Update Firestore with the recommendation
        # This step depends on how you want to store the recommendation in Firestore.
        # For this example, I'm assuming you want to add a 'recommendation' field to each stock in stock_list.
        # stock['recommendation'] = recommendation['data']

    # Update the user's stock_list in Firestore
    # user_ref = users_ref.document(user.id)
    # user_ref.update({
    #     'stock_list': stock_list
    # })
