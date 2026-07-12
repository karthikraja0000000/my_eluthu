import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constant_color.dart';
import '../../lock/pages/lock_page.dart';
import '../../home/pages/home_page.dart';
import '../../../utils/app_prefs.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final pin = await AppPrefs.getPin();

    if (pin != null && pin.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LockPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DiaryHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 80.sp,
                color: AppColors.primaryAccent,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'My Eluthu',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                fontFamily: 'Georgia',
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your Personal Digital Diary',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.bodyText.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            SizedBox(height: 48.h),
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
