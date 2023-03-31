import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import 'file_viewer.dart';

class RecentsScreen extends StatefulWidget {
  const RecentsScreen({
    super.key,
  });

  @override
  State<RecentsScreen> createState() => _RecentsScreenState();
}

class _RecentsScreenState extends State<RecentsScreen> {
  String _quoteWords =
      'beep boop beep.. hey there! -.-'; // initialize with an empty list of words
  // int _currentWordIndex = 0; // index of the currently displayed word

  // here is the logic to load files from File_upload_screen
  Future<List<String>> getFileNames() async {
    Directory directory = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = directory.listSync();
    List<FileSystemEntity> filteredFiles = files
        .where((file) =>
            !file.path.contains('flutter_assets') && // excluding bugs
            !file.path.contains('res_timestamp'))
        .toList();

    // sorting files according to latest an oldest
    filteredFiles
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));
    List<String> fileNames = filteredFiles
        .take(9) // show only top 9 recently opened
        .map((file) => path.basename(file.path))
        .toList();
    return fileNames;
  }

  List<String> _recentFileNames = [];

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _getQuoteWords();
    });
    getFileNames().then((fileNames) {
      setState(() {
        _recentFileNames = fileNames;
      });
    });
    // _getQuoteWords(); // fetch a quote when the screen is loaded
  }

  void _openFile(String fileName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ViewFileScreen(
          fileName: fileName,
          folderName: '',
          parentFolderName: '',
        ),
      ),
    );
  }

  void _getQuoteWords() async {
    final response =
        await http.get(Uri.parse('https://api.quotable.io/random'));
    if (response.statusCode == 200 && mounted) {
      // checking if widget is still mounted
      final Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        _quoteWords = data['content'];
      });
    } else if (mounted) {
      // checking if widget is still mounted
      setState(() {
        _quoteWords = 'Failed to load quote';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        SizedBox(
          height: size.height / 46,
        ),
        Container(
            width: size.width / 1.2,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  _quoteWords,
                  textAlign: TextAlign.center,
                  textStyle: const TextStyle(
                    color: Colors.cyan,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 100, // 100 quotes will be shown at one shot
              onFinished: () {
                return _getQuoteWords();
              },
              pause: const Duration(seconds: 10),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            )

            // TypewriterAnimatedTextKit(
            //   repeatForever: false,
            //   speed: const Duration(milliseconds: 100),
            //   text: _quoteWords.getRange(0, _currentWordIndex).join(' '),
            //   textStyle: const TextStyle(
            //     fontSize: 18,
            //     color: Colors.cyan,
            //   ),
            //   textAlign: TextAlign.center,
            //   isRepeatingAnimation: false,
            //   totalRepeatCount: 1,

            //   // cursor:  Cursor(
            //   //   height: 20,
            //   //   width: 10,
            //   //   blinkFrequency: Duration(milliseconds: 800),
            //   // ),
            // ),
            ),
        SizedBox(
          height: size.height / 42,
        ),
        Expanded(
          child: _recentFileNames.isEmpty
              ? const Center(
                  child: Text(
                    "Your recently opened notes\nwill appear here.",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                )
              : GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _recentFileNames.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    mainAxisSpacing: 50,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final String fileName = _recentFileNames[index];
                    final String nameWithoutExtension =
                        path.basenameWithoutExtension(
                            fileName); // Display filenames without the extention
                    return GestureDetector(
                      onTap: () => _openFile(fileName),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                ),
        ),
      ],
    );
  }
}
