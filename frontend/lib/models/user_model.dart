// UserModel definition
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  final List<WatchlistStock> stockList;
  final List<Recommendation> recommendationList;
  final List<Recommendation> addedRecommendationList;

  UserModel(
      {required this.uid,
      required this.username,
      required this.email,
      required this.imageUrl,
      required this.stockList,
      required this.recommendationList,
      required this.addedRecommendationList});

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    var stockList = (data['stock_list'] as List? ?? [])
        .map((stockData) => WatchlistStock.fromMap(stockData))
        .toList();
    var recommendationList = (data['recommendations_list'] as List? ?? [])
        .map((recommendationData) => Recommendation.fromMap(recommendationData))
        .toList();
    var addedRecommendationList = (data['added_recommendations_list']
                as List? ??
            [])
        .map((recommendationData) => Recommendation.fromMap(recommendationData))
        .toList();

    // print all values in stockList
    recommendationList.forEach((element) {
      print(element.ticker);
      print(element.bidPrice);
    });

    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
      stockList: stockList,
      recommendationList: recommendationList,
      addedRecommendationList: addedRecommendationList,
    );
  }
}
