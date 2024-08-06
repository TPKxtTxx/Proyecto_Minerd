import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<dynamic> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    final response = await http.get(Uri.parse('https://adamix.net/minerd/def/noticias.php'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _news = data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      throw Exception('Failed to load news');
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Noticias MINERD'),
        backgroundColor: Color(0xFF0033A0), // Azul
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _news.length,
              itemBuilder: (context, index) {
                final newsItem = _news[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (newsItem['image'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(newsItem['image']),
                        ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem['title'],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              newsItem['description'],
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Leer más',
                              style: TextStyle(color: Colors.blue, fontSize: 14),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 5),
                            Divider(),
                            SizedBox(height: 5),
                            Text(
                              newsItem['content'],
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      if (newsItem['link'] != null)
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: TextButton(
                            onPressed: () => _launchURL(newsItem['link']),
                            child: Text('Leer más en el sitio', style: TextStyle(color: Colors.blue)),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
