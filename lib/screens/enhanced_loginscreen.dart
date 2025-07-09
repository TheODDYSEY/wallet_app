import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/utils.dart';
import 'maindashboard.dart';
import 'signin.dart';

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
  late Animation<double> _shakeAnimation;

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

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticIn,
    ));
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

  void _navigateToSignUp() {
    Navigator.of(context).push(
      UIUtils.createRoute(const SignInScreen()),
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Header Animation
              FadeInDown(
                duration: const Duration(milliseconds: 800),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E88E5).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.security,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _isFirstTime ? 'Set Your PIN' : 'Welcome Back',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isFirstTime
                          ? 'Create a 4-digit PIN to secure your wallet'
                          : 'Enter your PIN to continue',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718096),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // PIN Input Animation
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Column(
                        children: [
                          PinCodeTextField(
                            appContext: context,
                            length: 4,
                            controller: _pinController,
                            onChanged: (value) {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                            onCompleted: (value) {
                              if (!_isLoading) {
                                _authenticateWithPin(value);
                              }
                            },
                            pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(12),
                              fieldHeight: 60,
                              fieldWidth: 60,
                              borderWidth: 2,
                              activeColor: const Color(0xFF1E88E5),
                              inactiveColor: const Color(0xFFE1E8ED),
                              selectedColor: const Color(0xFF1E88E5),
                              activeFillColor: Colors.white,
                              inactiveFillColor: Colors.white,
                              selectedFillColor: Colors.white,
                            ),
                            enableActiveFill: true,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            obscuringCharacter: '●',
                            animationType: AnimationType.fade,
                            animationDuration:
                                const Duration(milliseconds: 300),
                          ),
                          if (_errorMessage.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            FadeIn(
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              // Loading Indicator
              if (_isLoading)
                FadeIn(
                  child: const CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  ),
                ),

              const SizedBox(height: 40),

              // Biometric Authentication Button
              if (_isBiometricAvailable && !_isFirstTime)
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _authenticateWithBiometric,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Use Biometric'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E88E5),
                        elevation: 2,
                        side: const BorderSide(
                          color: Color(0xFF1E88E5),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 60),

              // Sign Up Link
              if (_isFirstTime)
                FadeInUp(
                  duration: const Duration(milliseconds: 800),
                  delay: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: _navigateToSignUp,
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
