import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_share_plugin/social_share_plugin.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _platformName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SocialSharePlugin Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_platformName == null)
              const SizedBox.shrink()
            else
              Text(
                'Platform Name: $_platformName',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await getPlatformName();
                  setState(() => _platformName = result);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Get Platform Name'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await shareToFeedFacebookLink(
                    url: 'https://www.flutter.dev',
                    quote: 'test',
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Share Link To Facebook Feed'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  await shareToFeedFacebook(
                    path: pickedFile!.path,
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Share Image to Facebook Feed'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await shareToTwitterLink(
                    url: 'https://www.flutter.dev',
                    text: r'test #, & and $',
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Share Link to Twitter'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);

                  await shareToFeedInstagram(
                    path: pickedFile!.path,
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Theme.of(context).primaryColor,
                      content: Text('$error'),
                    ),
                  );
                }
              },
              child: const Text('Share Image to Instagram'),
            ),
          ],
        ),
      ),
    );
  }
}
