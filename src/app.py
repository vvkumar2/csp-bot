from flask import Flask, jsonify, request
from recommendation_engine import recommendation

app = Flask(__name__)

@app.route('/recommendation', methods=['POST'])
def get_recommendation():
    data = request.get_json()

    # Extract required data from the request payload
    stock_ticker = data['stock_ticker']
    capital = data['capital']
    target_delta = data['target_delta']
    max_price = data['max_price']
    strategy = data['strategy']

    # Call your recommendation function
    recommendation(stock_ticker, capital, target_delta, max_price, strategy)

    # Return a JSON response
    return jsonify({'message': 'Recommendation processed successfully'})

if __name__ == '__main__':
    app.run()
