import 'package:bookedin_app/core/DI/injection_container.dart';
import 'package:bookedin_app/features/admin/presentation/pages/admin_portal.dart';
import 'package:bookedin_app/features/auth/presentation/pages/login_page.dart';
import 'package:bookedin_app/features/staff_user/presentation/pages/book_room.dart';
import 'package:bookedin_app/features/staff_user/presentation/pages/staff_portal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
      navigatorKey: navigatorKey,
      routes: {
        LoginPage.route: (context) => LoginPage(),
        AdminPortal.route: (context) => AdminPortal(),
        StaffPortal.route: (context) => StaffPortal(),
        BookRoom.route: (context) => BookRoom(),
      },
    );
  }
}
