from flask import Flask, jsonify, request
import firebase_admin
from firebase_admin import credentials, firestore
import recommendation_engine

cred = credentials.Certificate('./put-mate-firebase-key.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

application = Flask(__name__)

@application.route("/")
def index():
    return "Your Flask App Works!"


@application.route('/recommendation', methods=['POST'])
def get_recommendation():
    data = request.get_json()

    # Extract required data from the request payload
    user_id = data['user_id']
    stock_ticker = data['stock_ticker']
    capital = data['capital']
    target_delta = data['target_delta']
    max_price = data['max_price']
    strategy = data['strategy']

    # Call your recommendation function
    new_recommendation = recommendation_engine.recommendation(stock_ticker, capital, target_delta, max_price, strategy)

    # Return a JSON response
    if new_recommendation != None:
        # Add recommendation to database    
        doc_ref = db.collection('users').document(user_id)
        doc_ref.update({
            "recommendations_list": firestore.ArrayUnion([new_recommendation])
        })

    # Return a JSON response
    return jsonify({'message': 'Recommendation processed successfully', 'data': new_recommendation})

if __name__ == '__main__':
    application.run()
