import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:ggits/file_upload_screen.dart';
import 'package:ggits/new_asset2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolderScreen extends StatefulWidget {
  final String folderName;

  const FolderScreen({Key? key, required this.folderName}) : super(key: key);

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  late List<String> folderNames;

  bool _gridView = true;
  String folderAsset2 = 'assets/images/folder6.gif';
  User? _user;

  @override
  void initState() {
    super.initState();
    folderNames = [];
    _loadFolderNames();
    _loadViewPreference(); // loading the previousely switched layout
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        // so it will not call the set state even after the state has ended
        setState(() {
          _user = user;
        });
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      final asset2 = prefs.getString('folderAsset2');
      if (asset2 != null) {
        setState(() {
          folderAsset2 = asset2;
        });
      }
    });
  }

  Future<void> _loadFolderNames() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.ref().child(widget.folderName);
    final ListResult result = await ref.listAll();
    final List<String> folderNames = [];
    for (final prefix in result.prefixes) {
      // Get the name of the subfolder by splitting the full path
      final parts = prefix.fullPath.split('/');
      final name = parts.last;
      folderNames.add(name);
    }
    setState(() {
      this.folderNames = folderNames;
    });
  }

  Future<void> _createFolder(String folderName) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory folder = Directory('${appDir.path}/${widget.folderName}');
    final Directory newFolder = Directory('${folder.path}/$folderName');
    await newFolder.create();

    // Create the Firebase Storage reference for the new subfolder
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref =
        storage.ref().child('${widget.folderName}/$folderName/');

    // Upload a placeholder file to create the subfolder in Firebase Storage
    final File placeholderFile =
        await File('${newFolder.path}/placeholder.txt').create();
    await ref.child('placeholder.txt').putFile(placeholderFile);

    // Load the updated list of subfolder names
    _loadFolderNames();

    setState(() {
      folderNames.add(folderName);
    });
  }

  Future<void> _showCreateFolderDialog() async {
    final TextEditingController folderNameController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create a Folder'),
          content: TextField(
            controller: folderNameController,
            decoration: const InputDecoration(
              hintText: 'Enter a folder name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                final String folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  _createFolder(folderName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );
  }

  //Saving the state of the layout
  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isGridView = prefs.getBool('isGridView1') ?? false;
    setState(() {
      _gridView = isGridView;
    });
  }

  //Saving the state of the layout
  Future<void> _saveViewPreference(bool isGridView) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView1', isGridView);
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
        body: folderNames.isEmpty
            ? Center(
                child: FutureBuilder<void>(
                  future: Future.delayed(const Duration(seconds: 3)),
                  builder:
                      (BuildContext context, AsyncSnapshot<void> snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        folderNames.isEmpty) {
                      return const Center(
                        child: Text(
                          "No notes found, Goodluck! 🥳",
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
                    return const CircularProgressIndicator(
                      color: Colors.lightBlue,
                    );
                  },
                ),
              )
            : (_gridView)
                ? GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: folderNames.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      final String folderName = folderNames[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to new screen of subfolders
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FileScreen(
                                  parentFolderName: widget.folderName,
                                  folderName: folderName),
                            ),
                          );
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: size.height / 8,
                                    child: Image.asset(
                                      folderAsset2,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: SizedBox(
                                      width: size.width / 4,
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          folderName,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  PopupMenuButton(
                                    itemBuilder: (_) => [
                                      const PopupMenuItem(
                                        value: 'customize',
                                        child: Text('Customize'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'favorites',
                                        child: Text('Favorites'),
                                      ),
                                    ],
                                    onSelected: (value) async {
                                      if (value == 'customize') {
                                        // Show a dialog with a list of available assets
                                        final asset2 = await showDialog<String>(
                                          context: context,
                                          builder: (context) =>
                                              const AssetSelectionDialog2(),
                                        );
                                        // Update on user's selection
                                        if (asset2 != null) {
                                          setState(() {
                                            folderAsset2 = asset2;
                                          });
                                          // Save the selected
                                          final prefs = await SharedPreferences
                                              .getInstance();
                                          prefs.setString(
                                              'folderAsset2', folderAsset2);
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: folderNames.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String folderName = folderNames[index];
                      // final String nameWithoutExtension =
                      //     path.basenameWithoutExtension(fileName);
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        decoration: const BoxDecoration(
                            border: Border.symmetric(
                                horizontal: BorderSide(color: Colors.black12))),
                        child: ListTile(
                          leading: Image.asset(
                            folderAsset2,
                            fit: BoxFit.contain,
                          ),
                          title: Text(
                            folderName,
                            style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FileScreen(
                                  parentFolderName: widget.folderName,
                                  folderName: folderName),
                            ),
                          ),
                          // onLongPress: () => _showStorageOptions(fileName),
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
                  heroTag: "Subfolder screen button",
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
                                    onTap: _showCreateFolderDialog,
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
                                            Icons.upload_file_outlined,
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
