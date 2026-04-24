import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/glass.dart';
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
  int _currentPage = 1;
  static const int _pageSize = 6;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static const _categories = [
    'All',
    Species.mammals,
    Species.birds,
    Species.reptiles,
    Species.amphibians,
    Species.insects,
  ];
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
    _scrollController.dispose();
    super.dispose();
  }

  List<Species> get _filtered {
    var list = speciesData.where((s) {
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
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
        final c =
            conservationStatusRank(a.conservationStatus) -
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
      (_category != 'All' ? 1 : 0) +
      (_status != 'All' ? 1 : 0) +
      (_difficulty != 'All' ? 1 : 0);

  void _resetFilters() {
    setState(() {
      _category = 'All';
      _status = 'All';
      _difficulty = 'All';
      _tempCategory = 'All';
      _tempStatus = 'All';
      _tempDifficulty = 'All';
      _currentPage = 1;
    });
  }

  void _resetSort() {
    setState(() {
      _sortBy = _SortBy.none;
      _sortOrder = _SortOrder.ascending;
      _tempSortBy = _SortBy.none;
      _tempSortOrder = _SortOrder.ascending;
      _currentPage = 1;
    });
  }

  void _clearSearchInput() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  void _goToPage(int page, {bool smooth = true}) {
    setState(() {
      _currentPage = page;
    });
    if (!_scrollController.hasClients) return;
    if (smooth) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scale = Adaptive.scale(context);
    final filtered = _filtered;
    final totalPages = filtered.isEmpty
        ? 1
        : (filtered.length / _pageSize).ceil();
    final page = _currentPage.clamp(1, totalPages);
    final start = filtered.isEmpty ? 0 : (page - 1) * _pageSize;
    final displayed = filtered.skip(start).take(_pageSize).toList();
    final saved = context.watch<SavedSpeciesProvider>();

    return Material(
      color: Colors.transparent,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                24 * scale,
                16 * scale,
                8 * scale,
              ),
              child: GlassPanel(
                padding: EdgeInsets.fromLTRB(
                  18 * scale,
                  20 * scale,
                  18 * scale,
                  18 * scale,
                ),
                borderRadius: 26 * scale,
                fillAlpha: 0.42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kachak',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: Adaptive.clamp(context, 28, min: 22, max: 34),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        height: 1.05,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Malaysian Wildlife Explorer',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.35,
                        height: 1.35,
                        color: const Color(0xFF5C6B63),
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search species name',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearSearchInput,
                              )
                            : null,
                      ),
                      onChanged: (v) => setState(() {
                        _searchQuery = v;
                        _currentPage = 1;
                      }),
                    ),
                    SizedBox(height: 12 * scale),
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
                                selected:
                                    _showFilters || _activeFilterCount > 0,
                                primary: true,
                                badge: _activeFilterCount > 0
                                    ? '$_activeFilterCount'
                                    : null,
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
                          onPressed: () =>
                              setState(() => _gridView = !_gridView),
                          icon: Icon(
                            _gridView ? Icons.view_list : Icons.grid_view,
                          ),
                        ),
                      ],
                    ),
                    if (_showFilters) _filterPanel(),
                    if (_showSort) _sortPanel(),
                  ],
                ),
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
                      Icon(
                        Icons.info_outline,
                        size: 64 * scale,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12 * scale),
                      const Text(
                        'No species found',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8 * scale),
                      Text('No species matching "$_searchQuery"'),
                      SizedBox(height: 16 * scale),
                      FilledButton(
                        onPressed: _clearSearchInput,
                        child: const Text('Clear search'),
                      ),
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
                      Icon(
                        Icons.filter_alt_off,
                        size: 64 * scale,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 12 * scale),
                      const Text('No results match your filters'),
                      SizedBox(height: 16 * scale),
                      FilledButton(
                        onPressed: _resetFilters,
                        child: const Text('Reset filters'),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_gridView) ...[
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                8 * scale,
                16 * scale,
                0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  // Keep grid mode consistent across phones: always 2 columns.
                  // Device logical width can vary by pixel density, which previously
                  // caused 1-column or 3-column layouts on some screens.
                  crossAxisCount: 2,
                  mainAxisSpacing: 12 * scale,
                  crossAxisSpacing: 12 * scale,
                  // Taller cells than width/0.72 so title + chips + Save fit without overflow.
                  childAspectRatio: 0.58,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _speciesCard(displayed[index], saved, compact: true),
                  childCount: displayed.length,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _paginationFooter(
                scale: scale,
                page: page,
                totalPages: totalPages,
                hasResults: filtered.isNotEmpty,
              ),
            ),
          ] else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                8 * scale,
                16 * scale,
                100 * scale,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == displayed.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8 * scale),
                        child: _paginationControls(
                          page: page,
                          totalPages: totalPages,
                        ),
                      );
                    }
                    if (index >= displayed.length) return null;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12 * scale),
                      child: _speciesCard(
                        displayed[index],
                        saved,
                        compact: false,
                      ),
                    );
                  },
                  childCount: displayed.length + (filtered.isNotEmpty ? 1 : 0),
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
      color: selected ? color : Colors.white.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : Colors.black87,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: selected ? color : Colors.white,
                    ),
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
            const Text(
              'Category',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
            const Text(
              'Conservation Status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
            const Text(
              'Shooting Difficulty Level',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
                        _currentPage = 1;
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
            const Text(
              'Sort By',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
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
              const Text(
                'Order',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: Text(
                      _tempSortBy == _SortBy.difficultyLevel
                          ? 'Ascending (1★ → 5★)'
                          : 'Ascending (Least → Critical)',
                    ),
                    selected: _tempSortOrder == _SortOrder.ascending,
                    onSelected: (_) =>
                        setState(() => _tempSortOrder = _SortOrder.ascending),
                    selectedColor: AppColors.accent,
                    labelStyle: TextStyle(
                      color: _tempSortOrder == _SortOrder.ascending
                          ? Colors.white
                          : null,
                    ),
                  ),
                  ChoiceChip(
                    label: Text(
                      _tempSortBy == _SortBy.difficultyLevel
                          ? 'Descending (5★ → 1★)'
                          : 'Descending (Critical → Least)',
                    ),
                    selected: _tempSortOrder == _SortOrder.descending,
                    onSelected: (_) =>
                        setState(() => _tempSortOrder = _SortOrder.descending),
                    selectedColor: AppColors.accent,
                    labelStyle: TextStyle(
                      color: _tempSortOrder == _SortOrder.descending
                          ? Colors.white
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    onPressed: () {
                      setState(() {
                        _sortBy = _tempSortBy;
                        _sortOrder = _tempSortOrder;
                        _showSort = false;
                        _currentPage = 1;
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

  Widget _paginationFooter({
    required double scale,
    required int page,
    required int totalPages,
    required bool hasResults,
  }) {
    if (!hasResults) return SizedBox(height: 100 * scale);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16 * scale,
        12 * scale,
        16 * scale,
        100 * scale,
      ),
      child: _paginationControls(page: page, totalPages: totalPages),
    );
  }

  Widget _paginationControls({required int page, required int totalPages}) {
    if (totalPages <= 1) return const SizedBox.shrink();
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: page > 1 ? () => _goToPage(page - 1) : null,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Previous'),
                style: _pagerButtonStyle(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: page < totalPages ? () => _goToPage(page + 1) : null,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Next'),
                style: _pagerButtonStyle(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: _buildPageTokens(page: page, totalPages: totalPages).map((
            token,
          ) {
            if (token == null) {
              return Container(
                width: 44,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '...',
                  style: TextStyle(
                    color: AppColors.accent.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }
            return OutlinedButton(
              onPressed: token == page ? null : () => _goToPage(token),
              style: _pageNumberButtonStyle(selected: token == page),
              child: Text('$token'),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Text(
            'Page $page / $totalPages',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.accent,
            ),
          ),
        ),
      ],
    );
  }

  List<int?> _buildPageTokens({required int page, required int totalPages}) {
    if (totalPages <= 5) {
      return [for (var p = 1; p <= totalPages; p++) p];
    }

    final keep = <int>{
      1,
      totalPages,
      page,
      (page - 1).clamp(1, totalPages),
      (page + 1).clamp(1, totalPages),
    }.toList()..sort();

    final tokens = <int?>[];
    for (var i = 0; i < keep.length; i++) {
      final current = keep[i];
      if (tokens.isNotEmpty) {
        final prev = tokens.last;
        if (prev != null && current - prev > 1) {
          tokens.add(null);
        }
      }
      tokens.add(current);
    }
    return tokens;
  }

  ButtonStyle _pagerButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.white.withValues(alpha: 0.86),
      foregroundColor: AppColors.accent,
      disabledForegroundColor: Colors.grey.shade500,
      side: BorderSide(
        color: AppColors.primary.withValues(alpha: 0.45),
        width: 1.3,
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      padding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  ButtonStyle _pageNumberButtonStyle({required bool selected}) {
    return OutlinedButton.styleFrom(
      minimumSize: const Size(44, 40),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      backgroundColor: selected
          ? AppColors.primary.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.84),
      foregroundColor: selected ? Colors.white : AppColors.accent,
      side: BorderSide(
        color: selected
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.45),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    );
  }

  Widget _speciesCard(
    Species s,
    SavedSpeciesProvider saved, {
    required bool compact,
  }) {
    final imgH = compact
        ? Adaptive.clamp(context, 120, min: 92, max: 150)
        : Adaptive.clamp(context, 180, min: 140, max: 240);
    final hasStatus = s.conservationStatus.trim().isNotEmpty;
    final bg = hasStatus
        ? statusBackgroundColor(s.conservationStatus)
        : Colors.grey.shade300;
    final fg = hasStatus
        ? statusForegroundColor(s.conservationStatus)
        : Colors.black54;
    final statusText = hasStatus
        ? (compact
              ? statusAbbreviation(s.conservationStatus)
              : s.conservationStatus)
        : (compact ? 'N/A' : 'Status Unavailable');
    final commonName = s.commonName.trim().isNotEmpty
        ? s.commonName
        : 'Unknown Species';
    final scientificName = s.scientificName.trim().isNotEmpty
        ? s.scientificName
        : 'Scientific name unavailable';
    final categoryText = s.category.trim().isNotEmpty
        ? s.category
        : 'Category N/A';

    final scale = Adaptive.scale(context);
    final tagFontSize = compact
        ? Adaptive.clamp(context, 10, min: 9, max: 12)
        : Adaptive.clamp(context, 12, min: 10, max: 14);
    final tagLabelPadding = EdgeInsets.symmetric(
      horizontal: 5 * scale,
      vertical: 2 * scale,
    );
    final tagTextStyle = TextStyle(
      fontSize: tagFontSize,
      fontWeight: FontWeight.w600,
      height: 1.05,
    );
    const tagShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    );
    const tagDensity = VisualDensity(horizontal: -2, vertical: -2);

    final infoPadding = EdgeInsets.all((compact ? 10 : 16) * scale);
    final infoColumn = Padding(
      padding: infoPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            commonName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact
                  ? Adaptive.clamp(context, 16, min: 13, max: 19)
                  : Adaptive.clamp(context, 20, min: 16, max: 24),
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            scientificName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey.shade600,
              fontSize: compact
                  ? Adaptive.clamp(context, 11, min: 10, max: 13)
                  : Adaptive.clamp(context, 13, min: 11, max: 15),
            ),
          ),
          SizedBox(height: 8 * scale),
          Wrap(
            spacing: 5 * scale,
            runSpacing: 5 * scale,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(
                  categoryText,
                  style: tagTextStyle.copyWith(color: Colors.black87),
                ),
                labelPadding: tagLabelPadding,
                visualDensity: tagDensity,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                shape: tagShape,
                side: BorderSide(color: Colors.grey.shade400),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.transparent,
              ),
              Chip(
                label: Text(
                  statusText,
                  style: tagTextStyle.copyWith(color: fg),
                ),
                labelPadding: tagLabelPadding,
                visualDensity: tagDensity,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                shape: tagShape,
                side: BorderSide(width: 1, color: bg),
                backgroundColor: bg,
                surfaceTintColor: Colors.transparent,
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Text(
                'Difficulty:',
                style: TextStyle(
                  fontSize: compact
                      ? Adaptive.clamp(context, 10, min: 9, max: 12)
                      : Adaptive.clamp(context, 12, min: 10, max: 14),
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(width: 6 * scale),
              DifficultyStars(
                level: s.difficultyLevel,
                size: compact
                    ? Adaptive.clamp(context, 12, min: 10, max: 14)
                    : Adaptive.clamp(context, 16, min: 13, max: 20),
              ),
            ],
          ),
        ],
      ),
    );

    final saveButton = Padding(
      padding: EdgeInsets.fromLTRB(
        (compact ? 10 : 16) * scale,
        0,
        (compact ? 10 : 16) * scale,
        (compact ? 10 : 16) * scale,
      ),
      child: FilledButton.icon(
        onPressed: () async {
          try {
            await saved.toggleSaved(s.id);
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Failed to update saved species. Please try again.',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        icon: Icon(
          saved.isSaved(s.id) ? Icons.favorite : Icons.favorite_border,
        ),
        label: Text(saved.isSaved(s.id) ? 'Saved' : 'Save'),
        style: FilledButton.styleFrom(
          backgroundColor: saved.isSaved(s.id)
              ? AppColors.primary
              : Colors.grey.shade200,
          foregroundColor: saved.isSaved(s.id) ? Colors.white : Colors.black87,
        ),
      ),
    );

    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SpeciesDetailScreen(speciesId: s.id),
        ),
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
                      child: SpeciesNetworkImage(
                        url: s.imageUrl,
                        fit: BoxFit.cover,
                      ),
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
      clipBehavior: Clip.antiAlias,
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
                  child: SpeciesNetworkImage(
                    url: s.imageUrl,
                    fit: BoxFit.cover,
                  ),
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
