class Post {
  int userId, id;
  String title, body;

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  static Post fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      body: json['body'],
    );
  }
}
