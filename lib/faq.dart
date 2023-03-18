import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<String> _questions = [
    "Where I can find the notes?",
    "Who has written these notes?",
    "Are the notes complete according to what was taught in class?",
    "How can I Upload my Notes?",
    "I want to become an Admin. What will I need to do?",
    "What else we will get here other than notes?",
    "Notes are also available on Moo___, No?",
    "Is this application available offline?",
    "Will we recieve any credits for uploading our notes?"
  ];

  final List<String> _answers = [
    'On HomePage you can find your Branch/Semester folder by scrolling the screen or by searching your Branch/Semester on the Search Bar. After opening you Branch folder you can easily select the subject notes you wanna access and tap on it. And there you go!',
    "These notes are written by your semester peers and are published by them on the application.",
    "While we cannot provide a guarantee that the notes are comprehensive, we assure you that you will have access to all the necessary materials to effectively prepare for your exam.",
    "Great Initiative, You can easily request to upload your notes without becoming an admin by yourself. Just navigate to the menu, tap on 'Request to Upload', and there you go fill out the google form. After the verification process notes will be published",
    "You can easily request to be come an Admin and get the power to manage the publication by becoming an Admin, you just need to tap on another option on the menu, fill the Google form and wait for next 24 hours, we will contact you! 🤝",
    "We will try to provide all the necessary resources which is required for you guys, so that you all don't have to switch to multiple applications to find study material.",
    "Yes, its totally your wish which platform you want to prefer, here you will find several modes and options in the reader available to comfortably prepare for your exams which you won't get on Moo___ and other platforms and Most importantly you won't find Notes by your own batch mates on Moo___ with all the important Study material!",
    "Not yet, But looking forward to it in later versions. There is much more to come so stay tuned! 💙",
    "Yes obviously, We will be implementing that feature soon in future updates!",
  ];

  int _selectedQuestionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          width: MediaQuery.of(context).size.width * 1.7,
          left: 10,
          bottom: 100,
          child: Image.asset(
            "assets/images/Spline.png",
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            blendMode: BlendMode.src,
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox(),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.black87,
          appBar: AppBar(
            backgroundColor: Colors.black54,
            title: const Text('Frequently Asked Questions'),
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(
                decelerationRate: ScrollDecelerationRate.normal),
            child: Column(
              children: [
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _selectedQuestionIndex == index
                            ? Colors.black12
                            : Colors.black54,
                      ),
                      child: ExpansionTile(
                        title: Text(
                          _questions[index],
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        onExpansionChanged: (expanded) {
                          setState(() {
                            if (expanded) {
                              _selectedQuestionIndex = index;
                            } else {
                              _selectedQuestionIndex = -1;
                            }
                          });
                        },
                        initiallyExpanded: _selectedQuestionIndex == index,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: Text(
                              _answers[index],
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
