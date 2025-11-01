import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:madarsago/home_screen.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _isOtpSent = false;
  bool _isLoading = false;
  String _phoneNumber = '';
  String? _errorText;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _verificationId = '';
  int? _resendToken;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getFriendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'invalid-verification-code':
        return 'Invalid OTP. Please try again.';
      case 'session-expired':
        return 'The OTP has expired. Please send a new one.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'An unknown error occurred.';
    }
  }

  Future<void> _createUserDocumentInFirestore(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      await userRef.set({
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
        'role': 'viewer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  void _onSendOtp() async {
    if (_phoneNumber.isEmpty) {
      setState(() => _errorText = 'Please enter a valid phone number');
      return;
    }
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          await _createUserDocumentInFirestore(_auth.currentUser);
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _errorText = _getFriendlyError(e);
            _isLoading = false;
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isOtpSent = true;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      setState(() {
        _errorText = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onVerifyOtp(String pin) async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: pin,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      await _createUserDocumentInFirestore(userCredential.user);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorText = _getFriendlyError(e);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorText = 'An unexpected error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color inputFillColor = isDarkMode
        ? Colors.white.withAlpha(13)
        : Colors.black.withAlpha(10);
    final Color borderColor = isDarkMode
        ? Colors.grey[800]!
        : Colors.grey[300]!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDarkMode
            ? Brightness.light
            : Brightness.dark,
        statusBarBrightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDarkMode ? appDarkColor : Colors.white,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32.0),
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/images/login.webp',
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          _isOtpSent ? 'Verify Your Number' : 'Welcome!',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontFamily: 'Bold',
                            fontSize: 18, // CHANGED
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isOtpSent
                              ? 'Enter the 6-digit code sent to $_phoneNumber'
                              : 'Enter your phone number to continue and find the light of Deen.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontFamily: 'TagRegular',
                            fontSize: 15, // CHANGED: 16 se 15
                            height: 1.5,
                          ),
                        ),
                        if (_isOtpSent)
                          Align(
                            alignment: Alignment.center,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isOtpSent = false;
                                  _errorText = null;
                                });
                              },
                              child: Text(
                                'Change Number',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Bold',
                                  color: appPrimaryColor,
                                  fontSize: 14.5, // CHANGED
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 32),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          child: _isOtpSent
                              ? _buildOtpInput(
                                  textTheme,
                                  inputFillColor,
                                  borderColor,
                                )
                              : _buildPhoneInput(
                                  textTheme,
                                  isDarkMode,
                                  inputFillColor,
                                  borderColor,
                                ),
                        ),
                        if (_errorText != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _errorText!,
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.redAccent,
                              fontFamily: 'Regular',
                              fontSize: 11.5, // CHANGED
                            ),
                          ),
                        ],
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isOtpSent ? null : _onSendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Bold',
                              fontSize: 15, // CHANGED: 16 se 15
                            ),
                            elevation: 0,
                            shadowColor: appPrimaryColor.withAlpha(100),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Text(_isOtpSent ? 'Verify' : 'Send OTP'),
                        ),
                        if (_isOtpSent) _buildResendOtp(textTheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(
    TextTheme textTheme,
    bool isDarkMode,
    Color inputFillColor,
    Color borderColor,
  ) {
    return IntlPhoneField(
      key: const ValueKey('phone-input'),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        counterText: '',
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontFamily: 'Regular',
          fontSize: 14.5,
        ), // CHANGED
        filled: true,
        fillColor: inputFillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: appPrimaryColor, width: 2),
        ),
      ),
      initialCountryCode: 'IN',
      style: textTheme.bodyMedium?.copyWith(
        fontFamily: 'Regular',
        fontSize: 14.5,
      ), // CHANGED
      onChanged: (phone) {
        _phoneNumber = phone.completeNumber;
      },
      pickerDialogStyle: PickerDialogStyle(
        backgroundColor: isDarkMode ? appDarkColor : Colors.white,
        searchFieldInputDecoration: InputDecoration(
          labelText: 'Search country',
          labelStyle: textTheme.bodyMedium?.copyWith(
            fontFamily: 'Regular',
            fontSize: 14.5,
          ), // CHANGED
          filled: true,
          fillColor: inputFillColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: appPrimaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpInput(
    TextTheme textTheme,
    Color inputFillColor,
    Color borderColor,
  ) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: textTheme.headlineSmall?.copyWith(
        fontFamily: 'Bold',
        fontSize: 22,
      ), // CHANGED
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: appPrimaryColor, width: 2),
      ),
    );

    return Pinput(
      key: const ValueKey('otp-input'),
      length: 6,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      autofocus: true,
      onCompleted: (pin) => _onVerifyOtp(pin),
      onChanged: (value) {
        if (_errorText != null) {
          setState(() => _errorText = null);
        }
      },
    );
  }

  Widget _buildResendOtp(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 24.0),
        child: TextButton(
          onPressed: _isLoading ? null : _onSendOtp,
          child: Text(
            'Didn\'t receive code? Resend',
            style: textTheme.bodyMedium?.copyWith(
              fontFamily: 'Bold',
              color: appPrimaryColor,
              fontSize: 14.5, // CHANGED
            ),
          ),
        ),
      ),
    );
  }
}
