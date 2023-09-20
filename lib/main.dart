import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sazamtomp3/constants/routes.dart';
import 'package:sazamtomp3/screens/first_screen.dart';
import 'package:sazamtomp3/screens/search_screen.dart';
import 'package:sazamtomp3/screens/song_screen.dart';

Future<void> initialize() async {
  await dotenv.load(fileName: '.env');
}

void main() async {
  
  await initialize();

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(
    title: 'Sazam To Mp3',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    initialRoute: firstScreenRoute,
    routes: {
      firstScreenRoute: (context) => const FirstScreen(),
      searchScreenRoute: (context) => const SearchScreen(),
      songScreenRoute: (context) => const SongScreen(),
    },
  ));
}
