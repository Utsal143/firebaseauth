import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNewsImages();
  }

  Future<void> _fetchNewsImages() async {
    const apiKey = '6943b536df894bbfa951075bf5d36fc3';
    const url =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List articles = data['articles'];
        setState(() {
          _articles = articles
              .map<Map<String, String>>((article) => {
                    'urlToImage': article['urlToImage']?.toString() ?? '',
                    'url': article['url']?.toString() ?? '',
                  })
              .where((article) => article['urlToImage']!.isNotEmpty)
              .toList();
          _isLoading = false;
        });
      } else {
        print('Failed to load news articles');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching news articles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signOut(BuildContext context) async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // Method to show dialog
  void _showPostDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Post to Facebook'),
          content: const Text('Do you want to post this image to Facebook?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Post'),
              onPressed: () {
                Navigator.of(context).pop();
                _handleFacebookPost(context, imageUrl);
              },
            ),
          ],
        );
      },
    );
  }

  // Method to handle Facebook post
  Future<void> _handleFacebookPost(
      BuildContext context, String imageUrl) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        _fetchFacebookGroups(context, accessToken, imageUrl);
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      print('Error during Facebook login: $e');
    }
  }

  // Method to fetch Facebook groups
  Future<void> _fetchFacebookGroups(
      BuildContext context, AccessToken accessToken, String imageUrl) async {
    final response = await FacebookAuth.instance.getUserData(
      fields: 'groups{name,id}',
    );

    if (response.containsKey('groups')) {
      List<dynamic> groups = response['groups']['data'];
      _showGroupsDialog(context, groups, imageUrl);
    } else {
      print('No groups found');
    }
  }

  // Method to show groups dialog
  void _showGroupsDialog(
      BuildContext context, List<dynamic> groups, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a Group'),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: groups.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(groups[index]['name']),
                  onTap: () {
                    Navigator.of(context).pop();
                    _postToGroup(groups[index]['id'], imageUrl);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Method to post to group
  Future<void> _postToGroup(String groupId, String imageUrl) async {
    final accessToken = (await FacebookAuth.instance.accessToken)!.token;
    final uri = Uri.https('graph.facebook.com', '/$groupId/photos', {
      'access_token': accessToken,
    });

    final response = await http.post(
      uri,
      body: {
        'url': imageUrl,
        'caption': 'Check out this image!',
      },
    );

    if (response.statusCode == 200) {
      print('Image posted to group successfully');
    } else {
      print('Failed to post image to group: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Colors.blue[200],
        actions: [
          IconButton(
            icon: CircleAvatar(
              backgroundImage: NetworkImage(widget.user.photoURL ?? ''),
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.user.displayName ?? 'Guest'),
              accountEmail: Text(widget.user.email ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(widget.user.photoURL ?? ''),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await GoogleSignIn().signOut();
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF73AEF5),
              Color(0xFF61A4F1),
              Color(0xFF478DE0),
              Color(0xFF398AE5),
            ],
            stops: [0.1, 0.4, 0.7, 0.9],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(16.0),
                children: List.generate(
                  _articles.length,
                  (index) {
                    return Card(
                      child: InkWell(
                        onTap: () {
                          _showPostDialog(
                              context, _articles[index]['urlToImage']!);
                        },
                        child: Image.network(
                          _articles[index]['urlToImage']!,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}
