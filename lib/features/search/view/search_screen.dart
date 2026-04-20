import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/search/viewmodel/search_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/search/widgets/station_list_tile.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();
    final stations = context.watch<StationViewModel>().stations;
    final filtered = vm.filter(stations);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Stations'),
        backgroundColor: AppColors.surface,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _SearchField(vm: vm),
          ),
        ),
      ),
      body: filtered.isEmpty
          ? _EmptySearch(query: vm.query)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  StationListTile(station: filtered[i], index: i),
            ),
    );
  }
}

// ─── Search Field ─────────────────────────────────────────────────────────────

class _SearchField extends StatefulWidget {
  final SearchViewModel vm;
  const _SearchField({required this.vm});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      autofocus: false,
      onChanged: widget.vm.setQuery,
      style: const TextStyle(fontSize: 15, color: AppColors.textDark),
      decoration: InputDecoration(
        hintText: 'Search by name or address...',
        prefixIcon: const Icon(Icons.search_rounded,
            color: AppColors.textLight, size: 20),
        suffixIcon: widget.vm.query.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textLight, size: 18),
                onPressed: () {
                  _ctrl.clear();
                  widget.vm.clearQuery();
                },
              )
            : null,
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.search_off_rounded,
                color: AppColors.textLight, size: 34),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'No stations available' : 'No results for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try a different search term',
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
