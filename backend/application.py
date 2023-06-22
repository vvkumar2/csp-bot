from flask import Flask, jsonify, request
import recommendation_engine

application = Flask(__name__)

@application.route("/")
def index():
    return "Your Flask App Works!"


@application.route('/recommendation', methods=['POST'])
def get_recommendation():
    data = request.get_json()

    # Extract required data from the request payload
    stock_ticker = data['stock_ticker']
    capital = data['capital']
    target_delta = data['target_delta']
    max_price = data['max_price']
    strategy = data['strategy']

    # Call your recommendation function
    recommendation_engine.recommendation(stock_ticker, capital, target_delta, max_price, strategy)

    # Return a JSON response
    return jsonify({'message': 'Recommendation processed successfully'})

if __name__ == '__main__':
    application.run()
