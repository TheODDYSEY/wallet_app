# Quick Fix Guide for My Pocket Wallet App

## 🔧 Common Issues and Solutions

### 1. **Compilation Errors**

If you encounter compilation errors, try these steps:

```bash
# Step 1: Clean the project
flutter clean

# Step 2: Get dependencies
flutter pub get

# Step 3: Run the app
flutter run
```

### 2. **Missing Dependencies**

If you see import errors, ensure all dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.2
  intl: ^0.19.0
  http: ^1.1.0
  dio: ^5.3.2
  animate_do: ^3.1.2
  lottie: ^2.7.0
  shimmer: ^3.0.0
  connectivity_plus: ^5.0.2
  local_auth: ^2.1.6
  google_fonts: ^6.1.0
  pin_code_fields: ^8.0.1
  flutter_secure_storage: ^9.0.0
  uuid: ^4.2.1
  cached_network_image: ^3.3.0
  fl_chart: ^0.65.0
```

### 3. **Android Build Issues**

If Android build fails, check these files:

**android/app/build.gradle.kts:**
```kotlin
android {
    compileSdk = 34
    ndkVersion = "27.0.12077973"
    
    defaultConfig {
        minSdk = 23
        targetSdk = 34
    }
}
```

**android/app/src/main/AndroidManifest.xml:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.USE_FINGERPRINT" />
<uses-permission android:name="android.permission.USE_BIOMETRIC" />
```

### 4. **Simple App Version (If Enhanced Version Has Issues)**

If the enhanced version with MongoDB has too many issues, you can use the basic version by:

1. **Remove complex dependencies** from `pubspec.yaml`:
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.2
  intl: ^0.19.0
```

2. **Use basic login screen** instead of enhanced:
```dart
// In lib/screens/loginscreen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _authenticateWithPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('user_pin');

    await Future.delayed(const Duration(seconds: 1));

    if (savedPin == null) {
      await prefs.setString('user_pin', pin);
      await prefs.setBool('isLoggedIn', true);
      _navigateToDashboard();
    } else {
      if (savedPin == pin) {
        await prefs.setBool('isLoggedIn', true);
        _navigateToDashboard();
      } else {
        setState(() {
          _errorMessage = 'Invalid PIN. Please try again.';
          _pinController.clear();
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToDashboard() {
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Enter PIN',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 8),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: '••••',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                counterText: '',
              ),
              onChanged: (value) {
                if (value.length == 4) {
                  _authenticateWithPin(value);
                }
              },
            ),
            if (_errorMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            ],
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
```

### 5. **Basic Main Dashboard**

If enhanced dashboard has issues, use basic version:

```dart
// In lib/screens/maindashboard.dart
import 'package:flutter/material.dart';
import '../widgets/bottomNavigationWidget.dart';
import 'home_page.dart';
import '../classes/messages.dart';
import '../classes/setiings.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const MessagesPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationWidget(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
```

### 6. **Testing Commands**

```bash
# Check Flutter installation
flutter doctor

# Check for issues
flutter analyze

# Run on specific device
flutter devices
flutter run -d <device-id>

# Build APK
flutter build apk

# Build for release
flutter build apk --release
```

### 7. **Common Error Solutions**

**Error: "SharedPreferences not found"**
- Solution: Add `import 'package:shared_preferences/shared_preferences.dart';`

**Error: "Animation packages not found"**
- Solution: Run `flutter pub get` to install all dependencies

**Error: "SDK version issues"**
- Solution: Check `pubspec.yaml` has correct SDK version: `sdk: ^3.5.3`

**Error: "Android build failed"**
- Solution: Update `android/app/build.gradle.kts` with correct SDK versions

### 8. **Fallback Options**

If all else fails, you can:

1. Start with a new Flutter project: `flutter create wallet_app`
2. Copy over the working screens one by one
3. Test each screen individually
4. Add features incrementally

## 🎯 Minimal Working Version

For a guaranteed working version, use only these dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.3.2
  intl: ^0.19.0
```

This will give you a basic but functional wallet app without the advanced features.
