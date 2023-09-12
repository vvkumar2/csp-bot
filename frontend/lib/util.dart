import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_recommendation_model.dart';
import 'package:frontend/providers/user_provider.dart';

Future<void> addStockToUserList(
  String ticker,
  String company,
  String maxHoldings,
  String maxPrice,
  String strategy,
  WidgetRef ref,
) async {
  final userData = ref.read(userProvider);

  if (userData != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    DocumentSnapshot doc = await users.doc(userData.uid).get();

    if (!doc.exists) {
      print("Document does not exist!");
      return;
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List stockList = data['stock_list'] ?? [];

    // Check if stock with ticker already exists
    int index = stockList.indexWhere((stock) => stock['ticker'] == ticker);

    Map<String, String> newStockData = {
      'ticker': ticker,
      'company': company,
      'max_holdings': maxHoldings,
      'max_price': maxPrice,
      'strategy': strategy,
    };

    if (index != -1) {
      // Update existing stock data
      stockList[index] = newStockData;
    } else {
      // Add new stock data
      stockList.add(newStockData);
    }

    // Update the Firestore document
    return users
        .doc(userData.uid)
        .update({'stock_list': stockList}).catchError((error) {
      print("Failed to add/update stock: $error");
    });
  }
}

Future<void> addRecToUserList(
  WatchlistRecommendation recommendation,
  WidgetRef ref,
) async {
  final userData = ref.read(userProvider);

  if (userData != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    DocumentSnapshot doc = await users.doc(userData.uid).get();

    if (!doc.exists) {
      print("Document does not exist!");
      return;
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List recList = data['added_recommendations_list'] ?? [];

    // Check if recommendation with ticker and expiry date already exists
    int index = recList.indexWhere((rec) {
      return rec['ticker'] == recommendation.ticker &&
          rec['expiry_date'] == recommendation.expiryDate &&
          rec['strike_price'] == recommendation.strikePrice &&
          rec['delta'] == recommendation.delta;
    });

    Map<String, dynamic> newRecData = {
      'ticker': recommendation.ticker,
      'expiry_date': recommendation.expiryDate,
      'strike_price': recommendation.strikePrice,
      'bid_price': recommendation.bidPrice,
      'option_quantity': recommendation.optionQuantity,
      'delta': recommendation.delta,
      'is_sold': false,
      'is_expired': false,
      'expiration_status': '',
      'profit_loss': 0.0,
    };

    if (index != -1) {
      recList[index] = newRecData;
    } else {
      // Add new recommendation data
      recList.add(newRecData);
      try {
        await users
            .doc(userData.uid)
            .update({'recommendations_used': FieldValue.increment(1)});
      } catch (e) {
        print("Failed to add/update recommendation: $e");
      }
    }

    // Update the Firestore document
    try {
      await users
          .doc(userData.uid)
          .update({'added_recommendations_list': recList});
    } catch (e) {
      print("Failed to add/update recommendation: $e");
    }
  }
}

Future<void> setRecToSold(
  Recommendation recommendation,
  WidgetRef ref,
) async {
  final userData = ref.read(userProvider);

  if (userData != null) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    DocumentSnapshot doc = await users.doc(userData.uid).get();

    if (!doc.exists) {
      print("Document does not exist!");
      return;
    }

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List recList = data['recommendations_list'] ?? [];

    int index = recList.indexWhere((rec) {
      Recommendation recObj = Recommendation.fromMap(rec);
      return recObj.ticker == recommendation.ticker &&
          recObj.expiryDate == recommendation.expiryDate &&
          recObj.strikePrice == recommendation.strikePrice &&
          recObj.delta == recommendation.delta;
    });

    Map<String, dynamic> newRecData = {
      'ticker': recommendation.ticker,
      'expiry_date': recommendation.expiryDate,
      'strike_price': recommendation.strikePrice,
      'bid_price': recommendation.bidPrice,
      'option_quantity': recommendation.optionQuantity,
      'delta': recommendation.delta,
      'is_sold': true,
    };

    if (index != -1) {
      recList[index] = newRecData;
    } else {
      // Add new recommendation data
      recList.add(newRecData);
    }

    // Update the Firestore document
    return users
        .doc(userData.uid)
        .update({'recommendations_list': recList}).catchError((error) {
      print("Failed to add/update recommendation: $error");
    });
  }
}
