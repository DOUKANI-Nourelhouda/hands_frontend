import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hands/services/payment_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCreditsPage extends StatefulWidget {
  final Future<void> Function(String packageId) onBuyPackage;

  const PostCreditsPage({super.key, required this.onBuyPackage});

  @override
  State<PostCreditsPage> createState() => _PostCreditsPageState();
}

class _PostCreditsPageState extends State<PostCreditsPage>
    with WidgetsBindingObserver {
  static const Color accent = Color(0xfffcc001);
  static const Color background = Color(0xfff8f8f8);
  final PaymentService _paymentService = PaymentService();
  final String baseUrl = dotenv.env['BASE_URL']!;

  bool isLoading = true;
  String? errorMessage;
  String? buyingPackage;

  int freePostsRemaining = 0;
  int paidPostCredits = 0;
  final List<Map<String, dynamic>> packages = [
    {
      'id': '5_posts',
      'posts': 5,
      'price': 50,
      'description': 'For who is just getting started.',
    },
    {
      'id': '10_posts',
      'posts': 10,
      'price': 90,
      'description': 'For who wants to do more.',
    },
    {
      'id': '20_posts',
      'posts': 20,
      'price': 170,
      'description': 'For those who never stop creating.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCredits();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('HANDS RESUMED - REFRESHING CREDITS');

      _loadCredits(showLoading: false);
    }
  }

  Future<void> _loadCredits({bool showLoading = true}) async {
    if (!mounted) return;

    if (showLoading) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await _paymentService.getCredits();

      if (!mounted) return;

      setState(() {
        freePostsRemaining = (data['freePostsRemaining'] as num?)?.toInt() ?? 0;

        paidPostCredits = (data['paidPostCredits'] as num?)?.toInt() ?? 0;

        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      });

      debugPrint('LOAD CREDITS ERROR: $e');
    }
  }

  Future<void> _buyPackage(String packageId) async {
    setState(() {
      buyingPackage = packageId;
    });

    try {
      final result = await _paymentService.createPostPackagePayment(
        packageId: packageId,
      );

      debugPrint('PAYMENT RESPONSE: $result');

      final checkout = result['checkout'];
      final checkoutUrl = checkout is Map ? checkout['url']?.toString() : null;

      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('Checkout URL was not returned.');
      }

      final uri = Uri.tryParse(checkoutUrl);

      if (uri == null ||
          (uri.scheme != 'https' && uri.scheme != 'http') ||
          uri.host.isEmpty) {
        throw Exception('Invalid checkout URL.');
      }

      debugPrint('CHECKOUT URL: $checkoutUrl');

      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

      debugPrint('CHECKOUT OPENED: $opened');

      if (!opened) {
        throw Exception('Could not open the payment page.');
      }

      // The user may pay in the browser and return to Hands.
      // Refresh again when they return using the lifecycle method below.
    } catch (e) {
      debugPrint('PAYMENT ERROR: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          buyingPackage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xff333333),
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Post Credits',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: accent))
            : RefreshIndicator(
                color: accent,
                onRefresh: _loadCredits,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  children: [
                    _buildCreditsSection(),
                    const SizedBox(height: 30),
                    _buildPackagesHeader(),
                    const SizedBox(height: 16),
                    ...packages.map(_buildPackageCard),
                    const SizedBox(height: 7),
                    _buildInfoNote(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildCreditsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your balance',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Keep track of the posts you can publish.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildCreditCard(
                title: 'Free posts left',
                value: freePostsRemaining,
                icon: Icons.card_giftcard_rounded,
                subtitle: 'Free posts',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCreditCard(
                title: 'Paid post credits',
                value: paidPostCredits,
                icon: Icons.confirmation_number_rounded,
                subtitle: 'Purchased posts',
              ),
            ),
          ],
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red.shade800, fontSize: 13),
                ),
                TextButton(
                  onPressed: _loadCredits,
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCreditCard({
    required String title,
    required int value,
    required IconData icon,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 23),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Get more post credits',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the package that works for you !',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    final String id = package['id'] as String;
    final int posts = package['posts'] as int;
    final int price = package['price'] as int;
    final bool isBuying = buyingPackage == id;
    final bool anotherIsBuying = buyingPackage != null && !isBuying;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.17),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.post_add_rounded,
                    color: Colors.black87,
                    size: 27,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$posts Post Credits',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        package['description'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$price DA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(price / posts).toStringAsFixed(1)} DA / post',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: anotherIsBuying || isBuying
                    ? null
                    : () => _buyPackage(id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: Colors.grey.shade300,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBuying
                    ? const SizedBox(
                        height: 21,
                        width: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.black87,
                        ),
                      )
                    : const Text(
                        'Buy package',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 21, color: Colors.black87),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your 3 free posts are used first. Purchased credits are available after your free posts have been used.',
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
