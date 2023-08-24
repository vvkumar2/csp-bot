import 'package:intl/intl.dart';

class Recommendation {
  final String ticker;
  final String expiryDate;
  final double strikePrice;
  final double bidPrice;
  final int optionQuantity;
  final double delta;

  Recommendation(
      {required this.ticker,
      required this.expiryDate,
      required this.strikePrice,
      required this.bidPrice,
      required this.optionQuantity,
      required this.delta});

  factory Recommendation.fromMap(Map<String, dynamic> data) {
    return Recommendation(
      ticker: data['ticker'] ?? '',
      expiryDate: DateFormat('MM/dd').format(data['expiry_date'].toDate()),
      strikePrice: double.parse(data['strike_price'].toString()),
      bidPrice: double.parse(data['bid_price'].toString()),
      optionQuantity: int.parse(data['option_quantity'].toString()),
      delta: double.parse(data['delta'].toString()),
    );
  }
}
