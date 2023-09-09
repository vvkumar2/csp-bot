import firebase_admin
from firebase_admin import firestore, credentials
import logging

logging.basicConfig(level=logging.INFO)

def initialize_firestore():
    try:
        cred = credentials.Certificate('./put-mate-firebase-key.json')
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        return db
    except Exception as e:
        logging.error(f"Failed to initialize Firebase Admin SDK: {e}")
        return None

def fetch_users_from_firestore(db):
    try:
        users_ref = db.collection('users')
        users = users_ref.get()
        return users
    except Exception as e:
        logging.error(f"Failed to fetch stocks from Firestore: {e}")
        return None

def add_recommendation_to_db(db, user_id, new_recommendation):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc_ref.update({
            "recommendations_list": firestore.ArrayUnion([new_recommendation])
        })
        logging.info(f"Recommendation added to database for user {user_id}.")
    except Exception as e:
        logging.error(f"Error adding recommendation to database for user {user_id}: {str(e)}")

def replace_recommendation_list_in_db(db, user_id, new_recommendation_list):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc_ref.update({
            "recommendations_list": new_recommendation_list
        })
        logging.info(f"Recommendation list updated for user {user_id}.")
    except Exception as e:
        logging.error(f"Error updating recommendation list for user {user_id}: {str(e)}")

def replace_added_recommendation_list_in_db(db, user_id, new_added_recommendation_list):
    try:
        doc_ref = db.collection('users').document(user_id)
        doc_ref.update({
            "added_recommendations_list": new_added_recommendation_list
        })
        logging.info(f"Added recommendation list updated for user {user_id}.")
    except Exception as e:
        logging.error(f"Error updating added recommendation list for user {user_id}: {str(e)}")