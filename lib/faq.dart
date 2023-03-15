import 'package:flutter/material.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({Key? key}) : super(key: key);

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<String> _questions = [
    'How do I reset my password?',
    'How do I update my profile information?',
    'Can I cancel my subscription?',
    'How do I contact customer support?',
  ];

  final List<String> _answers = [
    'To reset your password, go to the login screen and click the "Forgot password" link. You will be prompted to enter your email address and follow the instructions in the email that is sent to you.',
    'To update your profile information, go to your profile page and click the "Edit" button. You can then update your name, profile picture, and other information.',
    'Yes, you can cancel your subscription at any time by going to your account settings and clicking the "Cancel subscription" button. Note that you will continue to have access to the premium features until the end of your current billing cycle.',
    'If you need help or have any questions, please contact our customer support team at support@example.com. We are available 24/7 to assist you.'
  ];

  int _selectedQuestionIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return ExpansionTile(
                  title: Text(
                    _questions[index],
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  // ignore: sort_child_properties_last
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Text(
                        _answers[index],
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
