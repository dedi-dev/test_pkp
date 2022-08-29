import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_pkp/provider/post_provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController userIdTextController = TextEditingController();
  TextEditingController titleTextController = TextEditingController();
  TextEditingController bodyTextController = TextEditingController();

  @override
  initState() {
    super.initState();
    Provider.of<PostProvider>(context, listen: false).getPostsList();
  }

  @override
  Widget build(BuildContext context) {
    PostProvider postProvider = Provider.of<PostProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: postProvider.getPostState == RequestState.LOADING
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        itemCount: postProvider.listPosts.length,
                        itemBuilder: (context, index) {
                          int id = postProvider.listPosts[index].id;
                          int userId = postProvider.listPosts[index].userId;
                          String title = postProvider.listPosts[index].title;
                          String body = postProvider.listPosts[index].body;
                          bool loading = postProvider.onDelete == id &&
                              postProvider.deletePostState ==
                                  RequestState.LOADING;
                          return Card(
                            elevation: 5,
                            child: ListTile(
                              leading: loading
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () async {
                                        await postProvider.deletePost(id);
                                        if (postProvider.deletePostState ==
                                            RequestState.SUCCESS) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(_snackBar(
                                                  "Success Delete Post"));
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(_snackBar(
                                                  "Failed Delete Post"));
                                        }
                                      },
                                      icon: const Icon(Icons.delete)),
                              title: loading
                                  ? const SizedBox(
                                      height: 100,
                                      child: Center(
                                          child: CircularProgressIndicator()))
                                  : Text(title),
                              subtitle: loading ? const SizedBox() : Text(body),
                              trailing: loading
                                  ? const SizedBox()
                                  : IconButton(
                                      onPressed: () {
                                        titleTextController.text = title;
                                        bodyTextController.text = body;
                                        postProvider.setIsEdit(id, userId);
                                        postProvider.setShowBottomSheet();
                                      },
                                      icon: const Icon(Icons.edit)),
                            ),
                          );
                        })),
              ],
            ),
      bottomSheet:
          postProvider.showBottomSheet ? _bottomSheet(postProvider) : null,
      floatingActionButton:
          !postProvider.showBottomSheet ? _addPostButton(postProvider) : null,
    );
  }

  FloatingActionButton _addPostButton(PostProvider postProvider) {
    return FloatingActionButton(
      onPressed: () {
        userIdTextController.text = "";
        titleTextController.text = "";
        bodyTextController.text = " ";
        postProvider.setShowBottomSheet();
      },
      tooltip: 'Add Post',
      child: const Icon(Icons.add),
    );
  }

  Widget _bottomSheet(PostProvider postProvider) {
    return BottomSheet(
      onClosing: () {},
      builder: (context) {
        return Container(
          height: postProvider.isEdit ? 350 : 400,
          width: double.infinity,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: postProvider.createUpdateState == RequestState.LOADING
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    postProvider.isEdit
                        ? const SizedBox(height: 10)
                        : Container(
                            margin: const EdgeInsets.all(10),
                            child: TextField(
                              controller: userIdTextController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'User ID',
                              ),
                              onChanged: (text) {},
                            ),
                          ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        maxLines: 2,
                        controller: titleTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Title',
                        ),
                        onChanged: (text) {},
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: TextField(
                        maxLines: 5,
                        controller: bodyTextController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Description',
                        ),
                        onChanged: (text) {},
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          child: Text("Cancel"),
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.red,
                          ),
                          onPressed: postProvider.setShowBottomSheet,
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          child: Text(postProvider.isEdit ? "Edit" : "Save"),
                          style: ElevatedButton.styleFrom(
                            onPrimary: Colors.white,
                            primary: Colors.green,
                          ),
                          onPressed: () async {
                            if (postProvider.isEdit) {
                              await postProvider.EditPost(
                                  titleTextController.text,
                                  bodyTextController.text);

                              if (postProvider.createUpdateState ==
                                  RequestState.SUCCESS) {
                                postProvider.setShowBottomSheet();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _snackBar("Success Edot Post"));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _snackBar("Failed Edit Post"));
                              }
                            } else {
                              await postProvider.createPost(
                                  int.parse(userIdTextController.text),
                                  titleTextController.text,
                                  bodyTextController.text);

                              if (postProvider.createUpdateState ==
                                  RequestState.SUCCESS) {
                                postProvider.setShowBottomSheet();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _snackBar("Success Create Post"));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    _snackBar("Failed Create Post"));
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }

  SnackBar _snackBar(String message) {
    return SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: 'Close',
        onPressed: () {},
      ),
    );
  }
}
