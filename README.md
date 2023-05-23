# Cash Secured Puts Automation

## About
This Cash Secured Put (CSP) trading bot is designed to automate the process of writing these contracts. The bot executes trades based on a predefined set of parameters and aims to generate income through the sale of put options.

The primary objective of the bot is to identify suitable stock options to sell based on specific criteria such as bid price, expiration date, and percent change in the underlying. It calculates the optimal quantity of options to sell based on the day of the week, bid price, and many more factors. The bot also includes functionality to manage trade quantities, track performance, and store trade data in a database.

By automating the trading process, this bot eliminates the need for manual monitoring and decision-making, allowing traders to focus on other aspects of their investment strategy.

Please note that while the bot provides automated trading functionality, it is essential to exercise caution and perform thorough testing before deploying it in live trading scenarios.

## How to Install
1. Set up the project environment:
   - Clone or download the project files from the repository.
   - Navigate to the project directory: `cd path/to/file`.
   - Set up a virtual environment (optional but recommended): `python3 -m venv venv`.
   - Activate the virtual environment:
     - On Linux/Mac: `source venv/bin/activate`.
     - On Windows: `venv\Scripts\activate`.

2. Install dependencies:
   - Install the required Python packages by running: `pip install -r requirements.txt`.

3. Set up the necessary environment variables (PUSHOVER_API_KEY, PUSHOVER_USER_KEY, SUPABASE_URL, SUPABASE_KEY) in a `.env` file.

## Usage
* To automate the execution of the bot, you can set up a cron job. The cron job will run the bot at specified intervals. 
* Edit your crontab file by running: crontab -e.
* Here's an example command:

```
    31 6-12 * * 1-5 cd path/to/file && mkdir -p logs/`date +\%Y-\%m-\%d` && path/to/venv/bin/python main.py > path/to/file/logs/`date +\%Y-\%m-\%d`/`date +\%H-\%M-\%S`-cron.log 2>&1
```

* Replace the path/to/file with the actual path to your project directory and path/to/venv with the path to your virtual environment. This command will run the bot every 31 minutes past the hour from 6 AM to 12 PM on weekdays (PST Trading Hours), create a log directory with the current date, and save the logs in that directory with a timestamp.

## Important Files
- `main.py`: The entry point of the application.
- `stock.py`: Contains functions related to fetching stock data and making trading decisions.
- `database.py`: Handles interactions with the database for storing trade information.
- `utils.py`: Provides utility functions used across the project.
- `notifications.py`: Handles sending notifications using the Pushover API.
