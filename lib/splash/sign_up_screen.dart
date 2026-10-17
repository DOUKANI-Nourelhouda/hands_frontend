import 'package:flutter/material.dart';
import 'package:hands/main/main.dart';
import 'package:hands/splash/sign_in_screen.dart';
import 'package:hands/widgets/residencedrowp.dart';
import 'package:hands/services/residence_service.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedResidence;
  String? selectedWilaya;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  List<Map<String, dynamic>> residences = [];
  bool isLoadingResidences = false;
  String? residenceError;

  final AuthService _authService = AuthService();
  bool isRegistering = false;

  String? usernameError;
  String? emailError;
  String? passwordError;
  String? wilayaError;
  String? residenceErrorMessage;
  String? generalError;

  Future<void> _handleSignUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    setState(() {
      usernameError = null;
      emailError = null;
      passwordError = null;
      wilayaError = null;
      residenceErrorMessage = null;
      generalError = null;
    });

    bool hasError = false;

    if (username.length < 3) {
      usernameError = 'Username must contain at least 3 characters.';
      hasError = true;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      emailError = 'Please enter a valid email address.';
      hasError = true;
    }

    if (password.length < 6) {
      passwordError = 'Password must contain at least 6 characters.';
      hasError = true;
    }

    if (selectedWilaya == null) {
      wilayaError = 'Please select your Wilaya.';
      hasError = true;
    }

    if (selectedResidence == null) {
      residenceErrorMessage = 'Please select your residence.';
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        residence: selectedResidence!,
      );

      if (!mounted) return;

      // Existing verified account: successful login
      if (result['loginSuccess'] == true) {
        final token = await AuthService().getSavedToken();

        if (token == null || token.isEmpty) {
          throw Exception('Authentication token was not saved.');
        }

        final postService = PostService(
          baseUrl: AuthService.baseUrl,
          token: token,
        );

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(postService: postService),
          ),
        );

        return;
      }

      // Existing email, but verification is still pending
      if (result['verificationEmailSent'] == true) {
        await _showSignupResultDialog(
          title: 'Check Your Email',
          message:
              result['message']?.toString() ??
              'Your account already exists, but your email is not verified. '
                  'We have sent you a new verification email.',
        );

        return;
      }

      // New account created successfully
      await _showSignupResultDialog(
        title: 'Account Created Successfully!',
        message:
            result['message']?.toString() ??
            'Please verify your email address using the link we sent you.',
      );
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst('Exception: ', '');
      final lowerMessage = message.toLowerCase();

      if (lowerMessage.contains('device') ||
          lowerMessage.contains('already registered')) {
        await _showSignupResultDialog(
          title: 'Account Already Exists',
          message:
              'An account is already registered on this device. '
              'Please sign in with your existing account.',
          icon: Icons.person_outline,
        );
      } else if (lowerMessage.contains('email not verified')) {
        await _showSignupResultDialog(
          title: 'Verify Your Email',
          message:
              'Your account already exists, but your email is not verified. '
              'Please check your inbox for the verification link.',
        );
      } else {
        setState(() {
          if (lowerMessage.contains('username')) {
            usernameError = message;
          } else if (lowerMessage.contains('email')) {
            emailError = message;
          } else if (lowerMessage.contains('password')) {
            passwordError = message;
          } else if (lowerMessage.contains('residence')) {
            residenceErrorMessage = message;
          } else {
            generalError = message;
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
        });
      }
    }
  }

  Future<void> loadResidences(String wilaya) async {
    setState(() {
      isLoadingResidences = true;
      residenceError = null;
      residences = [];
    });

    try {
      final result = await ResidenceService.getByWilaya(wilaya);

      if (!mounted || selectedWilaya != wilaya) return;

      setState(() {
        residences = result;
        isLoadingResidences = false;
      });
    } catch (error) {
      if (!mounted || selectedWilaya != wilaya) return;

      setState(() {
        isLoadingResidences = false;
        residenceError = 'Could not load residences. Please try again.';
      });
    }
  }

  Widget _buildErrorText(String? error) {
    if (error == null || error.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          error,
          style: const TextStyle(color: Color(0xfffcc001), fontSize: 12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ================= HEADER =================
              SizedBox(
                width: double.infinity,
                height: 260,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        'assets/sbigha_sghira.png',
                        fit: BoxFit.cover,
                      ),
                    ),

                    Positioned(
                      top: 37,
                      left: 3,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 20),

                          Image.asset(
                            'assets/logo_exct_white.png',
                            width: 90,
                            height: 90,
                          ),

                          const SizedBox(width: 10),

                          const Text(
                            'Welcome',
                            style: TextStyle(
                              fontSize: 55,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 35),

              // ================= FIELDS =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    _buildField(
                      controller: usernameController,
                      hint: 'Username',
                      icon: Icons.person_outline,
                    ),
                    _buildErrorText(usernameError),

                    const SizedBox(height: 15),

                    _buildField(
                      controller: emailController,
                      hint: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildErrorText(emailError),
                    const SizedBox(height: 15),

                    _buildField(
                      controller: passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: const Color(0xfffcc001),
                        ),
                      ),
                    ),
                    _buildErrorText(passwordError),
                    const SizedBox(height: 15),

                    WilayaDropdown(
                      selectedWilaya: selectedWilaya,
                      wilayas: const [
                        'Adrar',
                        'Chlef',
                        'Laghouat',
                        'Oum El Bouaghi',
                        'Batna',
                        'Béjaïa',
                        'Biskra',
                        'Béchar',
                        'Blida',
                        'Bouira',
                        'Tamanrasset',
                        'Tébessa',
                        'Tlemcen',
                        'Tiaret',
                        'Tizi Ouzou',
                        'Alger',
                        'Djelfa',
                        'Jijel',
                        'Sétif',
                        'Saïda',
                        'Skikda',
                        'Sidi Bel Abbès',
                        'Annaba',
                        'Guelma',
                        'Constantine',
                        'Médéa',
                        'Mostaganem',
                        'M’Sila',
                        'Mascara',
                        'Ouargla',
                        'Oran',
                        'El Bayadh',
                        'Illizi',
                        'Bordj Bou Arréridj',
                        'Boumerdès',
                        'El Tarf',
                        'Tindouf',
                        'Tissemsilt',
                        'El Oued',
                        'Khenchela',
                        'Souk Ahras',
                        'Tipaza',
                        'Mila',
                        'Aïn Defla',
                        'Naâma',
                        'Aïn Témouchent',
                        'Ghardaïa',
                        'Relizane',
                        'Timimoun',
                        'Bordj Badji Mokhtar',
                        'Ouled Djellal',
                        'Béni Abbès',
                        'In Salah',
                        'In Guezzam',
                        'Touggourt',
                        'Djanet',
                        'El M’Ghair',
                        'El Meniaa',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedWilaya = value;
                          selectedResidence = null;
                          residences = [];
                          residenceError = null;
                        });

                        if (value != null) {
                          loadResidences(value);
                        }
                      },
                    ),
                    _buildErrorText(wilayaError),
                    const SizedBox(height: 15),

                    ResidenceDropdown(
                      selectedResidenceId: selectedResidence,
                      residences: residences,
                      enabled: selectedWilaya != null && !isLoadingResidences,
                      loading: isLoadingResidences,
                      error: residenceError,
                      onChanged: (value) {
                        setState(() {
                          selectedResidence = value;
                        });
                      },
                    ),
                    _buildErrorText(residenceError),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: isRegistering ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfffcc001),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 15, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xfffcc001),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      cursorColor: Colors.black,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 17),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xfffcc001), size: 28),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 17,
          horizontal: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xfffcc001), width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xfffcc001), width: 3),
        ),
      ),
    );
  }

  Future<void> _showSignupResultDialog({
    required String title,
    required String message,
    IconData icon = Icons.mark_email_read_outlined,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: Icon(icon, color: const Color(0xfffcc001), size: 50),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xfffcc001),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: const Text(
                'Got it',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WilayaDropdown extends StatefulWidget {
  final String? selectedWilaya;
  final List<String> wilayas;
  final ValueChanged<String?> onChanged;

  const WilayaDropdown({
    super.key,
    required this.selectedWilaya,
    required this.wilayas,
    required this.onChanged,
  });

  @override
  State<WilayaDropdown> createState() => _WilayaDropdownState();
}

class _WilayaDropdownState extends State<WilayaDropdown> {
  final GlobalKey _key = GlobalKey();

  Future<void> _openDropdown() async {
    final RenderBox renderBox =
        _key.currentContext!.findRenderObject() as RenderBox;

    final Offset position = renderBox.localToGlobal(Offset.zero);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height + 5,
        position.dx + renderBox.size.width,
        0,
      ),
      color: Colors.white,
      elevation: 8,

      // Yellow rounded border for the opened list
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xfffcc001), width: 2.5),
      ),

      items: widget.wilayas.map((wilaya) {
        return PopupMenuItem<String>(
          value: wilaya,
          child: SizedBox(
            width: renderBox.size.width - 30,
            child: Text(
              wilaya,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openDropdown,
      child: Container(
        key: _key,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xfffcc001), width: 2.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            const Icon(
              Icons.location_on_outlined,
              color: Color(0xfffcc001),
              size: 30,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                widget.selectedWilaya ?? 'Wilaya',
                style: TextStyle(
                  fontSize: 16,
                  color: widget.selectedWilaya == null
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_drop_down,
              color: Color(0xfffcc001),
              size: 30,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
