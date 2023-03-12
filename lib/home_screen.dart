import 'dart:io';

import 'dart:ui';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ggits/subfolder_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<String> folderNames;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    folderNames = [];
    _loadFolderNames();
  }

// Add a method to set the sign in with email flag
  Future<void> _loadFolderNames() async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final ListResult result = await storage.ref().listAll();
    folderNames.clear();
    for (final Reference ref in result.prefixes) {
      final String folderName = ref.name;
      folderNames.add(folderName);
    }
    setState(() {});
  }

  Future<void> _createFolder(String folderName) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference folderRef = storage.ref().child('$folderName/');

    // create an empty file to create a folder
    await folderRef.child('placeholder.txt').putData(Uint8List(0));

    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory newFolder = Directory('${appDir.path}/$folderName');
    await newFolder.create();

    final File placeholderFile = File(
        '${newFolder.path}/placeholder.txt'); // create a placeholder.txt file in the local folder
    await placeholderFile.create();

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

  List<String> getFilteredFolders() {
    List<String> filteredFolders = [];

    for (String folderName in folderNames) {
      if (folderName.toLowerCase().contains(_searchQuery.toLowerCase())) {
        filteredFolders.add(folderName);
      }
    }

    return filteredFolders;
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    TextEditingController _searchController;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                "assets/images/Spline.png",
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                blendMode: BlendMode.xor,
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 20,
                ),
                child: const SizedBox(),
              ),
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.black87,
                title: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintText: 'Search your Branch',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    suffixIcon: const Icon(
                      Icons.search,
                      color: Colors.red,
                    ),
                    prefixIcon: const Icon(
                      Icons.menu,
                      color: Colors.red,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.lightBlueAccent,
                  labelColor: Colors.lightBlueAccent,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(
                      text: 'Branch',
                    ),
                    Tab(
                      text: 'Computer',
                    ),
                  ],
                ),
              ),
              body: folderNames.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Colors.lightBlue,
                      ),
                    )
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: getFilteredFolders().length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        final String folderName = getFilteredFolders()[index];
                        return GestureDetector(
                          onTap: () {
                            // Navigate to the folder screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FolderScreen(
                                  folderName: folderName,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 1,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.transparent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: size.width / 3,
                                      height: size.height / 7,
                                      child: Image.asset(
                                        'assets/images/folder4.gif',
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
                                        width: size.width / 4.5,
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

                                    // ---------------------------------Popup menu--------------------------------
                                    PopupMenuButton(
                                      itemBuilder: (_) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          // Edit folder
                                        } else if (value == 'delete') {
                                          //confirmation dialog
                                          bool confirmed = await showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text(
                                                    'Confirm Delete'),
                                                content: const Text(
                                                    'Are you sure you want to delete this folder?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context,
                                                          false); // Return false to indicate cancellation
                                                    },
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context,
                                                          true); // Return true to indicate confirmation
                                                    },
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmed) {
                                            // Remove the folder name from the list of folder names
                                            final String folderName =
                                                folderNames.removeAt(index);

                                            // Get the app documents directory
                                            final Directory appDir =
                                                await getApplicationDocumentsDirectory();

                                            // Create a File object for the folder to delete
                                            final Directory folderToDelete =
                                                Directory(
                                                    '${appDir.path}/$folderName');

                                            // Check if the folder exists before deleting it
                                            if (await folderToDelete.exists()) {
                                              // Delete the folder and all its contents recursively
                                              await folderToDelete.delete(
                                                  recursive: true);

                                              // Clear the list of folder names
                                              folderNames.clear();

                                              // Reload the list of folder names to reflect the deletion
                                              await _loadFolderNames();
                                            }
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
                    ),

              // ---------------------------------Floating action button starts--------------------------------
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
                  backgroundColor: Colors.lime,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25),
                      bottom: Radius.circular(25),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            )
          ],
        );
      },
    );
  }
}
