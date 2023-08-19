// UserModel definition
class UserModel {
  final String uid;
  final String username;
  final String email;
  final String imageUrl;
  final List<Map<String, dynamic>> stockList;

  UserModel(
      {required this.uid,
      required this.username,
      required this.email,
      required this.imageUrl,
      required this.stockList});

  factory UserModel.fromFirestore(String uid, Map<String, dynamic> data) {
    var stockList = (data['stock_list'] as List? ?? [])
        .map((stockData) => stockData as Map<String, dynamic>)
        .toList();

    print(stockList);

    return UserModel(
      uid: uid,
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      imageUrl: data['image_url'] ?? '',
      stockList: stockList,
    );
  }
}
