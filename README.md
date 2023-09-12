<div align="center">
<h1 align="center">
<img src="https://firebasestorage.googleapis.com/v0/b/put-mate.appspot.com/o/learning_images%2Fputprofit-logo.png?alt=media&token=20f57777-d189-4d54-b263-929946b9161d" width="100" />
<br>PutMate
</h1>
<h3>Developed with the software and tools listed below.</h3>

<p align="center">
<img src="https://img.shields.io/badge/Dart-B41717.svg?style&logo=Dart&logoColor=white" alt="Dart" />
<img src="https://img.shields.io/badge/Flutter-0175C2.svg?style&logo=Flutter&logoColor=white" alt="Flutter" />
<img src="https://img.shields.io/badge/Python-150458.svg?style&logo=Python&logoColor=white" alt="Python" />
<img src="https://img.shields.io/badge/Flask-000000.svg?style&logo=Flask&logoColor=white" alt="Flask" />
</p>
<img src="https://img.shields.io/github/languages/top/vvkumar2/csp-bot?style&color=5D6D7E" alt="GitHub top language" />
<img src="https://img.shields.io/github/languages/code-size/vvkumar2/csp-bot?style&color=5D6D7E" alt="GitHub code size in bytes" />
<img src="https://img.shields.io/github/commit-activity/m/vvkumar2/csp-bot?style&color=5D6D7E" alt="GitHub commit activity" />
</div>

---

## 📒 Table of Contents
- [📒 Table of Contents](#-table-of-contents)
- [📍 Overview](#-overview)
- [⚙️ Features](#-features)
- [📂 Project Structure](#project-structure)
- [🧩 Modules](#modules)
- [🚀 Getting Started](#-getting-started)

---


## 📍 Overview

The primary objective of the bot is to identify suitable stock options to sell based on specific criteria such as bid price, expiration date, and percent change in the underlying. It calculates the optimal quantity of options to sell, and notifies users when it is time to buy back an option.

By automating the option selection process, this bot eliminates the need for manual monitoring and decision-making, allowing traders to focus on other aspects of their investment strategy.

---

## ⚙️ Features

- **Cash-Secured Put Recommendations:** 
  - Provides tailored recommendations for cash-secured puts based on your selected stocks.
  - Advanced algorithm ensures optimal put options that align with current market conditions.

- **Personalized Watchlist:** 
  - Add your favorite stocks to your watchlist to receive put recommendations.
  - Easily manage and edit your watchlist to fine-tune recommendations.

- **Options Watchlist Integration:** 
  - Directly add recommended options to a dedicated watchlist.
  - Organized display of all your watched options in one location for quick referencing.

- **Timely Notifications:** 
  - Stay ahead of the curve with real-time notifications.
  - Get alerted when it's the optimal time to buy back an option, maximizing your potential gains.

- **User-Friendly Interface:** 
  - Simplified dashboard and intuitive design for effortless navigation.
  - Clear presentation of stock and option details to make informed decisions swiftly.

- **Learning and Resources:** 
  - Access comprehensive resources to understand cash-secured put strategies better.
  - Benefit from regularly updated content that caters to both beginners and seasoned traders.

---


## 📂 Project Structure

```
📂 ProjectName
│
├── 📂 frontend
│   │
│   ├── 📂 lib
│   │   │
│   │   ├── 📂 providers
│   │   │   ├── tab_provider.dart
│   │   │   ├── stock_list_provider.dart
│   │   │   ├── stock_filters_provider.dart
│   │   │   └── user_provider.dart
│   │   │
│   │   ├── 📂 models
│   │   │   ├── watchlist_recommendation_model.dart
│   │   │   ├── watchlist_stock_model.dart
│   │   │   ├── recommendation_model.dart
│   │   │   ├── user_model.dart
│   │   │   └── stock_model.dart
│   │   │
│   │   ├── 📂 screens
│   │   │   ├── auth.dart
│   │   │   ├── profile.dart
│   │   │   ├── navbar.dart
│   │   │   ├── splash.dart
│   │   │   ├── dashboard.dart
│   │   │   ├── learning.dart
│   │   │   └── stocks.dart
│   │   │
│   │   └── 📂 widgets
│   │       ├── add_rec_dialog.dart
│   │       ├── user_image_picker.dart
│   │       ├── edit_stock_dialog.dart
│   │       ├── learning_tagpage.dart
│   │       ├── bouncing_arrow.dart
│   │       ├── header_tooltip.dart
│   │       ├── edit_rec_dialog.dart
│   │       ├── custom_button.dart
│   │       └── add_stock_dialog.dart
│   │
│   ├── util.dart
│   ├── firebase_options.dart
│   ├── main.dart
│   └── firebase_api.dart
│
└── 📂 backend
    ├── update_user_recommendations.py
    ├── recommendation.py
    ├── application.py
    ├── utils.py
    ├── db_operations.py
    └── routes.py
```

---

## 🧩 Modules

<details closed><summary>Lib</summary>

| File                                                                                                      | Summary                   |
| ---                                                                                                       | ---                       |
| [util.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/util.dart)                         | Houses globally useful utility methods, aiding in tasks such as data formatting, common validations, and repeated operations, ensuring a DRY (Don't Repeat Yourself) codebase. |
| [firebase_options.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/firebase_options.dart) | Primarily deals with Firebase configurations. This is where you would define setup options, credentials, and other necessary parameters for Firebase services to work seamlessly with your Flutter application. |
| [main.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/main.dart)                         | Acts as the app's beating heart. Here, you'll find the main() method, initial theme and locale setups, and primary app-level configurations. It sets the tone for how the application initializes and runs. |
| [firebase_api.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/firebase_api.dart)         | A dedicated interface for Firebase interactions. Besides setting up notifications, it may handle authentication, Firestore operations, and more, ensuring a clear separation of concerns. |

</details>

<details closed><summary>Providers</summary>

| File                                                                                                                            | Summary                   |
| ---                                                                                                                             | ---                       |
| [tab_provider.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/providers/tab_provider.dart)                     | A state manager that controls and reflects the active state of the main navigation bar. It includes methods for tab selection, maintaining the state of the currently active tab, and emitting changes when a tab is switched. |
| [stock_list_provider.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/providers/stock_list_provider.dart)       | A comprehensive state manager that concerns itself with everything related to the stocks' list, from fetching and storing them to updating or removing them. |
| [stock_filters_provider.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/providers/stock_filters_provider.dart) | As the name suggests, it deals with filtering operations on stocks. This might include the application of various criteria to list stocks based on user choices. |
| [user_provider.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/providers/user_provider.dart)                   | Central to user operations, this file manages user-specific states like login status, user data caching, profile updates, and more. |

</details>

<details closed><summary>Models</summary>

| File                                                                                                                                         | Summary                   |
| ---                                                                                                                                          | ---                       |
| [watchlist_recommendation_model.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/models/watchlist_recommendation_model.dart) | Defines the structure and behavior of recommendations present in a user's watchlist, including attributes such as ticker symbol, target price, etc. |
| [watchlist_stock_model.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/models/watchlist_stock_model.dart)                   | Defines the structure and behavior of the stocks that a user has chosen to watch. Attributes include stock details, etc.  |
| [recommendation_model.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/models/recommendation_model.dart)                     | Defines the general structure for option recommendations. |
| [user_model.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/models/user_model.dart)                                         | Describes the user entity. This encompasses details like username, email, preferences, watchlist, and any other user-specific data. |
| [stock_model.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/models/stock_model.dart)                                       | A blueprint for all things stock-related. This includes stock attributes, behaviors, and potentially methods for fetching or updating stock data. |

</details>

<details closed><summary>Screens</summary>

| File                                                                                                | Summary                   |
| ---                                                                                                 | ---                       |
| [auth.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/auth.dart)           | The gateway to the app, responsible for user registration, login, and perhaps password recovery. |
| [profile.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/profile.dart)     | A personal space for users, detailing their information, preferences, app settings, and offering options to modify these details. |
| [navbar.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/navbar.dart)       | The component ensuring navigation within the app. It sets up and controls the main tabs/buttons and their respective navigation. |
| [splash.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/splash.dart)       | The first visual users experience, indicating the app's loading process. |
| [dashboard.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/dashboard.dart) | A holistic view of the app's primary features, highlighting a user's option recommendations. |
| [learning.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/learning.dart)   | An educational space, offering users insights, tutorials, and guides related to cash secured puts. |
| [stocks.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/screens/stocks.dart)       | A dedicated space to dive deep into stock details, analytics, history, and add these stocks to your watchlist. |

</details>

<details closed><summary>Widgets</summary>

| File                                                                                                                | Summary                   |
| ---                                                                                                                 | ---                       |
| [add_rec_dialog.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/add_rec_dialog.dart)       | A user interface component allowing users to seamlessly add new recommendations to their list. |
| [user_image_picker.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/user_image_picker.dart) | Simplifies the process of users updating or choosing a new profile image. |
| [edit_stock_dialog.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/edit_stock_dialog.dart) | Provides an intuitive interface for users to modify existing stock details. |
| [learning_tagpage.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/learning_tagpage.dart)   | Ctegorizes educational content based on tags, allowing users to navigate through topics of interest. |
| [bouncing_arrow.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/bouncing_arrow.dart)       | A dynamic widget designed to capture user attention. |
| [header_tooltip.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/header_tooltip.dart)       | Provides explanatory or additional information when users hover over or focus on header elements. |
| [edit_rec_dialog.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/edit_rec_dialog.dart)     | A dialog tailored for editing existing stock recommendations, ensuring user ease and clarity. |
| [custom_button.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/custom_button.dart)         | A specialized button, ensuring UI consistency and potentially offering enhanced interactivity. |
| [add_stock_dialog.dart](https://github.com/vvkumar2/csp-bot/blob/main/frontend/lib/widgets/add_stock_dialog.dart)   | Facilitates users in adding new stocks to their watchlist or portfolio. |

</details>

<details closed><summary>Backend</summary>

| File                                                                                                                   | Summary                   |
| ---                                                                                                                    | ---                       |
| [update_user_recommendations.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/update_user_recommendations.py) | A critical script that constantly updates user recommendations. Assessing stock data and current options ensures users always have the most current advice. This script's periodic execution by an AWS server ensures data freshness. |
| [recommendation.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/recommendation.py)                           | Contains the core logic and algorithms for generating stock recommendations, ensuring users receive insights based on reliable computations. |
| [application.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/application.py)                                 | The backbone of the backend, orchestrating the server's behavior, initializing necessary components, and overseeing request handling. |
| [utils.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/utils.py)                                             | An assortment of utility functions that cater to the backend's various needs, be it data transformation, validation, or common operations. |
| [db_operations.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/db_operations.py)                             | A dedicated interface for all database interactions, from creating and reading entries to updating and deleting them. It ensures data integrity and structured database interactions. |
| [routes.py](https://github.com/vvkumar2/csp-bot/blob/main/backend/routes.py)                                           | Lays down the map of the server, defining URL routes, and linking them to their respective request handlers or controllers. |

</details>

---

## 🚀 Getting Started

### ✔️ Prerequisites

Before you begin, ensure that you have the following prerequisites installed:
> `ℹ️ requirements.txt`

### 📦 Installation

1. Clone the csp-bot repository:
```sh
git clone https://github.com/vvkumar2/csp-bot
```

2. Change to the project directory:
```sh
cd csp-bot/frontend
```

3. Install the dependencies:
```sh
pub get
```

### 🎮 Using csp-bot

```sh
flutter emulator --launch <emulator-name>
flutter run
```

---
