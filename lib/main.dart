import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? image;
  final picker = ImagePicker();
  final desc = TextEditingController();

  Future pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked != null) {
      setState(() => image = File(picked.path));
      showDialog(context: context, builder: (_) => dialog());
    }
  }

  Widget dialog() {
    return AlertDialog(
      title: Text("Add Memory"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.file(image!, height: 120),
          TextField(controller: desc),
          ElevatedButton(onPressed: upload, child: Text("Save"))
        ],
      ),
    );
  }

  Future upload() async {
    final ref = FirebaseStorage.instance
        .ref("memories/${DateTime.now()}.jpg");

    await ref.putFile(image!);

    String url = await ref.getDownloadURL();

    FirebaseFirestore.instance.collection("memories").add({
      "image": url,
      "desc": desc.text,
      "time": Timestamp.now()
    });

    desc.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Memorie")),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera),
        onPressed: pickImage,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("memories")
            .orderBy("time", descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData)
            return Center(child: CircularProgressIndicator());

          return ListView(
            children: snap.data!.docs.map((d) {
              return Card(
                child: Column(
                  children: [
                    Image.network(d["image"]),
                    Text(d["desc"])
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
