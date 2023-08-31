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

  void printStockInfo() async {
    final url =
        "https://api.tradier.com/v1/markets/quotes?symbols=AAPL&greeks=false";
    final headers = {
      'Authorization': 'Bearer PKrgoHZXMmd6UkIewPaZnqn0tNz3',
      'Accept': 'application/json',
    };

    final response = await http.get(
        Uri.parse(
            'https://api.tradier.com/v1/markets/quotes?symbols=MMM,AOS,ABT,ABBV,ABMD,ACN,ATVI,ADM,ADBE,AAP,AMD,AES,AFL,A,APD,AKAM,ALB&greeks=false'),
        headers: headers);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var quotes = data['quotes']['quote'];

      // If it's a single quote, make sure it's in a list for consistent parsing
      if (quotes is Map) {
        quotes = [quotes];
      }

      for (var quote in quotes) {
        print(quote);
      }
    } else {
      // Handle error
      print("Failed to load data with status code: ${response.statusCode}");
    }

    // YahooFinanceResponse response =
    //     await YahooFinanceDailyReader().getDailyDTOs('GOOG');
    // print(response.candlesData[response.candlesData.length - 1].date);
    // StockInfo info = yfin.getStockInfo(ticker: 'msft');
    // StockQuote price = await yfin.getPrice(stockInfo: info);
    // print(price);

    // StockMeta meta = await yfin.getMetaData("SOFI");
    // print(meta);
    // StockChart chart = await yfin.getChartQuotes(
    //     stockHistory: hist,
    //     interval: StockInterval.oneDay,
    //     period: StockRange.fiveYear);

    // print(chart.chartQuotes!.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    final watchlistStockList = ref.watch(userProvider)!.stockList;
    final recommendationList = ref.watch(userProvider)!.recommendationList;
    List<Recommendation> activeRecommendations =
        recommendationList.where((recommendation) {
      if (_activeButton == -1) {
        return true;
      }
      return recommendation.ticker == watchlistStockList[_activeButton].ticker;
    }).toList();
    print(activeRecommendations);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _buildAllButton(),
              const SizedBox(width: 10),
              ...watchlistStockList.expand((WatchlistStock watchlistStock) {
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
            child: activeRecommendations.isEmpty
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                  color:
                                      const Color.fromRGBO(52, 219, 77, 0.872),
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
                          const Divider(color: Color.fromARGB(255, 52, 52, 52)),
                          const SizedBox(height: 15)
                        ],
                      );
                    },
                  ),
          ),
          TextButton(
            onPressed: () {
              printStockInfo();
            },
            child: const Text("Print Stock Info"),
          )
        ],
      ),
    );
  }

  Widget _buildAllButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
              : const Color.fromARGB(255, 41, 39, 39),
          borderRadius: BorderRadius.circular(20),
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
