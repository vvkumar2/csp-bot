import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/dummy_stocks.dart';
import 'package:frontend/models/stock_model.dart';

final stockListProvider = Provider<List<Stock>>((ref) {
  return dummyData;
});
