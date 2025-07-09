import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/utils.dart';
import 'maindashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  String _errorMessage = '';
  bool _isFirstTime = true;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _checkBiometricAvailability();
    _checkFirstTimeUser();
  }

  void _initAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      setState(() {
        _isBiometricAvailable = isAvailable && isDeviceSupported;
      });
    } catch (e) {
      setState(() {
        _isBiometricAvailable = false;
      });
    }
  }

  Future<void> _checkFirstTimeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasPin = prefs.getString('user_pin') != null;
      setState(() {
        _isFirstTime = !hasPin;
      });
    } catch (e) {
      setState(() {
        _isFirstTime = true;
      });
    }
  }

  Future<void> _authenticateWithBiometric() async {
    try {
      UIUtils.hapticFeedback();
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your wallet',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (isAuthenticated) {
        _navigateToDashboard();
      }
    } catch (e) {
      UIUtils.showSnackBar(
        context,
        'Biometric authentication failed: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _authenticateWithPin(String pin) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      if (_isFirstTime) {
        // First time setup - save the PIN
        await prefs.setString('user_pin', pin);
        await prefs.setBool('isLoggedIn', true);

        UIUtils.showSuccessDialog(
          context,
          'PIN Set Successfully',
          'Your PIN has been set. You can now use it to access your wallet.',
          onOk: _navigateToDashboard,
        );
      } else {
        // Verify PIN
        final savedPin = prefs.getString('user_pin');

        await Future.delayed(
            const Duration(milliseconds: 800)); // Simulate API call

        if (pin == savedPin) {
          await prefs.setBool('isLoggedIn', true);
          _navigateToDashboard();
        } else {
          _showPinError('Incorrect PIN. Please try again.');
          _shakeController.forward().then((_) {
            _shakeController.reset();
          });
        }
      }
    } catch (e) {
      _showPinError('Authentication failed. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPinError(String message) {
    setState(() {
      _errorMessage = message;
    });
    _pinController.clear();
    UIUtils.hapticFeedback();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      UIUtils.createRoute(const MainDashboard()),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo and Title
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 50,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your PIN to access your wallet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF718096),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // PIN Input
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Enter PIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        obscureText: true,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          hintText: '••••',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _errorMessage = '';
                          });
                          if (value.length == 4) {
                            _authenticateWithPin(value);
                          }
                        },
                      ),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Biometric Authentication
                if (_isBiometricAvailable)
                  Column(
                    children: [
                      const Text(
                        'Or use biometric authentication',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF718096),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _authenticateWithBiometric,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E88E5),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E88E5).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 0,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.fingerprint,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                const Spacer(),

                // Loading Indicator
                if (_isLoading)
                  const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
