import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'features/splash/pages/splash_page.dart';

void main() {
  runApp(const MyEluthu());
}

class MyEluthu extends StatelessWidget {
  const MyEluthu({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 14 base design
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Georgia',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF3E2723),
              brightness: Brightness.light,
            ),
          ),
          home: child,
        );
      },
      child: const SplashPage(),
    );
  }
}
