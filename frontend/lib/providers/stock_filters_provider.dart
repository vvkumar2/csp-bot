import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/stock_model.dart';
import 'package:frontend/providers/stock_list_provider.dart';

enum Filter { search }

final kInitialFilters = {
  Filter.search: '',
};

enum SortOption { ticker, priceInc, volumeDec, oneDayChangeInc }

class FiltersNotifiter extends StateNotifier<Map<Filter, dynamic>> {
  FiltersNotifiter() : super(kInitialFilters);

  void resetFilters() {
    state = kInitialFilters;
  }

  void setFilter(Filter filter, dynamic value) {
    state = {
      ...state,
      filter: value,
    };
  }

  void setAllFilters(Map<Filter, dynamic> filters) {
    state = filters;
  }
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifiter, Map<Filter, dynamic>>(
  (ref) => FiltersNotifiter(),
);

final filteredStockProvider = Provider<List<Stock>>((ref) {
  final stocks = ref.watch(stockListProvider);
  final filters = ref.watch(filtersProvider);
  final search = filters[Filter.search] as String;

  return stocks.maybeWhen(
    data: (stocks) {
      return stocks.where((stock) {
        return stock.ticker.toLowerCase().contains(search.toLowerCase()) ||
            stock.company.toLowerCase().contains(search.toLowerCase());
      }).toList();
    },
    loading: () {
      print('Loading');
      return List.empty();
    }, // You can return null or a placeholder list for loading
    error: (_, __) {
      print(_);
      return List.empty();
    },
    orElse: () {
      print('Or else');
      return List.empty();
    },
  );

  // }
});
