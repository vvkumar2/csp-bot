import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/user_provider.dart';

Future<void> addStockToUserList(
  String ticker,
  String company,
  String delta,
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
      'delta': delta,
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

    // return users.doc(userData.uid).update({
    //   'stock_list': FieldValue.arrayUnion([
    //     {
    //       'ticker': ticker,
    //       'company': company,
    //       'delta': delta,
    //       'max_holdings': maxHoldings,
    //       'max_price': maxPrice,
    //       'strategy': strategy,
    //     }
    //   ])
    // }).catchError((error) {
    //   print("Failed to add stock: $error");
    // });
  }
}
