import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:ggits/file_viewer.dart';
import 'package:path/path.dart' as path;
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  bool _gridView = true;
  List<String> _fileNames = [];
  List<String> _recentFileNames =
      []; // for loading files in recents screen as well

  bool _isUploading = false;
  late ConfettiController _confettiController;
  // final AudioCache _audioCache = AudioCache();
  bool _isAnimating = false;

  User? _user;

  @override
  void initState() {
    super.initState();
    _loadFiles('');
    _loadViewPreference(); // loading the previously switched layout
    _confettiController = ConfettiController();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  //Saving the state of the layout
  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isGridView = prefs.getBool('isGridView2') ?? false;
    setState(() {
      _gridView = isGridView;
    });
  }

  //Saving the state of the layout
  Future<void> _saveViewPreference(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView2', isGridView);
  }

  Future<void> _loadFiles(String folderName) async {
    ListResult result = await FirebaseStorage.instance
        .ref()
        .child(widget.parentFolderName)
        .child(widget.folderName) // point to parent folder
        .child(folderName) // point to subfolder
        .listAll();
    List<String> fileNames = [];
    for (Reference ref in result.items) {
      String name = ref.name;
      fileNames.add(name);
    }
    setState(() {
      _fileNames = fileNames;
      _recentFileNames = List.from(_recentFileNames)..addAll(fileNames);
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

  Future<void> _downloadFile(String fileName,
      {required Directory directory}) async {
    Reference ref = FirebaseStorage.instance
        .ref()
        .child(widget.parentFolderName)
        .child(widget.folderName)
        .child(fileName);

    String filePath = '${directory.path}/$fileName';

    File localFile = File(filePath);
    bool exists = await localFile.exists();
    if (exists) {
      Fluttertoast.showToast(
          msg: 'Document is already Saved Offline in the App',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color.fromARGB(143, 3, 168, 244),
          textColor: Colors.white);
      return;
    }

    try {
      final DownloadTask task = ref.writeToFile(localFile);
      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state == TaskState.success) {
          Fluttertoast.showToast(
              msg: 'Now you can access the document offline in the Application',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: const Color.fromRGBO(9, 166, 239, 0.543),
              textColor: Colors.white);
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  // Storing files in the application offline
  void _showStorageOptions(String fileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 10,
            left: 10,
            right: 10,
            top: 10,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.file_download,
                    color: Colors.green,
                  ),
                  title: const Text('Access offline'),
                  onTap: () async {
                    Navigator.pop(context);

                    // Making it available offline
                    Directory? directory =
                        await getApplicationDocumentsDirectory();
                    _downloadFile(fileName, directory: directory);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.favorite_outline,
                    color: Colors.red,
                  ),
                  title: const Text("Share the App"),
                  onTap: () async {},
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Confetti playing logic
  void _onPressed() {
    setState(() {
      _isAnimating = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isAnimating = false;
      });
    });

    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
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
            actions: [
              GestureDetector(
                  onTap: () {
                    setState(() {
                      _gridView = !_gridView;
                    });
                    _saveViewPreference(_gridView);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * 0.05),
                    child: Icon((_gridView) ? Icons.list : Icons.grid_on),
                  )),
            ],
          ),
          body: _isUploading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.lightBlue),
                )
              : _fileNames.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.lightBlue),
                    )
                  : (_gridView)
                      ? GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _fileNames.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 1,
                                  mainAxisSpacing: 60),
                          itemBuilder: (BuildContext context, int index) {
                            final String fileName = _fileNames[index];
                            final String nameWithoutExtension =
                                path.basenameWithoutExtension(
                                    fileName); // Display filenames without the extention
                            return GestureDetector(
                              onTap: () => _openFile(fileName),
                              onLongPress: () {
                                _showStorageOptions(fileName);
                              },
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            nameWithoutExtension,
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
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _fileNames.length,
                          itemBuilder: (BuildContext context, int index) {
                            final String fileName = _fileNames[index];
                            final String nameWithoutExtension =
                                path.basenameWithoutExtension(fileName);
                            return Container(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              decoration: const BoxDecoration(
                                  border: Border.symmetric(
                                      horizontal:
                                          BorderSide(color: Colors.black12))),
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/images/file4.png',
                                  fit: BoxFit.contain,
                                ),
                                title: Text(
                                  nameWithoutExtension,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400),
                                  maxLines: 3,
                                  overflow: TextOverflow.visible,
                                  textAlign: TextAlign.left,
                                ),
                                onTap: () => _openFile(fileName),
                                onLongPress: () =>
                                    _showStorageOptions(fileName),
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
                    heroTag: "File screen button",
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
                                            MediaQuery.of(context).size.width /
                                                8,
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
                                              padding:
                                                  EdgeInsets.only(top: 16.0),
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
                                    GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                14,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                8,
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
                                              padding:
                                                  EdgeInsets.only(top: 16.0),
                                              child: Icon(
                                                Icons.folder_copy_outlined,
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
                                      "Folder",
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

        //  bottom most text here, with animations
        Positioned(
          bottom: 0,
          right: 70,
          child: SizedBox(
            width: 250,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              hoverColor: Colors.transparent,
              focusColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
              onPressed: _onPressed,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                style: _isAnimating
                    ? const TextStyle(
                        color: Colors.white,
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      )
                    : const TextStyle(
                        color: Colors.white24,
                        fontSize: 16.0,
                      ),
                child: _isAnimating
                    ? const RotatedBox(
                        quarterTurns: 0,
                        child: Text("🤪"),
                      )
                    : const Center(
                        child: Text(
                        "Long press the files for more!",
                        textAlign: TextAlign.center,
                      )),
              ),
            ),
          ),
        ),
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          emissionFrequency: 0.05,
          numberOfParticles: 20,
          gravity: 0.1,
          shouldLoop: false,
          colors: const [
            Colors.blue,
            Colors.purple,
            Colors.pink,
            Colors.orange,
            Colors.yellow,
            Colors.green,
          ],
        ),
      ],
    );
  }
}

/*


*/
