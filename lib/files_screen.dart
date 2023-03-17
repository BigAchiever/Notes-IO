import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ggits/viewer.dart';
import 'package:path/path.dart' as path;
import 'package:rive/rive.dart';

class FileScreen extends StatefulWidget {
  const FileScreen(
      {Key? key, required this.parentFolderName, required this.folderName})
      : super(key: key);

  final String folderName;
  final String parentFolderName;

  @override
  State<FileScreen> createState() => _FileScreenState();
}

class _FileScreenState extends State<FileScreen> {
  List<String> _fileNames = [];
  bool _isUploading = false;
  User? _user;
  @override
  void initState() {
    super.initState();
    _loadFiles('');
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  Future<void> _loadFiles(String folderName) async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child(widget.parentFolderName)
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
    setState(() {
      _isUploading = true; // set the state variable to true when upload starts
    });
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = path.basename(file.path);

      // store the uploaded file in the subfolder
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child(widget.parentFolderName) //random folder
          .child(widget.folderName)
// .child(folderName)
          .child(fileName);

      UploadTask uploadTask = storageReference.putFile(file);

      await FirebaseFirestore.instance
          .collection('admins')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('files')
          .add({
        'fileName': fileName,
        'folderName': folderName,
      });

      uploadTask.whenComplete(() {
        setState(() {
          _fileNames.add(fileName);
          _isUploading = false;
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
          parentFolderName: widget.parentFolderName,
          folderName: widget.folderName,
          fileName: fileName,
        ),
      ),
    );
  }

  Future<void> _downloadFile(String fileName) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(widget.parentFolderName)
        .child(widget.folderName)
        .child(fileName);

    Directory? directory = await getExternalStorageDirectory();
    String filePath = '${directory?.path}/$fileName';

    File localFile = File(filePath);
    bool exists = await localFile.exists();
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File already exists in local storage.')));
      return;
    }

    try {
      Uint8List? data = await ref.getData();
      await localFile.writeAsBytes(data!);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File downloaded to local storage.')));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(children: [
      // Positioned(
      //   width: MediaQuery.of(context).size.width * 1.7,
      //   left: 100,
      //   bottom: 100,
      //   child: Image.asset(
      //     "assets/images/Spline.png",
      //   ),
      // ),
      Positioned.fill(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 200, sigmaY: 20),
          child: const SizedBox(
            height: 100,
          ),
        ),
      ),
      const RiveAnimation.asset(
        "assets/images/shapes.riv",
      ),
      Positioned.fill(
        child: BackdropFilter(
          blendMode: BlendMode.src,
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: const SizedBox(),
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black54,
          title: Text(widget.folderName),
        ),
        body: _isUploading // whenever anyone uploads any file this is called
            ? const Center(
                child: CircularProgressIndicator(color: Colors.lightBlue),
              )
            : _fileNames.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.lightBlue),
                  )
                : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: _fileNames.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 1,
                            mainAxisSpacing: 60),
                    itemBuilder: (BuildContext context, int index) {
                      final String fileName = _fileNames[index];
                      return GestureDetector(
                        onTap: () => _openFile(fileName),
                        onLongPress: () => showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Download File?'),
                            content: const Text(
                                'Do you want to download the file to local storage?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _downloadFile(fileName);
                                  Navigator.pop(context);
                                },
                                child: const Text('Download'),
                              ),
                              if (_isUploading) // kam kyu nahi karha bhai tu
                                const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.lightBlue,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: size.height / 9,
                                    child: Image.asset(
                                      'assets/images/file4.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height / 60),
                              Flexible(
                                flex: 1,
                                child: SizedBox(
                                  width: size.width / 4,
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      fileName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400),
                                      maxLines: 3,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        floatingActionButton: _user?.providerData
                    .any((element) => element.providerId == "google.com") ??
                true
            ? null
            : Transform.translate(
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
                                      height:
                                          MediaQuery.of(context).size.height /
                                              14,
                                      width:
                                          MediaQuery.of(context).size.width / 8,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                    height:
                                        MediaQuery.of(context).size.height / 14,
                                    width:
                                        MediaQuery.of(context).size.width / 8,
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
                  backgroundColor: Colors.white,
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
      ),
    ]);
  }
}
