import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class ResidenceDropdown extends StatefulWidget {
  final String? selectedResidenceId;
  final List<Map<String, dynamic>> residences;
  final bool enabled;
  final bool loading;
  final String? error;
  final ValueChanged<String?> onChanged;

  const ResidenceDropdown({
    super.key,
    required this.selectedResidenceId,
    required this.residences,
    required this.enabled,
    required this.loading,
    required this.error,
    required this.onChanged,
  });

  @override
  State<ResidenceDropdown> createState() => _ResidenceDropdownState();
}

class _ResidenceDropdownState extends State<ResidenceDropdown> {
  final GlobalKey _key = GlobalKey();

  Future<void> _openDropdown() async {
    if (!widget.enabled || widget.loading || widget.residences.isEmpty) {
      return;
    }

    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) return;

    final Offset position = renderBox.localToGlobal(Offset.zero);
    final double fieldWidth = renderBox.size.width;

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + renderBox.size.height + 5,
        position.dx + fieldWidth,
        0,
      ),
      color: Colors.white,
      elevation: 8,
      constraints: BoxConstraints(
        minWidth: fieldWidth,
        maxWidth: fieldWidth,
        maxHeight: 300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xfffcc001), width: 2.5),
      ),
      items: widget.residences.map((residence) {
        final String id = residence['_id'].toString();
        final String name =
            residence['name']?.toString() ?? 'Unnamed residence';

        return PopupMenuItem<String>(
          value: id,
          child: SizedBox(
            width: fieldWidth - 40,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                if (id == widget.selectedResidenceId)
                  const Icon(Icons.check, color: Color(0xfffcc001)),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (!mounted || selected == null) return;

    widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.residences.where(
      (residence) => residence['_id'].toString() == widget.selectedResidenceId,
    );

    final String? selectedName = selected.isEmpty
        ? null
        : selected.first['name']?.toString();

    String hint = 'Residence';

    if (widget.loading) {
      hint = 'Loading residences...';
    } else if (widget.error != null) {
      hint = 'Failed to load residences';
    } else if (!widget.enabled) {
      hint = 'Select a wilaya first';
    } else if (widget.residences.isEmpty) {
      hint = 'No residences available';
    }

    return GestureDetector(
      onTap: _openDropdown,
      child: Container(
        key: _key,
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xfffcc001), width: 2.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.home_outlined, color: Color(0xfffcc001), size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedName ?? hint,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: selectedName == null ? Colors.grey : Colors.black,
                ),
              ),
            ),
            if (widget.loading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xfffcc001),
                ),
              )
            else
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xfffcc001),
                size: 30,
              ),
          ],
        ),
      ),
    );
  }
}
