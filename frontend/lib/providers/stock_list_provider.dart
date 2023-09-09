import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/dummy_stocks.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/data/sp_stock_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
      'Authorization': 'Bearer ${dotenv.env['TRADIER_API_KEY']}',
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
