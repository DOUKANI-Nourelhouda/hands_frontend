import 'dart:io';
import 'package:hands/services/post_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hands/services/profile_service.dart';
import 'package:hands/services/residence_service.dart';
import 'package:hands/widgets/residencedrowp.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final PostService postService;

  const EditProfilePage({super.key, required this.postService});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const Color yellow = Color(0xfffcc001);

  final ProfileService _profileService = ProfileService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  final List<String> _wilayas = const [
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
  ];

  List<Map<String, dynamic>> _residences = [];

  String? _selectedWilaya;
  String? _selectedResidence;
  String? _profilePicture;
  XFile? _newPicture;

  bool _loading = true;
  bool _loadingResidences = false;
  bool _saving = false;
  String? _residenceError;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final result = await _profileService.getMyProfile();
      final user = result['user'] is Map
          ? Map<String, dynamic>.from(result['user'])
          : Map<String, dynamic>.from(result);

      final residence = user['residence'];
      final residenceMap = residence is Map
          ? Map<String, dynamic>.from(residence)
          : <String, dynamic>{};

      final wilaya = residenceMap['wilaya']?.toString();
      final residenceId = (residenceMap['_id'] ?? residenceMap['id'])
          ?.toString();

      _usernameController.text = user['username']?.toString() ?? '';
      _bioController.text = user['bio']?.toString() ?? '';
      _profilePicture = user['profilePicture']?.toString();

      if (wilaya != null && _wilayas.contains(wilaya)) {
        _selectedWilaya = wilaya;
        await _loadResidences(wilaya, initialResidenceId: residenceId);
      }

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);
      _showMessage('Could not load your profile: $e');
    }
  }

  Future<void> _loadResidences(
    String wilaya, {
    String? initialResidenceId,
  }) async {
    setState(() {
      _loadingResidences = true;
      _residenceError = null;
      _residences = [];
    });

    try {
      final result = await ResidenceService.getByWilaya(wilaya);

      if (!mounted || _selectedWilaya != wilaya) return;

      setState(() {
        _residences = result;
        _selectedResidence =
            result.any(
              (r) => (r['_id'] ?? r['id']).toString() == initialResidenceId,
            )
            ? initialResidenceId
            : null;
        _loadingResidences = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loadingResidences = false;
        _residenceError = 'Could not load residences.';
      });
    }
  }

  Future<void> _pickPicture() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (file == null || !mounted) return;

      setState(() => _newPicture = file);
    } catch (e) {
      _showMessage('Could not select the picture.');
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();

    if (username.isEmpty) {
      _showMessage('Username cannot be empty.');
      return;
    }

    if (username.length > 30) {
      _showMessage('Username cannot exceed 30 characters.');
      return;
    }

    if (bio.length > 300) {
      _showMessage('Bio cannot exceed 300 characters.');
      return;
    }

    if (_selectedWilaya == null || _selectedResidence == null) {
      _showMessage('Please select your Wilaya and residence.');
      return;
    }

    String? pictureUrl;

    if (_newPicture != null) {
      final uploadedMedia = await widget.postService.uploadMedia([
        _newPicture!,
      ]);

      if (uploadedMedia.isEmpty || uploadedMedia.first['url'] == null) {
        throw Exception('Profile picture upload failed.');
      }

      pictureUrl = uploadedMedia.first['url'].toString();
    }
    setState(() => _saving = true);

    try {
      await _profileService.updateMyProfile(
        username: username,
        bio: bio,
        residenceId: _selectedResidence!,
        profilePicture: pictureUrl,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xff2e7d32),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showMessage('Could not update your profile: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: yellow),
      filled: true,
      fillColor: const Color(0xfffafafa),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffeeeeee)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffeeeeee)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: yellow, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 5, 16, 12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 27,
                      color: Color(0xff333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff333333),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: yellow),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile picture
                          Center(
                            child: GestureDetector(
                              onTap: _pickPicture,
                              child: SizedBox(
                                width: 120,
                                height: 120,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: 108,
                                      height: 108,
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: yellow,
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor: const Color(
                                          0xfffff2c2,
                                        ),
                                        backgroundImage: _newPicture != null
                                            ? FileImage(File(_newPicture!.path))
                                            : (_profilePicture != null &&
                                                          _profilePicture!
                                                              .isNotEmpty
                                                      ? NetworkImage(
                                                          _profilePicture!,
                                                        )
                                                      : const AssetImage(
                                                          'assets/images/default_pfp.jpg',
                                                        ))
                                                  as ImageProvider,
                                      ),
                                    ),
                                    Positioned(
                                      right: 7,
                                      bottom: 13,
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: yellow,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 3,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Colors.black,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            'Personal information',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),

                          TextField(
                            controller: _usernameController,
                            maxLength: 30,
                            cursorColor: const Color(0xff333333),
                            textCapitalization: TextCapitalization.none,
                            decoration: InputDecoration(
                              labelText: 'Username',

                              hintText: 'Choose a username for yourself !',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: const Color(0xfffafafa),
                              floatingLabelStyle: const TextStyle(
                                color: Color(0xfffcc001),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xfffcc001),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          TextField(
                            controller: _bioController,
                            maxLength: 300,
                            maxLines: 4,
                            minLines: 3,
                            cursorColor: const Color(0xff333333),
                            textAlignVertical: TextAlignVertical.top,
                            decoration: InputDecoration(
                              labelText: 'Bio',
                              hintText:
                                  'Tell students a little about yourself !',
                              alignLabelWithHint: true,
                              filled: true,
                              fillColor: const Color(0xfffafafa),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              floatingLabelStyle: const TextStyle(
                                color: Color(0xfffcc001),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xffeeeeee),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xfffcc001),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          const Text(
                            'Location',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 14),

                          WilayaDropdown(
                            selectedWilaya: _selectedWilaya,
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
                                _selectedWilaya = value;
                                _selectedResidence = null;
                                _residences = [];
                              });

                              if (value != null) {
                                _loadResidences(value);
                              }
                            },
                          ),

                          const SizedBox(height: 14),

                          ResidenceDropdown(
                            selectedResidenceId: _selectedResidence,
                            residences: _residences,
                            enabled:
                                _selectedWilaya != null && !_loadingResidences,
                            loading: _loadingResidences,
                            error: _residenceError,
                            onChanged: (value) {
                              setState(() => _selectedResidence = value);
                            },
                          ),

                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellow,
                                disabledBackgroundColor: const Color(
                                  0xffffe69a,
                                ),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.black,
                                      ),
                                    )
                                  : const Text(
                                      'Save Changes',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
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
