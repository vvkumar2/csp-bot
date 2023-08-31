from flask import Flask, jsonify, request
import recommendation, db_operations
import logging

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
        user_id = data['user_id']
        stock_ticker = data['stock_ticker']
        capital = float(data['capital'])
        target_delta = float(data['target_delta'])
        max_price = float(data['max_price'])
        strategy = data['strategy']
        
        # Generate recommendation
        new_recommendation = recommendation.generate_recommendation(stock_ticker, capital, target_delta, max_price, strategy)
        if new_recommendation:
            db = db_operations.initialize_firestore()
            if db is None:
                logging.error("Failed to initialize Firestore database. Exiting...")
                exit()
            db_operations.add_recommendation_to_db(db, user_id, new_recommendation)
            return jsonify({'message': 'Recommendation processed successfully', 'data': new_recommendation})
        else:
            raise ValueError("Recommendation was not created. Check inputs and try again.")
            
    except ValueError as ve:
        logging.warning(str(ve))
        return jsonify(error=str(ve)), 400
    except Exception as e:
        logging.error("Error during recommendation: %s", str(e))
        return jsonify(error="Internal server error"), 500