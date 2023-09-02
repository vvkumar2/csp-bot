import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'dart:convert'; // for json.decode
import 'package:http/http.dart' as http;

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeButton = -1;

  @override
  Widget build(BuildContext context) {
    final watchlistStockList = ref.watch(userProvider)!.stockList;
    final recommendationList = ref.watch(userProvider)!.recommendationList;
    List<Recommendation> activeRecommendations = recommendationList.isEmpty
        ? []
        : recommendationList.where((recommendation) {
            if (_activeButton == -1) {
              return true;
            }
            return recommendation.ticker ==
                watchlistStockList[_activeButton].ticker;
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
                : recommendationList.isEmpty
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
                        itemBuilder: (context, index) {
                          Recommendation recommendation =
                              activeRecommendations[index];

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
                                        '\$${recommendation.strikePrice.toStringAsFixed(2)} Put - ${recommendation.expiryDate.toString()}',
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
                                  Container(
                                    width: 80,
                                    height: 40,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
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

  Widget _buildAllButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() {
          _activeButton = -1;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _activeButton == -1
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 22, 22, 23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _activeButton == -1
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800),
        ),
        child: Text(
          'All',
          style: TextStyle(
            color: _activeButton == -1
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
          _activeButton = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: _activeButton == index
              ? Theme.of(context).colorScheme.primary
              : const Color.fromARGB(255, 22, 22, 23),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: _activeButton == index
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey.shade800),
        ),
        child: Text(
          watchlistStock.ticker,
          style: TextStyle(
            color: _activeButton == index
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
