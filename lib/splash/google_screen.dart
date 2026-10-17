import 'package:flutter/material.dart';
import 'package:hands/main/main.dart';
import 'package:hands/widgets/residencedrowp.dart';
import 'package:hands/services/residence_service.dart';
import 'package:hands/services/google_auth_service.dart';
import 'package:hands/services/auth_service.dart';
import 'package:hands/services/post_service.dart';

class GoogleScreen extends StatefulWidget {
  const GoogleScreen({super.key});

  @override
  State<GoogleScreen> createState() => _GooglePageState();
}

class _GooglePageState extends State<GoogleScreen> {
  String? selectedResidence; // MongoDB ID
  String? selectedWilaya;
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  List<Map<String, dynamic>> residences = [];
  bool isLoadingResidences = false;
  String? residenceError;

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

  Future<void> _showGoogleSignInError(Object error) async {
    final errorText = error.toString();
    final message = errorText.toLowerCase();

    // Device already linked to an existing account.
    if (message.contains('device') &&
        (message.contains('already') ||
            message.contains('registered') ||
            message.contains('exists'))) {
      await _showResultDialog(
        title: 'Account Already Exists',
        message:
            'An account is already registered on this device. '
            'Please sign in with your existing account.',
        icon: Icons.person_outline,
      );
      return;
    }

    // Email already associated with an account.
    if (message.contains('email') &&
        (message.contains('already') ||
            message.contains('registered') ||
            message.contains('exists') ||
            message.contains('in use'))) {
      await _showResultDialog(
        title: 'Email Already Registered',
        message:
            'This email is already associated with an account. '
            'Please sign in with that account instead.',
        icon: Icons.email_outlined,
      );
      return;
    }

    // Google account authentication or token errors.
    if (message.contains('token') ||
        message.contains('credential') ||
        message.contains('google sign-in') ||
        message.contains('google signin') ||
        message.contains('401') ||
        message.contains('403')) {
      await _showResultDialog(
        title: 'Google Sign-In Failed',
        message:
            'We could not authenticate your Google account. '
            'Please try again or choose another Google account.',
        icon: Icons.g_mobiledata,
      );
      return;
    }

    // Network or server errors.
    if (message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('connection refused') ||
        message.contains('timed out') ||
        message.contains('timeout') ||
        message.contains('500') ||
        message.contains('502') ||
        message.contains('503')) {
      await _showResultDialog(
        title: 'Connection Problem',
        message:
            'We could not connect to the server. '
            'Check your internet connection and try again.',
        icon: Icons.wifi_off_outlined,
      );
      return;
    }

    // Fallback for other errors.
    await _showResultDialog(
      title: 'Sign-In Failed',
      message:
          'Something went wrong while signing in with Google. '
          'Please try again. If the problem continues, contact support.',
      icon: Icons.error_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
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
                      left: 25,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 20),
                          Image.asset(
                            'assets/logo_exct_white.png',
                            width: 100,
                            height: 100,
                          ),

                          const SizedBox(width: 13),

                          const Text(
                            'Hands',
                            style: TextStyle(
                              fontSize: 57,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 85),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    WilayaDropdown(
                      selectedWilaya: selectedWilaya,
                      wilayas: const [
                        // Keep your complete list of 58 wilayas here.
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

                    SizedBox(height: 15),

                    const SizedBox(height: 80),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xfffcc001),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          // Validate the residence selection.
                          if (selectedWilaya == null ||
                              selectedResidence == null) {
                            await _showResultDialog(
                              title: 'Select Your Residence',
                              message:
                                  'Please select your Wilaya and university residence '
                                  'before continuing with Google.',
                              icon: Icons.location_on_outlined,
                            );
                            return;
                          }

                          try {
                            await _googleAuthService.signIn(
                              residence: selectedResidence!,
                            );

                            if (!mounted) return;

                            final token = await AuthService().getSavedToken();

                            if (token == null || token.isEmpty) {
                              await _showResultDialog(
                                title: 'Sign-In Failed',
                                message:
                                    'Your sign-in could not be completed because the '
                                    'authentication token was not saved. Please try again.',
                                icon: Icons.error_outline,
                              );
                              return;
                            }

                            final postService = PostService(
                              baseUrl: AuthService.baseUrl,
                              token: token,
                            );

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    MainScreen(postService: postService),
                              ),
                            );
                          } catch (e, stackTrace) {
                            debugPrint('GOOGLE SIGN-IN ERROR: $e');
                            debugPrint('STACK TRACE: $stackTrace');

                            if (!mounted) return;

                            await _showGoogleSignInError(e);
                          }
                        },

                        child: const Text(
                          'Continue with Google',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
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

  Future<void> _showResultDialog({
    required String title,
    required String message,
    IconData icon = Icons.info_outline,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          title: Column(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xfffff5cc),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xfffcc001), size: 35),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xfffcc001),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        );
      },
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
