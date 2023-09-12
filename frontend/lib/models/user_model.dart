// UserModel definition
import 'package:frontend/models/recommendation_model.dart';
import 'package:frontend/models/watchlist_recommendation_model.dart';
import 'package:frontend/models/watchlist_stock_model.dart';

class UserModel {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  final List<WatchlistStock> stockList;
  final List<Recommendation> recommendationList;
  final List<WatchlistRecommendation> addedRecommendationList;
  final int recommendationsUsed;

  UserModel(
      {required this.uid,
      required this.username,
      required this.email,
      required this.imageUrl,
      required this.stockList,
      required this.recommendationList,
      required this.addedRecommendationList,
      required this.recommendationsUsed});

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    var stockList = (data['stock_list'] as List? ?? [])
        .map((stockData) => WatchlistStock.fromMap(stockData))
        .toList();
    var recommendationList = (data['recommendations_list'] as List? ?? [])
        .map((recommendationData) => Recommendation.fromMap(recommendationData))
        .toList();
    var addedRecommendationList =
        (data['added_recommendations_list'] as List? ?? [])
            .map((recommendationData) =>
                WatchlistRecommendation.fromMap(recommendationData))
            .toList();

    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
      stockList: stockList,
      recommendationList: recommendationList,
      addedRecommendationList: addedRecommendationList,
      recommendationsUsed: int.parse(data['recommendations_used'].toString()),
    );
  }
}
