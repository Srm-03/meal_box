import 'package:flutter/material.dart';
import 'package:meal_box/core/constants/app_colour.dart';

class RegionBubble extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final bool isLocal;
  final VoidCallback onTap;

  const RegionBubble({
    super.key,
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.isLocal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 66,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.35)
                        : Colors.black.withOpacity(0.07),
                    blurRadius: isSelected ? 10 : 4,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: isLocal && !isSelected
                    ? Border.all(color: AppColors.secondary, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(flag, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
