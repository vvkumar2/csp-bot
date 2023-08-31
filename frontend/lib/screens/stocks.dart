import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/stock_filters_provider.dart';
import 'package:frontend/providers/stock_list_provider.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/widgets/add_stock_dialog.dart';
import 'package:frontend/util.dart';
import 'package:frontend/screens/splash.dart';

class StockScreen extends ConsumerStatefulWidget {
  const StockScreen({super.key});

  @override
  ConsumerState<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreen> {
  SortOption? _selectedSortOption;

  bool stockExistsInUserList(String ticker, UserModel userData) {
    return userData.stockList.any((map) => map.ticker == ticker);
  }

  Map<String, String> convertToMapStringValues(WatchlistStock obj) {
    Map<String, String> stringMap = {};
    Map<String, dynamic> originalMap = obj.toMap();

    originalMap.forEach((key, value) {
      if (value is double) {
        stringMap[key] = value.toStringAsFixed(2);
      } else {
        stringMap[key] = value.toString();
      }
    });

    return stringMap;
  }

  Future<void> removeStockFromUserList(String ticker, UserModel userData) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    print(convertToMapStringValues(userData.stockList.firstWhere((map) {
      return map.ticker == ticker;
    })));

    return users.doc(userData.uid).update({
      'stock_list': FieldValue.arrayRemove([
        convertToMapStringValues(userData.stockList.firstWhere((map) {
          return map.ticker == ticker;
        }))
      ])
    }).catchError((error) {
      print("Failed to remove stock: $error");
    });
  }

  void sortStocks(filteredStocks, SortOption? option, bool ascending) {
    dynamic getColumnValue(Stock stock, SortOption? option) {
      switch (option) {
        case SortOption.ticker:
          return stock.ticker;
        case SortOption.priceInc:
          return stock.price;
        case SortOption.volumeDec:
          return stock.volume.toDouble();
        case SortOption.oneDayChangeInc:
          return stock.oneDayChange;
        default:
          return stock.ticker;
      }
    }

    filteredStocks.sort((stockA, stockB) {
      final valueA = getColumnValue(stockA, option);
      final valueB = getColumnValue(stockB, option);

      // Compare the values as per their type.
      int comparison;
      if (valueA is String && valueB is String) {
        comparison = valueA.compareTo(valueB);
      } else if (valueA is double && valueB is double) {
        comparison = valueA.compareTo(valueB);
      } else {
        comparison = 0; // Default to considering them equal.
      }

      // Return either the comparison or its inverse based on ascending order.
      if (ascending) {
        return comparison;
      } else {
        return comparison * -1;
      }
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final filteredStocks = ref.watch(filteredStockProvider);
    final userData = ref.watch(userProvider);

    return Theme(
      data: ThemeData(
        dividerColor: const Color(0x4F2E3334),
        iconTheme: const IconThemeData(color: Colors.grey),
      ),
      child: filteredStocks.isEmpty
          ? const Center(child: SplashScreen())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<SortOption>(
                            borderRadius: BorderRadius.circular(10),
                            style: const TextStyle(color: Colors.white),
                            dropdownColor: const Color(0xFF1E1E1E),
                            icon: const Icon(EvaIcons.arrowIosDownwardOutline,
                                color: Colors.white),
                            value: _selectedSortOption,
                            hint: const Text('Sort by',
                                style: TextStyle(color: Colors.white)),
                            items: const <DropdownMenuItem<SortOption>>[
                              DropdownMenuItem<SortOption>(
                                value: SortOption.ticker,
                                child: Text('A-Z'),
                              ),
                              DropdownMenuItem<SortOption>(
                                value: SortOption.priceInc,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Price'),
                                    SizedBox(width: 4),
                                    Icon(
                                      EvaIcons.arrowUpward,
                                      color: Colors.white,
                                      size: 18,
                                    ) // You can adjust the color accordingly
                                  ],
                                ),
                              ),
                              DropdownMenuItem<SortOption>(
                                value: SortOption.volumeDec,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Volume'),
                                    SizedBox(width: 4),
                                    Icon(
                                      EvaIcons.arrowDownward,
                                      color: Colors.white,
                                      size: 18,
                                    ) // You can adjust the color accordingly
                                  ],
                                ),
                              ),
                              DropdownMenuItem<SortOption>(
                                value: SortOption.oneDayChangeInc,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('1D Change'),
                                    SizedBox(width: 4),
                                    Icon(
                                      EvaIcons.arrowDownward,
                                      color: Colors.white,
                                      size: 18,
                                    ) // You can adjust the color accordingly
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (SortOption? newValue) {
                              setState(() {
                                _selectedSortOption = newValue!;
                                if (_selectedSortOption ==
                                    SortOption.volumeDec) {
                                  sortStocks(filteredStocks,
                                      _selectedSortOption, false);
                                } else {
                                  sortStocks(filteredStocks,
                                      _selectedSortOption, true);
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.purple),
                        onPressed: () {
                          ref.refresh(stockListProvider);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: RawScrollbar(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: 600,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding:
                                  EdgeInsets.only(top: 20, left: 60, right: 20),
                              child: Row(
                                children: [
                                  // For example:
                                  SizedBox(
                                      width: 170,
                                      child: Text('Ticker',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold))),

                                  SizedBox(
                                      width: 95,
                                      child: Text('Price',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                      width: 95,
                                      child: Text('Volume',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold))),
                                  SizedBox(
                                      width: 115,
                                      child: Text('52W High',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold))),
                                  Expanded(
                                    child: SizedBox(
                                        width: 115,
                                        child: Text('1D Δ',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold))),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Expanded(
                              child: ListView.builder(
                                itemCount: filteredStocks.length,
                                itemBuilder: (ctx, index) {
                                  final stock = filteredStocks[index];

                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8, left: 20, right: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Icon Data Cell
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 20),
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                child: Icon(
                                                    stockExistsInUserList(
                                                            stock.ticker,
                                                            userData!)
                                                        ? EvaIcons
                                                            .checkmarkCircle2
                                                        : EvaIcons
                                                            .plusCircleOutline,
                                                    size: 24,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                                onTap: () async {
                                                  if (stockExistsInUserList(
                                                      stock.ticker, userData)) {
                                                    removeStockFromUserList(
                                                        stock.ticker, userData);
                                                    final snackBar = SnackBar(
                                                      content: Text(
                                                          'You have removed ${stock.company} from your watchlist'),
                                                      backgroundColor:
                                                          Colors.red.shade400,
                                                      duration: const Duration(
                                                          seconds: 2),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  } else {
                                                    // Add the stock to user's stock list and notify
                                                    await showDialog(
                                                      context: context,
                                                      builder: (context) =>
                                                          AddStockDialog(
                                                        stock: stock,
                                                        addStockToUserList:
                                                            addStockToUserList,
                                                        userData: userData,
                                                        stockExistsInUserList:
                                                            stockExistsInUserList,
                                                        removeStockFromUserList:
                                                            removeStockFromUserList,
                                                      ),
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            // Ticker and Company Name
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(stock.ticker,
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    stock.company,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Price
                                            SizedBox(
                                              width: 95,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${stock.price.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),

                                            // Volume
                                            SizedBox(
                                              width: 95,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '${(stock.volume / 1000000).toStringAsFixed(2)}M',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),

                                            // 52 Week High
                                            SizedBox(
                                              width: 105,
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '\$${stock.week52High.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),

                                            // 1 Day Change
                                            SizedBox(
                                              width: 105,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Icon(
                                                    stock.oneDayChange > 0
                                                        ? Icons.arrow_drop_up
                                                        : Icons.arrow_drop_down,
                                                    color: stock.oneDayChange >
                                                            0
                                                        ? Colors.green.shade400
                                                        : Colors.red.shade400,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '${stock.oneDayChange}%',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        const Divider()
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final filteredStocks = ref.watch(filteredStockProvider);
  //   final userData = ref.watch(userProvider);
  //   // print(filteredStocks);

  //   return Theme(
  //     data: ThemeData(
  //       dividerColor: const Color(0x4F2E3334),
  //       iconTheme: const IconThemeData(color: Colors.grey),
  //     ),
  //     child: RawScrollbar(
  //       child: SingleChildScrollView(
  //         scrollDirection: Axis.vertical,
  //         child: SingleChildScrollView(
  //           padding: const EdgeInsets.only(top: 20),
  //           scrollDirection: Axis.horizontal,
  //           child: DataTable(
  //             columnSpacing: 30,
  //             headingRowHeight: 40,
  //             dataRowMinHeight: 60,
  //             dataRowMaxHeight: 60,
  //             headingRowColor: MaterialStateProperty.all(Colors.transparent),
  //             headingTextStyle: const TextStyle(
  //                 color: Colors.white, fontWeight: FontWeight.bold),
  //             sortAscending: _isAscending,
  //             sortColumnIndex: _sortColumnIndex,
  //             columns: [
  //               const DataColumn(label: Text('')),
  //               DataColumn(
  //                   label: const Text('Ticker',
  //                       style: TextStyle(
  //                           color: Colors.grey, fontWeight: FontWeight.bold)),
  //                   onSort: (int columnIndex, bool ascending) {
  //                     sortStocks(filteredStocks, columnIndex);
  //                   }),
  //               DataColumn(
  //                   label: const Text('Price',
  //                       textAlign: TextAlign.right,
  //                       style: TextStyle(
  //                           color: Colors.grey, fontWeight: FontWeight.bold)),
  //                   onSort: (int columnIndex, bool ascending) {
  //                     sortStocks(filteredStocks, columnIndex);
  //                   }),
  //               DataColumn(
  //                   label: const Text('Volume',
  //                       style: TextStyle(
  //                           color: Colors.grey, fontWeight: FontWeight.bold)),
  //                   onSort: (int columnIndex, bool ascending) {
  //                     sortStocks(filteredStocks, columnIndex);
  //                   }),
  //               DataColumn(
  //                   label: const Text('52 Week High',
  //                       style: TextStyle(
  //                           color: Colors.grey, fontWeight: FontWeight.bold)),
  //                   onSort: (int columnIndex, bool ascending) {
  //                     sortStocks(filteredStocks, columnIndex);
  //                   }),
  //               DataColumn(
  //                   label: const Text('1 Day Change',
  //                       style: TextStyle(
  //                           color: Colors.grey, fontWeight: FontWeight.bold)),
  //                   onSort: (int columnIndex, bool ascending) {
  //                     sortStocks(filteredStocks, columnIndex);
  //                   }),
  //             ],
  //             rows: filteredStocks
  //                 .map((stock) => DataRow(cells: [
  //                       DataCell(
  // InkWell(
  //   borderRadius: BorderRadius.circular(50),
  //   child: Icon(
  //       stockExistsInUserList(stock.ticker, userData!)
  //           ? EvaIcons.checkmarkCircle2
  //           : EvaIcons.plusCircleOutline,
  //       size: 24,
  //       color: Theme.of(context).colorScheme.primary),
  //   onTap: () async {
  //     if (stockExistsInUserList(
  //         stock.ticker, userData)) {
  //       // Remove the stock from user's stock list and notify
  //       print("REMOVE: ");
  //       print(stock.ticker);
  //       removeStockFromUserList(stock.ticker, userData);
  //       final snackBar = SnackBar(
  //         content: Text(
  //             'You have removed ${stock.company} from your watchlist'),
  //         backgroundColor: Colors.red.shade400,
  //         duration: const Duration(seconds: 2),
  //       );
  //       ScaffoldMessenger.of(context)
  //           .showSnackBar(snackBar);
  //     } else {
  //       // Add the stock to user's stock list and notify
  //       await showDialog(
  //         context: context,
  //         builder: (context) => AddStockDialog(
  //           stock: stock,
  //           addStockToUserList: addStockToUserList,
  //           userData: userData,
  //           stockExistsInUserList:
  //               stockExistsInUserList,
  //           removeStockFromUserList:
  //               removeStockFromUserList,
  //         ),
  //       );
  //     }
  //   },
  // ),
  //                       ),
  //                       DataCell(Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Text(stock.ticker,
  //                               style: const TextStyle(color: Colors.white)),
  //                           const SizedBox(height: 5),
  //                           Text(stock.company,
  //                               style: const TextStyle(
  //                                   fontSize: 12, color: Colors.grey)),
  //                         ],
  //                       )),
  //                       DataCell(SizedBox(
  //                         width: 65,
  //                         child: Align(
  //                           alignment: Alignment.centerRight,
  //                           child: Text('\$${stock.price.toStringAsFixed(2)}',
  //                               style: const TextStyle(color: Colors.white)),
  //                         ),
  //                       )),
  //                       DataCell(SizedBox(
  //                         width: 60,
  //                         child: Align(
  //                           alignment: Alignment.centerRight,
  //                           child: Text(
  //                               '${(stock.volume / 1000000).toStringAsFixed(2)}M',
  //                               style: const TextStyle(color: Colors.white)),
  //                         ),
  //                       )),
  //                       DataCell(SizedBox(
  //                         width: 95,
  //                         child: Align(
  //                           alignment: Alignment.centerRight,
  //                           child: Text(
  //                               '\$${stock.week52High.toStringAsFixed(2)}',
  //                               style: const TextStyle(color: Colors.white)),
  //                         ),
  //                       )),
  //                       DataCell(
  //                         SizedBox(
  //                           width: 95,
  //                           child: Align(
  //                             alignment: Alignment.centerRight,
  //                             child: Row(
  //                               mainAxisSize: MainAxisSize.min,
  //                               children: [
  //                                 Icon(
  //                                   stock.oneDayChange > 0
  //                                       ? Icons.arrow_drop_up
  //                                       : Icons.arrow_drop_down,
  //                                   color: stock.oneDayChange > 0
  //                                       ? Colors.green.shade400
  //                                       : Colors.red.shade400,
  //                                 ),
  //                                 const SizedBox(width: 3),
  //                                 Text(
  //                                   '${stock.oneDayChange}%',
  //                                   style: const TextStyle(color: Colors.white),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ]))
  //                 .toList(),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
