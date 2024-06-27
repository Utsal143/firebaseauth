import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final User user;

  HomeScreen({required this.user});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _imageUrls = [];
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
          _imageUrls = articles
              .map<String>((article) => article['urlToImage']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .cast<String>()
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
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
              leading: Icon(Icons.logout),
              title: Text('Sign Out'),
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
        decoration: BoxDecoration(
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
            ? Center(child: CircularProgressIndicator())
            : GridView.count(
                crossAxisCount: 2,
                padding: EdgeInsets.all(16.0),
                children: List.generate(
                  _imageUrls.length,
                  (index) {
                    return Card(
                      child: InkWell(
                        onTap: () {},
                        child: Image.network(
                          _imageUrls[index],
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
