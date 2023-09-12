import 'package:intl/intl.dart';

final inputFormatter = DateFormat('EEE, d MMM yyyy HH:mm:ss');
final outputFormatter = DateFormat('MM/dd');

class WatchlistRecommendation {
  final String ticker;
  final String expiryDate;
  final double strikePrice;
  final double bidPrice;
  final int optionQuantity;
  final double delta;
  final bool isSold;
  final bool isExpired;
  final String expirationStatus;
  final double profitLoss;

  WatchlistRecommendation({
    required this.ticker,
    required this.expiryDate,
    required this.strikePrice,
    required this.bidPrice,
    required this.optionQuantity,
    required this.delta,
    required this.isSold,
    this.isExpired = false,
    this.expirationStatus = '',
    this.profitLoss = 0.0,
  });

  factory WatchlistRecommendation.fromMap(Map<String, dynamic> data) {
    String expiryDateInput = data['expiry_date'] ?? '';
    String formattedExpiryDate;

    // Check if the date is already in 'MM/dd' format
    if (RegExp(r'^\d{2}/\d{2}$').hasMatch(expiryDateInput)) {
      formattedExpiryDate = expiryDateInput;
    } else {
      DateTime parsedExpiryDate = inputFormatter.parse(expiryDateInput);
      formattedExpiryDate = outputFormatter.format(parsedExpiryDate);
    }

    return WatchlistRecommendation(
      ticker: data['ticker'] ?? '',
      expiryDate: formattedExpiryDate,
      strikePrice: double.parse(data['strike_price'].toString()),
      bidPrice: double.parse(data['bid_price'].toString()),
      optionQuantity: int.parse(data['option_quantity'].toString()),
      delta: double.parse(data['delta'].toString()),
      isSold: data['is_sold'] ?? false,
      isExpired: data['is_expired'] ?? false,
      expirationStatus: data['expiration_status'] ?? '',
      profitLoss: double.parse(data['profit_loss'].toString()),
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
      'is_expired': isExpired,
      'expiration_status': expirationStatus,
      'profit_loss': profitLoss,
    };
  }
}
