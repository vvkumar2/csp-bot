import 'package:flutter/material.dart';
import 'package:frontend/data/learning_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CollectionReference collection =
      FirebaseFirestore.instance.collection('learning');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
          onPressed: () async {
            for (var item in learningData) {
              await collection.add(item);
            }
            print('Data added successfully!');
          },
          child: const Text('Upload to Firestore',
              style: TextStyle(fontSize: 20, color: Colors.white)),
        ),
      ),
    ));
  }
}
