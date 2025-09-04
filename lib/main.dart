import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rabbitrating/screens/rattingscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<double>('ratings'); // box to store ratings
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rating App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: RatingScreen(),
    );
  }
}
