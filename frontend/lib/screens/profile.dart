import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/watchlist_recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/widgets/edit_rec_dialog.dart';
import 'package:frontend/widgets/edit_stock_dialog.dart';
import 'package:frontend/util.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _activeTab = 0;

  @override
  Widget build(BuildContext context) {
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
                      text: user.recommendationsUsed.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  TextSpan(
                      text: ' Recommendations Used',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _activeTab = 0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeTab == 0
                          ? Theme.of(context).colorScheme.primary
                          : const Color.fromARGB(255, 22, 22, 23),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _activeTab == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade800),
                    ),
                    child: Text(
                      'My Options',
                      style: TextStyle(
                        color: _activeTab == 0
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    setState(() {
                      _activeTab = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 10),
                    decoration: BoxDecoration(
                      color: _activeTab == 1
                          ? Theme.of(context).colorScheme.primary
                          : const Color.fromARGB(255, 22, 22, 23),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _activeTab == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade800),
                    ),
                    child: Text(
                      'My Stocks',
                      style: TextStyle(
                        color: _activeTab == 1
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _activeTab == 0
                ? Expanded(
                    child: user.addedRecommendationList.isEmpty
                        ? const Center(
                            child: Text(
                              'No options in watchlist, add some!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _buildOptionsTab(user),
                  )
                : Expanded(
                    child: user.stockList.isEmpty
                        ? const Center(
                            child: Text(
                              'No stocks in watchlist, add some!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : _buildStocksTab(user),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsTab(UserModel user) {
    return RawScrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 30,
            headingRowHeight: 40,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('')),
              DataColumn(
                  label: Text('Ticker',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Strike',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Buy Back?',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Bid',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Quant.',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Expiry',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
            ],
            rows: user.addedRecommendationList
                .map((WatchlistRecommendation recommendation) {
              return DataRow(cells: [
                DataCell(
                  InkWell(
                      child: const Icon(Icons.edit, color: Colors.purple),
                      onTap: () async {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return EditRecDialog(
                                  recommendation: recommendation,
                                  addRecToUserList: addRecToUserList);
                            });
                      }),
                ),
                DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(recommendation.ticker,
                      style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(recommendation.strikePrice.toString(),
                      style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                          recommendation.isSold && !recommendation.isExpired
                              ? 'Yes'
                              : recommendation.isExpired
                                  ? 'Expired'
                                  : 'No',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(
                        recommendation.isSold && !recommendation.isExpired
                            ? '${recommendation.profitLoss.toStringAsFixed(2)}%'
                            : '-',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: recommendation.profitLoss < 0
                                ? const Color.fromARGB(255, 175, 76, 76)
                                : recommendation.profitLoss > 0
                                    ? const Color.fromARGB(255, 76, 175, 76)
                                    : Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  // child: Text(recommendation.isSold ? 'Yes' : 'No',
                  //     style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text(recommendation.bidPrice.toString(),
                      style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text(recommendation.optionQuantity.toString(),
                      style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text(recommendation.expiryDate,
                      style: const TextStyle(color: Colors.white)),
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildStocksTab(UserModel user) {
    return RawScrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 30,
            headingRowHeight: 40,
            dataRowMinHeight: 60,
            dataRowMaxHeight: 60,
            headingRowColor: MaterialStateProperty.all(Colors.transparent),
            columns: const [
              DataColumn(label: Text('')),
              DataColumn(
                  label: Text('Ticker',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Max Price',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Max Collateral',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Strategy',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold))),
            ],
            rows: user.stockList.map((WatchlistStock stock) {
              print(stock.ticker);
              return DataRow(cells: [
                DataCell(
                  InkWell(
                      child: const Icon(Icons.edit, color: Colors.purple),
                      onTap: () async {
                        await showDialog(
                            context: context,
                            builder: (context) {
                              return EditStockDialog(
                                  stock: stock,
                                  addStockToUserList: addStockToUserList);
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
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                )),
                DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text('\$${stock.maxPrice.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white)),
                )),
                DataCell(Align(
                  alignment: Alignment.centerRight,
                  child: Text('\$${stock.maxHoldings.toStringAsFixed(0)}',
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
    );
  }
}
