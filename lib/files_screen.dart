import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ggits/viewer.dart';
import 'package:path/path.dart' as path;

class FileScreen extends StatefulWidget {
  const FileScreen({Key? key, required this.folderName}) : super(key: key);

  final String folderName;

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  List<String> _fileNames = [];

  @override
  void initState() {
    super.initState();
    _loadFiles('');
  }

  Future<void> _loadFiles(String folderName) async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child("Censored")
        .child(widget.folderName) // point to parent folder

        // .child(folderName) // point to subfolder
        .listAll();
    List<String> fileNames = [];
    for (Reference ref in result.items) {
      String name = ref.name;
      fileNames.add(name);
    }
    setState(() {
      _fileNames = fileNames;
    });
  }

  Future<void> _pickFile(String folderName) async {
    

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);

      // store the uploaded file in the subfolder
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('Censored') //random folder
          .child(widget.folderName) 
// .child(folderName) 
          .child(fileName);

      UploadTask uploadTask = storageReference.putFile(file);

      uploadTask.whenComplete(() {
        if (kDebugMode) {
          print('File uploaded');
        }
        setState(() {
          _fileNames.add(fileName);
          _loadFiles(folderName); //  refresh the list
        });
      });
    }
  }

  Future<void> _openFile(String fileName) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => ViewFileScreen(
          fileName: fileName,
          folderName: widget.folderName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folderName),
      ),
      body: ListView.builder(
        itemCount: _fileNames.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(_fileNames[index]),
            onTap: () => _openFile(_fileNames[index]),
          );
        },
      ),
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -20),
        child: FloatingActionButton(
          onPressed: () {
            showModalBottomSheet(
              elevation: 3,
              backgroundColor: Colors.transparent,
              context: context,
              builder: (BuildContext context) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    color: Colors.blueGrey.shade900,
                  ),
                  height: MediaQuery.of(context).size.height / 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => _pickFile(''),
                            child: Container(
                              height: MediaQuery.of(context).size.height / 14,
                              width: MediaQuery.of(context).size.width / 8,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: Colors.white70,
                                  width: 0.4,
                                ),
                              ),
                              child: Column(
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.only(top: 16.0),
                                    child: Icon(
                                      Icons.upload_file_outlined,
                                      color: Colors.white70,
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: size.height / 80,
                          ),
                          const Text(
                            "Upload",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height / 14,
                            width: MediaQuery.of(context).size.width / 8,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white70,
                                width: 0.4,
                              ),
                            ),
                            child: Column(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.only(top: 16.0),
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 80,
                          ),
                          const Text(
                            "Scan",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.grey.shade500,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(25),
              bottom: Radius.circular(25),
            ),
          ),
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
