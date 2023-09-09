from flask import Flask, jsonify, request
import recommendation, db_operations
import logging
import datetime

application = Flask(__name__)

@application.errorhandler(400)
def bad_request(e):
    logging.error("Bad request: %s", str(e))
    return jsonify(error=str(e)), 400

@application.errorhandler(500)
def internal_server_error(e):
    logging.error("Server error: %s", str(e))
    return jsonify(error="Internal server error"), 500

@application.route("/")
def index():
    return "Your Flask App Works!"


@application.route('/recommendation', methods=['POST'])
def get_recommendation():
    try: 
        data = request.get_json()

        # Extract required data from the request payload
        stock_ticker = data['stock_ticker']
        capital = float(data['capital'])
        target_delta = float(data['target_delta'])
        max_price = float(data['max_price'])
        strategy = data['strategy']
        
        # Generate recommendation
        new_recommendation = recommendation.generate_recommendation(stock_ticker, capital, target_delta, max_price, strategy)

        # option_expiry_date = datetime.datetime.now().date()
        # datetime_obj = datetime.datetime.combine(option_expiry_date, datetime.datetime.min.time())
        # new_recommendation = {
        # "bid_price": 0.05,
        # "delta": target_delta,
        # "expiry_date": datetime_obj,
        # "option_quantity": "15",
        # "strike_price": 100,
        # "ticker": stock_ticker
        # }

        if new_recommendation:
            return jsonify({'message': 'Recommendation processed successfully', 'data': new_recommendation})
        else:
            raise ValueError("Recommendation was not created. Check inputs and try again.")
            
    except ValueError as ve:
        logging.warning(str(ve))
        return jsonify(error=str(ve)), 400
    except Exception as e:
        logging.error("Error during recommendation: %s", str(e))
        return jsonify(error="Internal server error"), 500