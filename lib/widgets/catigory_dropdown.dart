import 'package:flutter/material.dart';
import 'package:hands/utils/langs.dart';

class CategoryDropdown extends StatefulWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onChanged;

  const CategoryDropdown({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
  });

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final GlobalKey _key = GlobalKey();

  Future<void> _openDropdown() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      color: isDark ? Color(0xFF333333) : Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xfffcc001), width: 2.5),
      ),
      items: widget.categories.map((category) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return PopupMenuItem<String>(
          value: category,
          child: SizedBox(
            width: renderBox.size.width - 30,
            child: Text(
              textRead(context, category),
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _openDropdown,
      child: Container(
        key: _key,
        height: 60,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF333333) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xfffcc001), width: 2.5),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),

            const Icon(
              Icons.category_outlined,
              color: Color(0xfffcc001),
              size: 28,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                textRead(context, widget.selectedCategory ?? 'Category'),
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  color: widget.selectedCategory == null
                      ? (isDark ? Colors.grey : Colors.grey)
                      : (isDark ? Colors.white : Color(0xff333333)),
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
