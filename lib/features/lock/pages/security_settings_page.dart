import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:local_auth/local_auth.dart';
import '../../../utils/constant_color.dart';
import '../../../utils/app_prefs.dart';

class SecuritySettingsPage extends StatefulWidget {
  const SecuritySettingsPage({super.key});

  @override
  State<SecuritySettingsPage> createState() => _SecuritySettingsPageState();
}

class _SecuritySettingsPageState extends State<SecuritySettingsPage> {
  final TextEditingController _pinController = TextEditingController();
  bool _biometricEnabled = false;
  bool _canCheckBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final pin = await AppPrefs.getPin();
    _biometricEnabled = await AppPrefs.isBiometricEnabled();
    _canCheckBiometrics = await auth.canCheckBiometrics;
    if (pin != null) {
      _pinController.text = pin;
    }
    if (mounted) setState(() {});
  }

  Future<void> _savePin() async {
    if (_pinController.text.length == 4) {
      await AppPrefs.setPin(_pinController.text);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("PIN saved successfully")));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("PIN must be 4 digits")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: const Text("Security Settings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.primaryAccent,
      ),
      body: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Custom PIN",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryAccent,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                hintText: "Enter 4-digit PIN",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _savePin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save PIN"),
            ),
            SizedBox(height: 30.h),
            if (_canCheckBiometrics)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Enable Biometrics",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  Switch(
                    value: _biometricEnabled,
                    activeColor: AppColors.primaryAccent,
                    onChanged: (val) async {
                      await AppPrefs.setBiometricEnabled(val);
                      setState(() {
                        _biometricEnabled = val;
                      });
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
