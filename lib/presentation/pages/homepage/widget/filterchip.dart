import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_event.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';
import 'package:meal_box/presentation/widgets/categorychip.dart'
    show CategoryChip;
import 'package:meal_box/presentation/widgets/shimmer_widget.dart';

class FilterChipsRow extends StatelessWidget {
  final HomeState state;
  const FilterChipsRow({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final isCategories = state.activeFilterTab == FilterTab.categories;

    if (isCategories && state.isLoadingCategories ||
        !isCategories && state.isLoadingAreas) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, __) =>
                const ShimmerBox(width: 76, height: 36, borderRadius: 30),
          ),
        ),
      );
    }

    final items = isCategories
        ? state.categories.map((c) => c.name).toList()
        : state.areas;

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final isSelected = item == state.selectedCategory;
            return CategoryChip(
              label: item,
              isSelected: isSelected,
              onTap: () {
                if (isCategories) {
                  context.read<HomeBloc>().add(HomeCategorySelected(item));
                } else {
                  context.read<HomeBloc>().add(HomeAreaSelected(item));
                }
              },
            );
          },
        ),
      ),
    );
  }
}
