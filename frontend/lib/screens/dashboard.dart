import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/util.dart';
import 'package:frontend/widgets/add_rec_dialog.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeTabButton = 0;
  int _activeStockButton = -1;

  @override
  Widget build(BuildContext context) {
    final watchlistStockList = ref.watch(userProvider)!.stockList;
    final recommendationList = ref.watch(userProvider)!.recommendationList;
    final addedRecommendationList =
        ref.watch(userProvider)!.addedRecommendationList;
    List<Recommendation> activeRecommendations = recommendationList.isEmpty
        ? []
        : recommendationList.where((recommendation) {
            if (_activeStockButton == -1) {
              return true;
            }
            return recommendation.ticker ==
                watchlistStockList[_activeStockButton].ticker;
          }).toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: watchlistStockList.isEmpty
                    ? [
                        _buildAllButton(),
                      ]
                    : [
                        _buildAllButton(),
                        const SizedBox(width: 10),
                        ...watchlistStockList
                            .expand((WatchlistStock watchlistStock) {
                          return [
                            _buildRecommendationButton(watchlistStock,
                                watchlistStockList.indexOf(watchlistStock)),
                            const SizedBox(width: 10),
                          ];
                        }).toList()
                          ..removeLast(),
                      ]),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: activeRecommendations.isEmpty && watchlistStockList.isEmpty
                ? const Center(
                    child: Text(
                      "Add a stock to your watchlist to get recommendations",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : activeRecommendations.isEmpty
                    ? const Center(
                        child: Text(
                          "More recommendations brewing. Stay tuned!",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: activeRecommendations.length,
                        itemBuilder: (ctx_1, index) {
                          Recommendation recommendation =
                              activeRecommendations[index];
                          String tickerString = (_activeStockButton == -1)
                              ? "${recommendation.ticker} "
                              : "";

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$tickerString\$${recommendation.strikePrice.toStringAsFixed(2)} Put - ${recommendation.expiryDate.toString()}',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text('Quantity',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  recommendation.optionQuantity
                                                      .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Text('Delta',
                                                  style: TextStyle(
                                                      color: Colors.grey)),
                                              const SizedBox(height: 4),
                                              Text(
                                                  recommendation.delta
                                                      .toStringAsFixed(2),
                                                  style: const TextStyle(
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(50),
                                        onTap: () async {
                                          if (recommendation.isSold == true) {
                                            // show a snackbar
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Recommendation already sold'),
                                                duration: Duration(seconds: 1),
                                              ),
                                            );
                                            return;
                                          }
                                          await showDialog(
                                            context: context,
                                            builder: (ctx_2) => AddRecDialog(
                                                recommendation: recommendation,
                                                addRecToUserList:
                                                    addRecToUserList,
                                                setRecToSold: setRecToSold),
                                          );
                                        },
                                        child: Icon(
                                          EvaIcons.checkmarkCircle2Outline,
                                          color: recommendation.isSold == true
                                              ? Colors.green
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Container(
                                        width: 80,
                                        height: 40,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          color: const Color.fromRGBO(
                                              52, 219, 77, 0.872),
                                        ),
                                        child: Text(
                                          '\$${recommendation.bidPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              const Divider(
                                  color: Color.fromARGB(255, 52, 52, 52)),
                              const SizedBox(height: 15)
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _activeTabButton = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _activeTabButton == index
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 22, 22, 23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _activeTabButton == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: _activeTabButton == index
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAllButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _activeStockButton = -1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _activeStockButton == -1
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 22, 22, 23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _activeStockButton == -1
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800),
        ),
        child: Text(
          'All',
          style: TextStyle(
            color: _activeStockButton == -1
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationButton(WatchlistStock watchlistStock, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _activeStockButton = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _activeStockButton == index
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 22, 22, 23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _activeStockButton == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800),
        ),
        child: Text(
          watchlistStock.ticker,
          style: TextStyle(
            color: _activeStockButton == index
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
