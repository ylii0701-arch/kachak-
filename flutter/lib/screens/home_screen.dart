import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

enum _SortBy { none, conservationStatus, difficultyLevel }

enum _SortOrder { ascending, descending }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _category = 'All';
  String _status = 'All';
  Object _difficulty = 'All';
  bool _showFilters = false;
  String _tempCategory = 'All';
  String _tempStatus = 'All';
  Object _tempDifficulty = 'All';
  bool _showSort = false;
  _SortBy _sortBy = _SortBy.none;
  _SortOrder _sortOrder = _SortOrder.ascending;
  _SortBy _tempSortBy = _SortBy.none;
  _SortOrder _tempSortOrder = _SortOrder.ascending;
  bool _gridView = false;
  bool _showAll = false;

  static const _categories = ['All', Species.mammals, Species.birds, Species.reptiles, Species.amphibians, Species.insects];
  static const _statuses = [
    'All',
    Species.leastConcern,
    Species.nearThreatened,
    Species.vulnerable,
    Species.endangered,
    Species.criticallyEndangered,
  ];
  static const _difficulties = <Object>['All', 1, 2, 3, 4, 5];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Species> get _filtered {
    var list = speciesData.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          s.commonName.toLowerCase().contains(q) ||
          s.scientificName.toLowerCase().contains(q);
      final matchCat = _category == 'All' || s.category == _category;
      final matchSt = _status == 'All' || s.conservationStatus == _status;
      final matchDiff =
          _difficulty == 'All' || (s.difficultyLevel == _difficulty as int);
      return matchSearch && matchCat && matchSt && matchDiff;
    }).toList();

    if (_sortBy == _SortBy.conservationStatus) {
      list.sort((a, b) {
        final c = conservationStatusRank(a.conservationStatus) -
            conservationStatusRank(b.conservationStatus);
        return _sortOrder == _SortOrder.ascending ? c : -c;
      });
    } else if (_sortBy == _SortBy.difficultyLevel) {
      list.sort((a, b) {
        final c = a.difficultyLevel - b.difficultyLevel;
        return _sortOrder == _SortOrder.ascending ? c : -c;
      });
    }
    return list;
  }

  int get _activeFilterCount =>
      (_category != 'All' ? 1 : 0) + (_status != 'All' ? 1 : 0) + (_difficulty != 'All' ? 1 : 0);

  void _resetFilters() {
    setState(() {
      _category = 'All';
      _status = 'All';
      _difficulty = 'All';
      _tempCategory = 'All';
      _tempStatus = 'All';
      _tempDifficulty = 'All';
      _showAll = false;
    });
  }

  void _resetSort() {
    setState(() {
      _sortBy = _SortBy.none;
      _sortOrder = _SortOrder.ascending;
      _tempSortBy = _SortBy.none;
      _tempSortOrder = _SortOrder.ascending;
      _showAll = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    final initialCount = filtered.isEmpty ? 0 : (filtered.length * 0.25).ceil().clamp(1, filtered.length);
    final displayed = _showAll ? filtered : filtered.take(initialCount).toList();
    final hasMore = filtered.length > initialCount && !_showAll;
    final saved = context.watch<SavedSpeciesProvider>();

    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x1A2F855A), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kachak',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.accent),
                  ),
                  Text(
                    'Malaysian Wildlife Explorer',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search species name',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.close), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); })
                          : null,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _chipButton(
                              label: 'Filter',
                              icon: Icons.filter_list,
                              selected: _showFilters || _activeFilterCount > 0,
                              primary: true,
                              badge: _activeFilterCount > 0 ? '$_activeFilterCount' : null,
                              onTap: () {
                                setState(() {
                                  if (_showFilters) {
                                    _showFilters = false;
                                  } else {
                                    _tempCategory = _category;
                                    _tempStatus = _status;
                                    _tempDifficulty = _difficulty;
                                    _showFilters = true;
                                    _showSort = false;
                                  }
                                });
                              },
                            ),
                            _chipButton(
                              label: 'Sort',
                              icon: Icons.swap_vert,
                              selected: _showSort || _sortBy != _SortBy.none,
                              primary: false,
                              badge: _sortBy != _SortBy.none ? '✓' : null,
                              onTap: () {
                                setState(() {
                                  if (_showSort) {
                                    _showSort = false;
                                  } else {
                                    _tempSortBy = _sortBy;
                                    _tempSortOrder = _sortOrder;
                                    _showSort = true;
                                    _showFilters = false;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_activeFilterCount > 0 || _sortBy != _SortBy.none)
                        IconButton(
                          onPressed: () {
                            _resetFilters();
                            _resetSort();
                          },
                          icon: const Icon(Icons.cleaning_services_outlined),
                          color: Colors.red.shade700,
                          tooltip: 'Clear all',
                        ),
                      IconButton(
                        onPressed: () => setState(() => _gridView = !_gridView),
                        icon: Icon(_gridView ? Icons.view_list : Icons.grid_view),
                      ),
                    ],
                  ),
                  if (_showFilters) _filterPanel(),
                  if (_showSort) _sortPanel(),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty && _searchQuery.isNotEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('No species found matching "$_searchQuery"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Text('Try checking your spelling or using different filters.', style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }, child: const Text('Clear search')),
                    ],
                  ),
                ),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_alt_off, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('No results match your filters'),
                      const SizedBox(height: 16),
                      FilledButton(onPressed: _resetFilters, child: const Text('Reset filters')),
                    ],
                  ),
                ),
              ),
            )
          else if (_gridView) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    // Taller cells than width/0.72 so title + chips + Save fit without overflow.
                    childAspectRatio: 0.58,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _speciesCard(displayed[index], saved, compact: true),
                    childCount: displayed.length,
                  ),
                ),
              ),
              if (hasMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: OutlinedButton(
                      onPressed: () => setState(() => _showAll = true),
                      child: const Text('View More Species'),
                    ),
                  ),
                )
              else
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ]
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == displayed.length && hasMore) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton(
                            onPressed: () => setState(() => _showAll = true),
                            child: const Text('View More Species'),
                          ),
                        );
                      }
                      if (index >= displayed.length) return null;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _speciesCard(displayed[index], saved, compact: false),
                      );
                    },
                    childCount: displayed.length + (hasMore ? 1 : 0),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _chipButton({
    required String label,
    required IconData icon,
    required bool selected,
    required bool primary,
    required VoidCallback onTap,
    String? badge,
  }) {
    final color = primary ? AppColors.primary : AppColors.accent;
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? color : Colors.grey.shade300, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: selected ? Colors.white : Colors.black87),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: selected ? Colors.white : Colors.black87)),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: selected ? color : Colors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterPanel() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((c) {
                final sel = _tempCategory == c;
                return ChoiceChip(
                  label: Text(c),
                  selected: sel,
                  onSelected: (_) => setState(() => _tempCategory = c),
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(color: sel ? Colors.white : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Conservation Status', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _statuses.map((c) {
                final sel = _tempStatus == c;
                return FilterChip(
                  label: Text(c, style: const TextStyle(fontSize: 11)),
                  selected: sel,
                  onSelected: (_) => setState(() => _tempStatus = c),
                  selectedColor: AppColors.accent,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: sel ? Colors.white : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Shooting Difficulty Level', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _difficulties.map((d) {
                final sel = _tempDifficulty == d;
                final label = d == 'All' ? 'All' : '$d ★';
                return FilterChip(
                  label: Text(label, style: const TextStyle(fontSize: 11)),
                  selected: sel,
                  onSelected: (_) => setState(() => _tempDifficulty = d),
                  selectedColor: AppColors.accent,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: sel ? Colors.white : null),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _category = _tempCategory;
                        _status = _tempStatus;
                        _difficulty = _tempDifficulty;
                        _showFilters = false;
                        _showAll = false;
                      });
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _tempCategory = 'All';
                    _tempStatus = 'All';
                    _tempDifficulty = 'All';
                  }),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortPanel() {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _sortChip('None', _SortBy.none),
                _sortChip('Conservation Status', _SortBy.conservationStatus),
                _sortChip('Difficulty Level', _SortBy.difficultyLevel),
              ],
            ),
            if (_tempSortBy != _SortBy.none) ...[
              const SizedBox(height: 16),
              const Text('Order', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(_tempSortBy == _SortBy.difficultyLevel ? 'Ascending (1★ → 5★)' : 'Ascending (Least → Critical)'),
                    selected: _tempSortOrder == _SortOrder.ascending,
                    onSelected: (_) => setState(() => _tempSortOrder = _SortOrder.ascending),
                    selectedColor: AppColors.accent,
                    labelStyle: TextStyle(color: _tempSortOrder == _SortOrder.ascending ? Colors.white : null),
                  ),
                  ChoiceChip(
                    label: Text(_tempSortBy == _SortBy.difficultyLevel ? 'Descending (5★ → 1★)' : 'Descending (Critical → Least)'),
                    selected: _tempSortOrder == _SortOrder.descending,
                    onSelected: (_) => setState(() => _tempSortOrder = _SortOrder.descending),
                    selectedColor: AppColors.accent,
                    labelStyle: TextStyle(color: _tempSortOrder == _SortOrder.descending ? Colors.white : null),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.accent),
                    onPressed: () {
                      setState(() {
                        _sortBy = _tempSortBy;
                        _sortOrder = _tempSortOrder;
                        _showSort = false;
                        _showAll = false;
                      });
                    },
                    child: const Text('Confirm'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _tempSortBy = _SortBy.none),
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortChip(String label, _SortBy value) {
    final sel = _tempSortBy == value;
    return ChoiceChip(
      label: Text(label),
      selected: sel,
      onSelected: (_) => setState(() => _tempSortBy = value),
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(color: sel ? Colors.white : null),
    );
  }

  Widget _speciesCard(Species s, SavedSpeciesProvider saved, {required bool compact}) {
    final imgH = compact ? 120.0 : 180.0;

    // --- SAFE STATUS CHECKS ---
    final hasStatus = s.conservationStatus.trim().isNotEmpty;
    final bg = hasStatus ? statusBackgroundColor(s.conservationStatus) : Colors.grey.shade300;
    final fg = hasStatus ? statusForegroundColor(s.conservationStatus) : Colors.black54;
    final statusText = hasStatus
        ? (compact ? statusAbbreviation(s.conservationStatus) : s.conservationStatus)
        : (compact ? 'N/A' : 'Status Unavailable');

    final infoPadding = EdgeInsets.all(compact ? 10 : 16);
    final infoColumn = Padding(
      padding: infoPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- SAFE NAME CHECKS ---
          Text(
            s.commonName.trim().isNotEmpty ? s.commonName : 'Unknown Species',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.w600),
          ),
          Text(
            s.scientificName.trim().isNotEmpty ? s.scientificName : 'Scientific name unavailable',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey.shade600, fontSize: compact ? 11 : 13),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              // --- SAFE CATEGORY CHECK ---
              Chip(
                label: Text(
                    s.category.trim().isNotEmpty ? s.category : 'Category N/A',
                    style: TextStyle(fontSize: compact ? 10 : 12)
                ),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
                child: Text(statusText, style: TextStyle(color: fg, fontSize: compact ? 10 : 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('Difficulty:', style: TextStyle(fontSize: compact ? 10 : 12, color: Colors.grey.shade600)),
              const SizedBox(width: 6),
              DifficultyStars(level: s.difficultyLevel, size: compact ? 12 : 16),
            ],
          ),
        ],
      ),
    );

    final saveButton = Padding(
      padding: EdgeInsets.fromLTRB(compact ? 10 : 16, 0, compact ? 10 : 16, compact ? 10 : 16),
      child: FilledButton.icon(
        onPressed: () async {
          try {
            await saved.toggleSaved(s.id);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update saved species. Please try again.'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: Icon(saved.isSaved(s.id) ? Icons.favorite : Icons.favorite_border),
        label: Text(saved.isSaved(s.id) ? 'Saved' : 'Save'),
        style: FilledButton.styleFrom(
          backgroundColor: saved.isSaved(s.id) ? AppColors.primary : Colors.grey.shade200,
          foregroundColor: saved.isSaved(s.id) ? Colors.white : Colors.black87,
        ),
      ),
    );

    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => SpeciesDetailScreen(speciesId: s.id)),
      );
    }

    if (compact) {
      return Card(
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: openDetail,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SpeciesNetworkImage(url: s.imageUrl, fit: BoxFit.cover),
                    ),
                    infoColumn,
                  ],
                ),
              ),
            ),
            saveButton,
          ],
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: openDetail,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: imgH,
                  child: SpeciesNetworkImage(url: s.imageUrl, fit: BoxFit.cover),
                ),
                infoColumn,
              ],
            ),
          ),
          saveButton,
        ],
      ),
    );
  }
}