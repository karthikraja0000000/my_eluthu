import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../../utils/constant_color.dart';
import '../../../utils/app_prefs.dart';
import '../../home/pages/home_page.dart';

class LockPage extends StatefulWidget {
  const LockPage({super.key});

  @override
  State<LockPage> createState() => _LockPageState();
}

class _LockPageState extends State<LockPage> {
  String _enteredPin = "";
  String? _storedPin;
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _initLock();
  }

  Future<void> _initLock() async {
    _storedPin = await AppPrefs.getPin();
    // Default PIN if none set
    _storedPin ??= "1234";

    try {
      _canCheckBiometrics = await auth.canCheckBiometrics;
      final isBioEnabled = await AppPrefs.isBiometricEnabled();

      if (_canCheckBiometrics && isBioEnabled) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      debugPrint("Biometric error: $e");
    }
    if (mounted) setState(() {});
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to open your diary',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated && mounted) {
        _onAuthenticated();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onAuthenticated() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DiaryHomePage()),
    );
  }

  void _handleNumberClick(String number) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += number;
      });
    }

    if (_enteredPin.length == 4) {
      Future.delayed(const Duration(milliseconds: 200), _verifyPin);
    }
  }

  void _verifyPin() {
    if (_enteredPin == _storedPin) {
      _onAuthenticated();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incorrect PIN"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _enteredPin = "";
      });
    }
  }

  void _handleBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 60.h),
            Icon(
              Icons.lock_outline,
              size: 64.sp,
              color: AppColors.primaryAccent,
            ),
            SizedBox(height: 24.h),
            Text(
              "Enter PIN",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
                fontFamily: 'Georgia',
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              _storedPin == "1234"
                  ? "Default PIN is 1234"
                  : "Unlock your diary",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.bodyText.withOpacity(0.5),
              ),
            ),
            SizedBox(height: 40.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.w),
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryAccent),
                    color: index < _enteredPin.length
                        ? AppColors.primaryAccent
                        : Colors.transparent,
                  ),
                );
              }),
            ),
            const Spacer(),
            _buildKeypad(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['biometrics', '0', 'backspace'],
        ])
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key == 'biometrics') {
                  return SizedBox(
                    width: 70.w,
                    height: 70.w,
                    child: _canCheckBiometrics
                        ? IconButton(
                            onPressed: _authenticateWithBiometrics,
                            icon: Icon(Icons.fingerprint, size: 32.sp),
                            color: AppColors.primaryAccent,
                          )
                        : const SizedBox(),
                  );
                }
                if (key == 'backspace') {
                  return SizedBox(
                    width: 70.w,
                    height: 70.w,
                    child: IconButton(
                      onPressed: _handleBackspace,
                      icon: Icon(Icons.backspace_outlined, size: 28.sp),
                      color: AppColors.primaryAccent,
                    ),
                  );
                }
                return InkWell(
                  onTap: () => _handleNumberClick(key),
                  borderRadius: BorderRadius.circular(40.r),
                  child: Container(
                    width: 70.w,
                    height: 70.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryAccent.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      key,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryAccent,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
