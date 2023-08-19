import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/dummy_stocks.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/providers/stock_filters_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/widgets/add_stock_dialog.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  Future<void> addStockToUserList(
    String ticker,
    String company,
    String delta,
    String maxHoldings,
    String maxPrice,
    String strategy,
  ) async {
    final userData = ref.read(userProvider);

    if (userData != null) {
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      return users.doc(userData.uid).update({
        'stock_list': FieldValue.arrayUnion([
          {
            'ticker': ticker,
            'company': company,
            'delta': delta,
            'max_holdings': maxHoldings,
            'max_price': maxPrice,
            'strategy': strategy,
          }
        ])
      }).catchError((error) {
        print("Failed to add stock: $error");
      });
    }
  }

  bool stockExistsInUserList(String ticker, UserModel userData) {
    return userData.stockList.any((map) => map['ticker'] == ticker);
  }

  Future<void> removeStockFromUserList(String ticker, UserModel userData) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return users.doc(userData.uid).update({
      'stock_list': FieldValue.arrayRemove(
          [userData.stockList.firstWhere((map) => map['ticker'] == ticker)])
    }).catchError((error) {
      print("Failed to remove stock: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = ref.watch(filteredStockProvider);
    final userData = ref.watch(userProvider);

    return Theme(
      data: ThemeData(
        dividerColor: const Color(0x4F2E3334),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 20),
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowHeight: 40,
          dataRowMinHeight: 60,
          dataRowMaxHeight: 60,
          columns: const [
            DataColumn(label: Text('')),
            DataColumn(
                label: Text('Ticker',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Price',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Volume',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('52 Week High',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('1 Day Change',
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold))),
          ],
          rows: filteredStocks
              .map((stock) => DataRow(cells: [
                    DataCell(
                      InkWell(
                        borderRadius: BorderRadius.circular(50),
                        child: Icon(
                            stockExistsInUserList(stock.ticker, userData!)
                                ? EvaIcons.checkmarkCircle2
                                : EvaIcons.plusCircleOutline,
                            size: 24,
                            color: Theme.of(context).colorScheme.primary),
                        onTap: () async {
                          if (stockExistsInUserList(stock.ticker, userData)) {
                            // Remove the stock from user's stock list and notify
                            removeStockFromUserList(stock.ticker, userData);
                            final snackBar = SnackBar(
                              content: Text(
                                  'You have removed ${stock.company} from your watchlist'),
                              backgroundColor: Colors.red.shade400,
                              duration: const Duration(seconds: 2),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          } else {
                            // Add the stock to user's stock list and notify
                            await showDialog(
                              context: context,
                              builder: (context) => AddStockDialog(
                                stock: stock,
                                addStockToUserList: addStockToUserList,
                                userData: userData,
                                stockExistsInUserList: stockExistsInUserList,
                                removeStockFromUserList:
                                    removeStockFromUserList,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    DataCell(Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(stock.ticker,
                            style: const TextStyle(color: Colors.white)),
                        const SizedBox(height: 5),
                        Text(stock.company,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    )),
                    DataCell(Align(
                      alignment: Alignment.centerRight,
                      child: Text('\$${stock.price.toString()}',
                          style: const TextStyle(color: Colors.white)),
                    )),
                    DataCell(Align(
                      alignment: Alignment.centerRight,
                      child: Text('${(stock.volume / 1000000).toString()}M',
                          style: const TextStyle(color: Colors.white)),
                    )),
                    DataCell(Align(
                      alignment: Alignment.centerRight,
                      child: Text('\$${stock.week52High.toString()}',
                          style: const TextStyle(color: Colors.white)),
                    )),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              stock.oneDayChange > 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: stock.oneDayChange > 0
                                  ? Colors.green.shade400
                                  : Colors.red.shade400,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '${stock.oneDayChange}%',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]))
              .toList(),
        ),
      ),
    );
  }
}
