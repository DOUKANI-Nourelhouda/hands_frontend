import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hands/utils/langs.dart';

class HomeCategories extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const HomeCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Color accent = Color(0xfffcc001);

  static const List<Map<String, String>> categories = [
    {'name': 'All', 'icon': 'assets/icons/all.svg'},
    {'name': 'Food', 'icon': 'assets/icons/food.svg'},
    {'name': 'Beauty', 'icon': 'assets/icons/beauty.svg'},
    {'name': 'Sports', 'icon': 'assets/icons/sports.svg'},
    {'name': 'Delivery', 'icon': 'assets/icons/delivery.svg'},
    {'name': 'Printing & Copying', 'icon': 'assets/icons/printing&copying.svg'},
    {'name': 'Sewing', 'icon': 'assets/icons/sewing.svg'},
    {'name': 'Phone & PC Repair', 'icon': 'assets/icons/phone&pcrepair.svg'},
    {'name': 'Education', 'icon': 'assets/icons/education.svg'},
    {'name': 'Design', 'icon': 'assets/icons/design.svg'},
    {'name': 'Photography', 'icon': 'assets/icons/photography.svg'},
    {'name': 'Video Editing', 'icon': 'assets/icons/vedioediting.svg'},
    {'name': 'Hairdressing', 'icon': 'assets/icons/hairdressing.svg'},
    {'name': 'Cleaning', 'icon': 'assets/icons/cleaning.svg'},
    {'name': 'Laundry', 'icon': 'assets/icons/laundry.svg'},
    {'name': 'Handmade', 'icon': 'assets/icons/handmade.svg'},
    {'name': 'Electronics', 'icon': 'assets/icons/electronics.svg'},
    {'name': 'Clothing', 'icon': 'assets/icons/clothing.svg'},
    {'name': 'Jewelry', 'icon': 'assets/icons/jewelry.svg'},
    {'name': 'Exchange', 'icon': 'assets/icons/translation.svg'},
    {'name': 'Projects', 'icon': 'assets/icons/projects.svg'},
    {'name': 'Programming', 'icon': 'assets/icons/programming.svg'},
    {'name': 'Trips', 'icon': 'assets/icons/trips.svg'},
    {'name': 'Lost & Found', 'icon': 'assets/icons/losts&founds.svg'},
    {
      'name': 'Rentals & Borrowing',
      'icon': 'assets/icons/rentals&borrowing.svg',
    },
    {'name': 'Questions & Answers', 'icon': 'assets/icons/q&a.svg'},
    {'name': 'Other', 'icon': 'assets/icons/others.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 37,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final category = categories[index];
          final name = category['name']!;

          // The selected category now comes from HomePageState.
          final isSelected = name == (selectedCategory ?? 'All');

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onCategorySelected(name == 'All' ? null : name);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? accent : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? accent : const Color(0xFFEEEEEE),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    category['icon']!,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      isSelected ? Colors.white : const Color(0xff333333),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    text(context, name),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff333333),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
