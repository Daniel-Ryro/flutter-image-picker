import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Dio dio = Dio();
  List<dynamic> users = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Ocorreu um erro"));
          } else if (snapshot.hasData) {
            users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> userData = users[index];
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '${userData['name']['title']} ${userData['name']['first']} ${userData['name']['last']}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(userData['gender']),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(userData['picture']['medium']),
                        ),
                        trailing: index == 0
                            ? ElevatedButton(
                                onPressed: () => _editProfilePic(index),
                                child: const Text('Editar'),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text('Email: ${userData['email']}'),
                      Text('Idade: ${userData['dob']['age']}'),
                      Text(
                          'Endereço: ${userData['location']['street']['number']} ${userData['location']['street']['name']}, ${userData['location']['city']}, ${userData['location']['state']}, ${userData['location']['country']}'),
                      Text('Telefone: ${userData['phone']}'),
                    ],
                  ),
                );
              },
            );
          } else {
            return const Text('Erro');
          }
        },
      ),
    );
  }

  Future<List<dynamic>> fetchData() async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.get('https://randomuser.me/api/?results=10');
      List<dynamic> results = response.data!['results'];
      return results;
    } catch (error) {
      throw Exception('Erro');
    }
  }

  Future<void> _editProfilePic(int index) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      final imagePath = image.path;
      setState(() {
        users[index].imagePath = imagePath;
      });
      print("Nova imagem: $imagePath");
    }
  }
}
