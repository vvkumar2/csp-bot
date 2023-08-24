import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';
import 'package:frontend/providers/user_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _activeButton = 0;

  @override
  Widget build(BuildContext context) {
    final watchlistStockList = ref.watch(userProvider)!.stockList;
    final recommendationList = ref.watch(userProvider)!.recommendationList;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  watchlistStockList.expand((WatchlistStock watchlistStock) {
                return [
                  _buildRecommendationButton(watchlistStock,
                      watchlistStockList.indexOf(watchlistStock)),
                  const SizedBox(width: 10),
                ];
              }).toList()
                    ..removeLast(),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView.builder(
              itemCount: recommendationList.length,
              itemBuilder: (context, index) {
                Recommendation recommendation = recommendationList[index];

                if (recommendation.ticker !=
                    watchlistStockList[_activeButton].ticker) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\$${recommendation.strikePrice.toStringAsFixed(2)} Put ${recommendation.expiryDate.toString()}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Quantity',
                                        style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 2),
                                    Text(
                                        recommendation.optionQuantity
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.white)),
                                  ],
                                ),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Delta',
                                        style: TextStyle(color: Colors.grey)),
                                    const SizedBox(height: 5),
                                    Text(
                                        recommendation.delta.toStringAsFixed(2),
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
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.green,
                          ),
                          child: Text(
                            recommendation.bidPrice.toStringAsFixed(2),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color.fromARGB(255, 52, 52, 52)),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRecommendationButton(WatchlistStock watchlistStock, int index) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
              : const Color.fromARGB(255, 41, 39, 39),
          borderRadius: BorderRadius.circular(20),
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
