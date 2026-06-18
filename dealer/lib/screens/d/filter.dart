import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class newpage extends StatefulWidget {
  const newpage({super.key});
  @override
  State<newpage> createState() => _newpageState();
}

class _newpageState extends State<newpage> {
  List comments = [];
  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    final response = await http.get(Uri.parse("http://localhost:3001/product"));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        comments = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: comments.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(10),

              child: ListTile(
                leading: CircleAvatar(
                  child: Text(comments[index]["id"].toString()),
                ),

                title: Text(comments[index]["name"]),

                subtitle: Text(comments[index]["email"]),
                selectedTileColor: Colors.blue,
                onTap: () => showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Container(
                        margin: EdgeInsets.all(10),
                        height: 500,
                        width: 400,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text("Name: ${comments[index]["name"]}"),
                            SizedBox(height: 10),
                            Text("Email : ${comments[index]["email"]}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
