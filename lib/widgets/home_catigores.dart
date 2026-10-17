import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeCategories extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const HomeCategories({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const Color accent = Color(0xFFFCC001);

  final List<Map<String, String>> categories = const [
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
    {'name': 'Translation', 'icon': 'assets/icons/translation.svg'},
    {'name': 'Projects', 'icon': 'assets/icons/projects.svg'},
    {'name': 'Programming', 'icon': 'assets/icons/programming.svg'},
    {'name': 'Trips', 'icon': 'assets/icons/trips.svg'},
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
          final isSelected = index == 0;

          return Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xfffcc001)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xfffcc001)
                        : const Color(0xFFEEEEEE),
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
                      color: isSelected ? Color(0xffffffff) : Color(0xff333333),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['name']!,
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
            ],
          );
        },
      ),
    );
  }
}
