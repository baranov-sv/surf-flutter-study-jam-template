import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:surf_practice_chat_flutter/data/chat/repository/firebase.dart';
import 'package:surf_practice_chat_flutter/firebase_options.dart';
import 'package:surf_practice_chat_flutter/screens/chat.dart';
import 'package:surf_practice_chat_flutter/data/chat/application_state.dart';
import 'package:surf_practice_chat_flutter/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform(
      androidKey: 'AIzaSyD5bCOfO29kCv2mIdmYa6CEKhud4Gs1YIU',
      iosKey: 'enter ios key here',
      webKey: 'enter web key here',
    ),
  );

  final chatRepository = ChatRepositoryFirebase(FirebaseFirestore.instance);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(chatRepository),
      builder: (context, _) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: ColorConstants.themeColor,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
