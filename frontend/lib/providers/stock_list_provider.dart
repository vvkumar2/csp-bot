import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/dummy_stocks.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/data/sp_stock_data.dart';

// class StockListNotifier extends StateNotifier<List<Stock>> {
//   StockListNotifier() : super(dummyData);

//   void addStock(Stock stock) {
//     state = [...state, stock];
//   }

//   void removeStock(Stock stock) {
//     state = state.where((element) => element.ticker != stock.ticker).toList();
//   }
// }

// final stockListProvider = Provider<List<Stock>>((ref) {
//   return dummyData;
// });

import 'package:http/http.dart' as http;
import 'dart:convert';

const batchSize = 100;

final stockListProvider = FutureProvider<List<Stock>>((ref) async {
  List<Stock> allStocks = [];

  // Assuming you have a list of all SP500 symbols called sp500Symbols
  final batches = splitListIntoChunks(sp500Tickers, batchSize);

  for (var batch in batches) {
    final commaSeparatedSymbols = batch.join(',');
    final url =
        "https://api.tradier.com/v1/markets/quotes?symbols=$commaSeparatedSymbols&greeks=false";
    final headers = {
      'Authorization': 'Bearer PKrgoHZXMmd6UkIewPaZnqn0tNz3',
      'Accept': 'application/json',
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      var quotes = data['quotes']['quote'];

      // If it's a single quote, make sure it's in a list for consistent parsing
      if (quotes is Map) {
        quotes = [quotes];
      }

      for (var quote in quotes) {
        allStocks.add(Stock(
          ticker: quote['symbol'],
          company: quote['description'],
          price: quote['last'],
          oneDayChange: quote['change_percentage'],
          week52High: quote['week_52_high'],
          volume: quote['volume'],
        ));
      }
    } else {
      // Handle the error (you might want to throw an exception or handle it in another way)
      print("Failed to load batch with status code: ${response.statusCode}");
    }
  }

  return allStocks;
});

List<List<T>> splitListIntoChunks<T>(List<T> list, int chunkSize) {
  var chunks = <List<T>>[];
  for (var i = 0; i < list.length; i += chunkSize) {
    chunks.add(list.sublist(
        i, i + chunkSize > list.length ? list.length : i + chunkSize));
  }
  return chunks;
}


// final stockListProvider = FutureProvider<List<Stock>>((ref) async {
//   // List<String> symbols = [...] // List of S&P 500 symbols
//   List<Stock> stocks = [];

//   for (String symbol in sp500Tickers) {
//     final url =
//         "https://api.tradier.com/v1/markets/quotes?symbols=$symbol&greeks=false";
//     final headers = {
//       'Authorization': 'Bearer PKrgoHZXMmd6UkIewPaZnqn0tNz3',
//       'Accept': 'application/json',
//     };

//     final response = await http.get(Uri.parse(url), headers: headers);
//     if (response.statusCode == 200) {
//       var data = json.decode(response.body);

//       if (data.containsKey('quotes') &&
//           data['quotes'].containsKey('unmatched_symbols')) {
//         continue;
//       }

//       final stock = Stock(
//         company: data['quotes']['quote']['description'],
//         ticker: symbol,
//         price: data['quotes']['quote']['last'],
//         oneDayChange: data['quotes']['quote']['change_percentage'],
//         week52High: data['quotes']['quote']['week_52_high'],
//         volume: data['quotes']['quote']['volume'],
//       );
//       stocks.add(stock);
//     }
//     // Handle errors and rate limits appropriately.
//   }
//   print(stocks);
//   return stocks;
// });
