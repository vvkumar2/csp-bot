import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/widgets/edit_stock_dialog.dart';
import 'package:frontend/util.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return Theme(
      data: ThemeData(
        dividerColor: const Color(0x4F2E3334),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: NetworkImage(user!.imageUrl),
            ),
            const SizedBox(height: 20),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: '121',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  TextSpan(
                      text: ' Recommendations Received',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Watchlist',
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RawScrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 30,
                      headingRowHeight: 40,
                      dataRowMinHeight: 60,
                      dataRowMaxHeight: 60,
                      headingRowColor:
                          MaterialStateProperty.all(Colors.transparent),
                      columns: const [
                        DataColumn(label: Text('')),
                        DataColumn(
                            label: Text('Ticker',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Delta',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Max Price',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Max Collateral',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                        DataColumn(
                            label: Text('Strategy',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold))),
                      ],
                      rows: user.stockList.map((WatchlistStock stock) {
                        return DataRow(cells: [
                          DataCell(
                            InkWell(
                                child: const Icon(Icons.edit,
                                    color: Colors.purple),
                                onTap: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditStockDialog(
                                            stock: stock,
                                            addStockToUserList:
                                                addStockToUserList);
                                      });
                                }),
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
                            child: Text(stock.delta.toStringAsFixed(2),
                                style: const TextStyle(color: Colors.white)),
                          )),
                          DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                '\$${stock.maxPrice.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.white)),
                          )),
                          DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                                '\$${stock.maxHoldings.toStringAsFixed(0)}',
                                style: const TextStyle(color: Colors.white)),
                          )),
                          DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(stock.strategy,
                                style: const TextStyle(color: Colors.white)),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
