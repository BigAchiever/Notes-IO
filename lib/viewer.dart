import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewFileScreen extends StatefulWidget {
  final String fileName;
  final String folderName;
  final String parentFolderName;


  const ViewFileScreen({
    Key? key,
    required this.fileName,
    required this.folderName, required this.parentFolderName,
  }) : super(key: key);

  @override
  State<ViewFileScreen> createState() => _ViewFileScreenState();
}

class _ViewFileScreenState extends State<ViewFileScreen> {
  String? _filePath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
      } catch (e) {
        if (kDebugMode) {
          print("Error signing in anonymously: $e");
        }
      }
    }

    if (user != null) {
      String token = await user.getIdToken();
      Directory appDirectory = await getApplicationDocumentsDirectory();
      String filePath = '${appDirectory.path}/${widget.fileName}';
      File file = File(filePath);
      if (!file.existsSync()) {
        try {
          HttpClient httpClient = HttpClient();
          HttpClientRequest request = await httpClient.getUrl(Uri.parse(
              await FirebaseStorage.instance
                  .ref()
                  .child(widget.parentFolderName) // Outside Folder
                  .child(widget.folderName) // Inside Folder
                  .child(widget.fileName) // File name
                  .getDownloadURL()));
          request.headers.add('Authorization', 'Bearer $token');
          HttpClientResponse response = await request.close();
          response.pipe(file.openWrite());
        } on FirebaseException catch (e) {
          if (kDebugMode) {
            print(e);
          }
        }
      }
      setState(() {
        _filePath = filePath;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle the case when the user is not authenticated
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SfPdfViewer.file(
              File(_filePath!),
              canShowPaginationDialog: true,
            ),
    );
  }
}
