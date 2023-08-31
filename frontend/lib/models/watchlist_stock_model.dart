class WatchlistStock {
  final String company;
  final String ticker;
  final double delta;
  final double maxHoldings;
  final double maxPrice;
  final String strategy;

  WatchlistStock(
      {required this.company,
      required this.ticker,
      required this.delta,
      required this.maxHoldings,
      required this.maxPrice,
      required this.strategy});

  factory WatchlistStock.fromMap(Map<String, dynamic> data) {
    return WatchlistStock(
      company: data['company'] ?? '',
      ticker: data['ticker'] ?? '',
      delta: double.parse(data['delta'].toString()),
      maxHoldings: double.parse(data['max_holdings'].toString()),
      maxPrice: double.parse(data['max_price'].toString()),
      strategy: data['strategy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company': company,
      'delta': delta,
      'max_holdings': maxHoldings,
      'max_price': maxPrice,
      'strategy': strategy,
      'ticker': ticker
    };
  }
}
