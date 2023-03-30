import 'dart:io';

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ggits/dialoguebox.dart';
import 'package:ggits/drawer.dart';
import 'package:ggits/new_asset1.dart';
import 'package:ggits/recents.dart';

import 'package:ggits/subfolder_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  //used for smooth transition between recents and branches
  late PageController _pageController;
  // used for searching folders
  late List<String> folderNames;

  String _searchQuery = '';
  // tabbar index
  int _currentIndex = 0;
  //used for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  User? _user;
  // Initial asset
  String folderAsset = 'assets/images/folder6.gif';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // switching tabs
    _pageController = PageController(
        initialPage: 0,
        viewportFraction: 1.0); // switching between recents and my branch pages
    folderNames = [];
    _loadFolderNames();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool dialogShown = prefs.getBool('dialogShown') ??
          false; //checking if the user logged in previousely
      if (!dialogShown) {
        // ignore: use_build_context_synchronously
        _showWelcomeDialog(context);
        prefs.setBool('dialogShown', true);
      }
    });
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _user = user;
        });
      }
    });

    SharedPreferences.getInstance().then((prefs) {
      final asset = prefs.getString('folderAsset');
      if (asset != null) {
        setState(() {
          folderAsset = asset;
        });
      }
    });
  }

  // Whenever user logins this Dialog appears
  Future<void> _showWelcomeDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return CustomDialog(
          title: 'Hey there, buds!',
          message:
              '''⁕ Access to quality handwritten notes by your college mates of different branches and semesters.
              \n⁕ User-friendly interface for easy navigation and access to notes.
              \n⁕ Integrated document viewer for easy reading and writing, with several modes, themes, layout customization, and much more!
              \n⁕ Admin functionality for specific users to upload files and create folders and manage the resources.
              \n⁕ Users can find all the resources and Notes available here, so now you don't need to switch through several application to access different Study Materials.''',
          onPressed: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );
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

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
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
              key: _scaffoldKey,
              drawer: const CustomDrawer(),
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: Colors.black87,
                title: TextField(
                  autofocus: false,
                  decoration: InputDecoration(
                    hintStyle: const TextStyle(color: Colors.white54),
                    hintText: 'Search your Branch',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.withOpacity(0.2),
                    suffixIcon: GestureDetector(
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      child: const Icon(
                        Icons.search,
                        color: Colors.red,
                      ),
                    ),
                    prefixIcon: IconButton(
                      splashColor: Colors.transparent,
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
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
                  splashBorderRadius: BorderRadius.zero,
                  splashFactory: NoSplash.splashFactory,
                  controller: _tabController,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                      _pageController.animateToPage(
                        _currentIndex,
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOut,
                      );
                    });
                  },
                  indicatorSize: TabBarIndicatorSize.label,
                  indicatorColor: Colors.lightBlueAccent,
                  labelColor: Colors.lightBlueAccent,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(
                      text: 'Branch',
                    ),
                    Tab(
                      text: 'Recents',
                    ),
                  ],
                ),
              ),

              body: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  _tabController.animateTo(
                    index,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.ease,
                  );
                },
                children: [
                  folderNames.isEmpty
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
                            final String folderName =
                                getFilteredFolders()[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigate to the folder screen

                                FocusManager.instance.primaryFocus
                                    ?.unfocus(); // unfocus cursor

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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: size.width / 3,
                                          height: size.height / 7,
                                          child: Image.asset(
                                            folderAsset,
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
                                                    fontWeight:
                                                        FontWeight.w500),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // ---------------------------------Popup menu--------------------------------

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
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            if (value == 'customize') {
                                              // Show a dialog with a list of available assets
                                              final asset =
                                                  await showDialog<String>(
                                                context: context,
                                                builder: (context) =>
                                                    const AssetSelectionDialog(),
                                              );
                                              // Update on user's selection
                                              if (asset != null) {
                                                setState(() {
                                                  folderAsset = asset;
                                                });
                                                // Save the selected
                                                final prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setString(
                                                    'folderAsset', folderAsset);
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
                  RecentsScreen(),
                ],
              ),

              // ---------------------------------Floating action button starts--------------------------------
              floatingActionButton: _user?.providerData.any(
                          (element) => element.providerId == "google.com") ??
                      true
                  ? null
                  : Transform.translate(
                      offset: const Offset(0, -20),
                      child: FloatingActionButton(
                        heroTag: "home screen button",
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: _showCreateFolderDialog,
                                          child: Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                14,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
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
                                                  padding: EdgeInsets.only(
                                                      top: 16.0),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              14,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              14,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
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
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endFloat,
            )
          ],
        );
      },
    );
  }
}
