class Stock {
  final String company;
  final String ticker;
  final double price;
  final int volume;
  final double week52High;
  final double oneDayChange;

  Stock(
      {required this.company,
      required this.ticker,
      required this.price,
      required this.volume,
      required this.week52High,
      required this.oneDayChange});
}
