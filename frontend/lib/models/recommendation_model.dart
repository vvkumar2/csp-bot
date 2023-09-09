import 'package:intl/intl.dart';

final inputFormatter = DateFormat('EEE, d MMM yyyy HH:mm:ss');
final outputFormatter = DateFormat('MM/dd');

class Recommendation {
  final String ticker;
  final String expiryDate;
  final double strikePrice;
  final double bidPrice;
  final int optionQuantity;
  final double delta;
  final bool isSold;

  Recommendation(
      {required this.ticker,
      required this.expiryDate,
      required this.strikePrice,
      required this.bidPrice,
      required this.optionQuantity,
      required this.delta,
      required this.isSold});

  factory Recommendation.fromMap(Map<String, dynamic> data) {
    String expiryDateInput = data['expiry_date'] ?? '';
    String formattedExpiryDate;

    // Check if the date is already in 'MM/dd' format
    if (RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDateInput)) {
      formattedExpiryDate = expiryDateInput;
    } else {
      DateTime parsedExpiryDate = inputFormatter.parse(expiryDateInput);
      formattedExpiryDate = outputFormatter.format(parsedExpiryDate);
    }

    return Recommendation(
      ticker: data['ticker'] ?? '',
      expiryDate: formattedExpiryDate,
      strikePrice: double.parse(data['strike_price'].toString()),
      bidPrice: double.parse(data['bid_price'].toString()),
      optionQuantity: int.parse(data['option_quantity'].toString()),
      delta: double.parse(data['delta'].toString()),
      isSold: data['is_sold'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ticker': ticker,
      'expiry_date': expiryDate,
      'strike_price': strikePrice,
      'bid_price': bidPrice,
      'option_quantity': optionQuantity,
      'delta': delta,
      'is_sold': isSold,
    };
  }
}
