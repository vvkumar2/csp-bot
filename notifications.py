import os
import dotenv
import http.client as httplib
import urllib.parse as urllib
import ssl

# Load environment variables
dotenv.load_dotenv()
PUSHOVER_API_KEY = os.getenv("PUSHOVER_API_KEY")
PUSHOVER_USER_KEY = os.getenv("PUSHOVER_USER_KEY")

def send_notification(expiration_date_pd, strike_price, options_amount, bid_price):
    try:
        conn = httplib.HTTPSConnection("api.pushover.net:443", context=ssl._create_unverified_context())
        conn.request("POST", "/1/messages.json",
            urllib.urlencode({
                "token": PUSHOVER_API_KEY,
                "user": PUSHOVER_USER_KEY,
                "message": f"SOFI 0{expiration_date_pd.month}/{expiration_date_pd.day}/{expiration_date_pd.year} {strike_price:.2f} P\nSTO {options_amount} @ Limit {bid_price}, Day",
                }), {"Content-type": "application/x-www-form-urlencoded"})
        conn.getresponse()
        return True
    
    except Exception as e:
        print(e)
        return False