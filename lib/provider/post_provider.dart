import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:test_pkp/domain/post.dart';

class PostProvider with ChangeNotifier {
  List<Post> _listPosts = [];
  List<Post> get listPosts => _listPosts;

  bool _showBottomSheet = false;
  bool get showBottomSheet => _showBottomSheet;

  RequestState? _getPostState;
  RequestState? get getPostState => _getPostState;

  RequestState? _createUpdateState;
  RequestState? get createUpdateState => _createUpdateState;

  RequestState? _deletePostState;
  RequestState? get deletePostState => _deletePostState;

  int? _onDelete;
  int? get onDelete => _onDelete;

  int? _onEdit;
  int? get onEdit => _onEdit;

  int _onEditUserId = 0;

  bool _isEdit = false;
  bool get isEdit => _isEdit;

  var dio = Dio();

  final String baseUrl = 'https://jsonplaceholder.typicode.com/posts';

  Future<void> getPostsList() async {
    _getPostState = RequestState.LOADING;
    notifyListeners();
    try {
      var response = await dio.get(baseUrl);

      List<dynamic> data = response.data as List<dynamic>;

      var listMovieJson = data;
      _listPosts = listMovieJson.map((e) => Post.fromJson(e)).toList();

      if (response.statusCode == 201) {
        _getPostState = RequestState.SUCCESS;
      } else {
        _getPostState = RequestState.FAILED;
      }
      notifyListeners();
    } catch (e) {
      print(e);
      _getPostState = RequestState.FAILED;
      notifyListeners();
    }
  }

  Future<void> createPost(
    int userId,
    String title,
    String desc,
  ) async {
    _createUpdateState = RequestState.LOADING;
    notifyListeners();

    try {
      var response = await dio.post(baseUrl,
          data: {"title": title, "body": desc, "userId": userId});

      if (response.statusCode == 201) {
        _createUpdateState = RequestState.SUCCESS;
      } else {
        _createUpdateState = RequestState.FAILED;
      }
      notifyListeners();
    } catch (e) {
      print(e);
      _createUpdateState = RequestState.FAILED;
      notifyListeners();
    }
  }

  Future<void> deletePost(int id) async {
    _onDelete = id;
    _deletePostState = RequestState.LOADING;
    notifyListeners();

    try {
      var response = await dio.delete('$baseUrl/$id');

      if (response.statusCode == 200) {
        _deletePostState = RequestState.SUCCESS;
        deletingPost(id);
      } else {
        _deletePostState = RequestState.FAILED;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      _deletePostState = RequestState.FAILED;
      notifyListeners();
    }
  }

  Future<void> EditPost(
    String title,
    String desc,
  ) async {
    _createUpdateState = RequestState.LOADING;
    notifyListeners();

    try {
      var response = await dio.put('$baseUrl/$_onEdit', data: {
        "id": _onEdit,
        "title": title,
        "body": desc,
        "userId": _onEditUserId
      });

      Map<String, dynamic> data = response.data as Map<String, dynamic>;

      if (response.statusCode == 200) {
        updatingPost(
          data["id"],
          data["userId"],
          data["title"],
          data["body"],
        );
        _createUpdateState = RequestState.SUCCESS;
      } else {
        _createUpdateState = RequestState.FAILED;
      }
      notifyListeners();
    } catch (e) {
      print(e);
      _createUpdateState = RequestState.FAILED;
      notifyListeners();
    }
  }

  void deletingPost(int id) {
    _listPosts.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updatingPost(
    int id,
    int userId,
    String title,
    String body,
  ) {
    Post updatedPost = Post(id: id, userId: userId, title: title, body: body);
    int index = _listPosts.indexWhere((e) => e.id == id);
    _listPosts[index] = updatedPost;
    notifyListeners();
  }

  void setShowBottomSheet() {
    _showBottomSheet = !_showBottomSheet;
    if (_showBottomSheet == false && _isEdit) {
      _isEdit = false;
    }
    notifyListeners();
  }

  void setIsEdit(int id, int userId) {
    _isEdit = true;
    _onEdit = id;
    _onEditUserId = userId;
    notifyListeners();
  }
}

enum RequestState { LOADING, SUCCESS, FAILED }
