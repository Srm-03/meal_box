import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_bloc.dart';
import 'package:meal_box/presentation/bloc/home/home_event.dart';
import 'package:meal_box/presentation/bloc/home/home_state.dart';
import 'package:meal_box/presentation/pages/homepage/widget/tabbar.dart';

class FilterTabs extends StatelessWidget {
  final HomeState state;
  const FilterTabs({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          TabButton(
            label: 'Categories',
            icon: Icons.grid_view_rounded,
            isActive: state.activeFilterTab == FilterTab.categories,
            onTap: () {
              if (state.activeFilterTab != FilterTab.categories &&
                  state.categories.isNotEmpty) {
                context.read<HomeBloc>().add(
                  HomeCategorySelected(state.categories.first.name),
                );
              }
            },
          ),
          const SizedBox(width: 10),
          TabButton(
            label: 'Regions',
            icon: Icons.public_rounded,
            isActive: state.activeFilterTab == FilterTab.regions,
            onTap: () {
              if (state.activeFilterTab != FilterTab.regions &&
                  state.areas.isNotEmpty) {
                final first =
                    state.localCuisine != null &&
                        state.areas.contains(state.localCuisine)
                    ? state.localCuisine!
                    : state.areas.first;
                context.read<HomeBloc>().add(HomeAreaSelected(first));
              }
            },
          ),
        ],
      ),
    );
  }
}
