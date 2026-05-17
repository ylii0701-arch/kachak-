import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/site_data.dart';
import '../data/species_data.dart';
import '../models/species.dart';
import '../providers/saved_species_provider.dart';
import '../services/prediction_manager.dart';
import '../theme/app_theme.dart';
import '../utils/adaptive.dart';
import '../widgets/difficulty_stars.dart';
import '../widgets/onboarding/spotlight_tour.dart';
import '../widgets/onboarding/tour_anchor.dart';
import '../widgets/species_network_image.dart';
import 'species_detail_screen.dart';

enum _SortBy { none, conservationStatus, difficultyLevel }

enum _SortOrder { ascending, descending }

enum _FilterPanelTab { location, species }

/// Main species explorer with search, filter, sort, and pagination controls.
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
  String? _tempSelectedCity;
  String? _tempSelectedSiteId;
  _FilterPanelTab _activeFilterPanelTab = _FilterPanelTab.location;
  bool _showAllCities = false;
  bool _showAllSites = false;
  bool _showSort = false;
  _SortBy _sortBy = _SortBy.none;
  _SortOrder _sortOrder = _SortOrder.ascending;
  _SortBy _tempSortBy = _SortBy.none;
  _SortOrder _tempSortOrder = _SortOrder.ascending;
  bool _gridView = false;
  String? _selectedCity;
  String? _selectedSiteId;
  int _currentPage = 1;
  static const int _pageSize = 6;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _tourFilterOpenedByStep = false;

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
    TourRuntimeCommand.command.removeListener(_onTourCommandChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    TourRuntimeCommand.command.addListener(_onTourCommandChanged);
  }

  void _onTourCommandChanged() {
    final cmd = TourRuntimeCommand.command.value;
    if (!mounted || cmd == null) return;
    if (cmd == 'home.openFilter') {
      if (_showFilters) return;
      setState(() {
        _tempCategory = _category;
        _tempStatus = _status;
        _tempDifficulty = _difficulty;
        _tempSelectedCity = _selectedCity;
        _tempSelectedSiteId = _selectedSiteId;
        _activeFilterPanelTab = _FilterPanelTab.location;
        _showAllCities = false;
        _showAllSites = false;
        _showFilters = true;
        _showSort = false;
        _tourFilterOpenedByStep = true;
      });
    } else if (cmd == 'home.closeFilter') {
      if (_showFilters && _tourFilterOpenedByStep) {
        setState(() {
          _showFilters = false;
          _tourFilterOpenedByStep = false;
        });
      }
    } else if (cmd != 'home.openFilter' && _tourFilterOpenedByStep && _showFilters) {
      setState(() {
        _showFilters = false;
        _tourFilterOpenedByStep = false;
      });
    }
  }

  bool get _isAreaMode => _selectedCity != null;

  List<Species> get _filtered {
    // Apply text/category/status/difficulty filters first.
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

    if (_isAreaMode) {
      final matchingSites = siteData.where((site) {
        if (site.cityName != _selectedCity) return false;
        if (_selectedSiteId != null && site.id != _selectedSiteId) return false;
        return true;
      }).toList();

      list = list.where((species) {
        for (final site in matchingSites) {
          if (site.supportedSpeciesIds.contains(species.id)) return true;
        }
        return false;
      }).toList();

      double speciesScore(Species species) {
        var best = 0.0;
        for (final site in matchingSites) {
          final p = PredictionManager.instance.latestPredictions[site.id]?[species.id] ?? 0.0;
          if (p > best) best = p;
        }
        return best;
      }

      list.sort((a, b) => speciesScore(b).compareTo(speciesScore(a)));
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

    // Apply sorting over the already-filtered list (explore mode only).
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
      (_selectedCity != null ? 1 : 0) +
      (_category != 'All' ? 1 : 0) +
      (_status != 'All' ? 1 : 0) +
      (_difficulty != 'All' ? 1 : 0);

  bool get _hasSortApplied => _sortBy != _SortBy.none;
  bool get _hasFilterApplied => _activeFilterCount > 0;

  /// Clears active filter state and returns to page 1.
  void _resetFilters() {
    setState(() {
      _category = 'All';
      _status = 'All';
      _difficulty = 'All';
      _selectedCity = null;
      _selectedSiteId = null;
      _tempCategory = 'All';
      _tempStatus = 'All';
      _tempDifficulty = 'All';
      _tempSelectedCity = null;
      _tempSelectedSiteId = null;
      _showFilters = false;
      _currentPage = 1;
    });
  }

  void _clearSort() {
    setState(() {
      _sortBy = _SortBy.none;
      _sortOrder = _SortOrder.ascending;
      _tempSortBy = _SortBy.none;
      _tempSortOrder = _SortOrder.ascending;
      _showSort = false;
      _currentPage = 1;
    });
  }

  void _clearAppliedRefinements() {
    _resetFilters();
    _clearSort();
  }

  List<Site> _sitesForCity(String? cityName) {
    if (cityName == null) return const [];
    final list = siteData.where((s) => s.cityName == cityName).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  void _toggleFilterDropdown() {
    setState(() {
      _tourFilterOpenedByStep = false;
      if (_showFilters) {
        _showFilters = false;
      } else {
        _tempCategory = _category;
        _tempStatus = _status;
        _tempDifficulty = _difficulty;
        _tempSelectedCity = _selectedCity;
        _tempSelectedSiteId = _selectedSiteId;
        _activeFilterPanelTab = _FilterPanelTab.location;
        _showAllCities = false;
        _showAllSites = false;
        _showFilters = true;
        _showSort = false;
      }
    });
  }

  String _locationLabel() {
    if (_selectedCity == null) return 'All regions';
    if (_selectedSiteId == null) return _selectedCity!;
    final site = siteData.where((s) => s.id == _selectedSiteId).firstOrNull;
    return site == null ? _selectedCity! : '${_selectedCity!} · ${site.name}';
  }

  List<Site> _sitesForCurrentArea() {
    if (_selectedCity == null) return const [];
    return siteData.where((s) {
      if (s.cityName != _selectedCity) return false;
      if (_selectedSiteId != null && s.id != _selectedSiteId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Clears search input and resets paging.
  void _clearSearchInput() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _currentPage = 1;
    });
  }

  /// Handles pagination change and optionally scrolls list to top.
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
    final saved = context.watch<SavedSpeciesProvider>();
    return ListenableBuilder(
      listenable: PredictionManager.instance,
      builder: (context, _) {
        final filtered = _filtered;
        // Pagination is computed after all filters/sorts are applied.
        final totalPages = filtered.isEmpty
            ? 1
            : (filtered.length / _pageSize).ceil();
        final page = _currentPage.clamp(1, totalPages);
        final start = filtered.isEmpty ? 0 : (page - 1) * _pageSize;
        final displayed = filtered.skip(start).take(_pageSize).toList();

        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/images/home_editorial_bg.png',
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),
              CustomScrollView(
                controller: _scrollController,
                slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16 * scale,
                42 * scale,
                16 * scale,
                8 * scale,
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  6 * scale,
                  6 * scale,
                  6 * scale,
                  10 * scale,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kachak',
                      style: GoogleFonts.libreBaskerville(
                        fontSize: Adaptive.clamp(context, 38, min: 30, max: 42),
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Malaysian Wildlife Explorer',
                      style: GoogleFonts.inter(
                        fontSize: Adaptive.clamp(context, 17, min: 15, max: 19),
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                        color: AppColors.textSubtitleOnFrost,
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    TourAnchor(
                      id: TourTargetIds.homeSearch,
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search species name',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.iconSectionOnFrost,
                          ),
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
                    ),
                    SizedBox(height: 12 * scale),
                    if (_isAreaMode)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12 * scale,
                          vertical: 10 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightSage.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, color: AppColors.primary),
                                SizedBox(width: 6 * scale),
                                Expanded(
                                  child: Text(
                                    _locationLabel(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6 * scale),
                            Text(
                              'Showing prediction-ranked species for selected area.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textSubtitleOnFrost,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_sitesForCurrentArea().isNotEmpty) ...[
                              SizedBox(height: 8 * scale),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: _sitesForCurrentArea()
                                    .take(3)
                                    .map(
                                      (site) => Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Text(
                                          site.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    if (_isAreaMode) SizedBox(height: 12 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                TourAnchor(
                                  id: TourTargetIds.homeFilterButton,
                                  child: _chipButton(
                                  label: 'Filter',
                                  icon: Icons.filter_list,
                                  selected: _showFilters || _hasFilterApplied,
                                  primary: true,
                                  badge: _hasFilterApplied ? '$_activeFilterCount' : null,
                                  onTap: _toggleFilterDropdown,
                                ),
                                ),
                                SizedBox(width: 8 * scale),
                                TourAnchor(
                                  id: TourTargetIds.homeSortButton,
                                  child: _chipButton(
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
                                ),
                                if (_hasFilterApplied || _hasSortApplied) ...[
                                  SizedBox(width: 8 * scale),
                                  _iconActionButton(
                                    icon: Icons.cleaning_services_outlined,
                                    onTap: _clearAppliedRefinements,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        TourAnchor(
                          id: TourTargetIds.homeLayoutButton,
                          child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => setState(() => _gridView = !_gridView),
                            child: Container(
                              width: 56 * scale,
                              height: 50 * scale,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Icon(
                                _gridView
                                    ? Icons.view_list_rounded
                                    : Icons.grid_view_rounded,
                                color: AppColors.iconSectionOnFrost,
                              ),
                            ),
                          ),
                        ),
                        ),
                      ],
                    ),
                    if (_showFilters)
                      TourAnchor(
                        id: TourTargetIds.homeFilterPanel,
                        child: _filterPanel(),
                      ),
                    if (_showSort) _sortPanel(),
                  ],
                ),
              ),
            ),
          ),
          // Empty states differentiate search miss vs filter miss.
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
            // Grid mode: fixed 2-column cards + footer pager.
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
                      _speciesCard(
                        displayed[index],
                        saved,
                        compact: true,
                        tourAnchorCard: index == 0,
                        tourAnchorSave: index == 0,
                      ),
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
            // List mode: full-width cards + inline pager card.
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
                        tourAnchorCard: index == 0,
                        tourAnchorSave: index == 0,
                      ),
                    );
                  },
                  childCount: displayed.length + (filtered.isNotEmpty ? 1 : 0),
                ),
              ),
            ),
                ],
              ),
            ],
          ),
        );
      },
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
      color: selected
          ? AppColors.lightSage.withValues(alpha: 0.66)
          : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.35)
                  : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: AppColors.iconSectionOnFrost),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
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

  Widget _iconActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 52,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withValues(alpha: 0.46)),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.red.shade400,
          ),
        ),
      ),
    );
  }

  Widget _filterPanel() {
    final allCityOptions = <String>[
      'All',
      ...{
        ...siteData.map((s) => s.cityName),
      }.toList()..sort(),
    ];
    final cityOptions = _showAllCities
        ? allCityOptions
        : allCityOptions.take(7).toList();
    final allSiteOptions = <Site>[
      ..._sitesForCity(_tempSelectedCity),
    ];
    final siteOptions = _showAllSites ? allSiteOptions : allSiteOptions.take(5).toList();

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TourAnchor(
              id: TourTargetIds.homeFilterTabs,
              child: Row(
                children: [
                  Expanded(
                    child: _filterTabTile(
                      tab: _FilterPanelTab.location,
                      title: 'Location',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _filterTabTile(
                      tab: _FilterPanelTab.species,
                      title: 'Species',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 340,
              child: SingleChildScrollView(
                child: _activeFilterPanelTab == _FilterPanelTab.location
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'City',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final city in cityOptions)
                                ChoiceChip(
                                  label: Text(city),
                                  selected: (_tempSelectedCity ?? 'All') == city,
                                  onSelected: (_) {
                                    setState(() {
                                      if (city == 'All') {
                                        _tempSelectedCity = null;
                                        _tempSelectedSiteId = null;
                                        return;
                                      }
                                      _tempSelectedCity = city;
                                      _tempSelectedSiteId = null;
                                      _showAllSites = false;
                                    });
                                  },
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: (_tempSelectedCity ?? 'All') == city
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                          if (allCityOptions.length > 7) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => setState(() => _showAllCities = !_showAllCities),
                              icon: Icon(
                                _showAllCities
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                              ),
                              label: Text(_showAllCities ? 'Show less' : 'Show more'),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            'Site',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: _tempSelectedSiteId == null,
                                onSelected: (_) =>
                                    setState(() => _tempSelectedSiteId = null),
                                selectedColor: AppColors.primary,
                                labelStyle: TextStyle(
                                  color: _tempSelectedSiteId == null
                                      ? Colors.white
                                      : null,
                                ),
                              ),
                              for (final site in siteOptions)
                                ChoiceChip(
                                  label: Text(site.name),
                                  selected: _tempSelectedSiteId == site.id,
                                  onSelected: (_) =>
                                      setState(() => _tempSelectedSiteId = site.id),
                                  selectedColor: AppColors.primary,
                                  labelStyle: TextStyle(
                                    color: _tempSelectedSiteId == site.id
                                        ? Colors.white
                                        : null,
                                  ),
                                ),
                            ],
                          ),
                          if (allSiteOptions.length > 5) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () => setState(() => _showAllSites = !_showAllSites),
                              icon: Icon(
                                _showAllSites
                                    ? Icons.keyboard_arrow_up_rounded
                                    : Icons.keyboard_arrow_down_rounded,
                              ),
                              label: Text(_showAllSites ? 'Show less' : 'Show more'),
                            ),
                          ],
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
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
                          const SizedBox(height: 14),
                          Text(
                            'Conservation Status',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _statuses.map((c) {
                              final sel = _tempStatus == c;
                              return ChoiceChip(
                                label: Text(c),
                                selected: sel,
                                onSelected: (_) => setState(() => _tempStatus = c),
                                selectedColor: AppColors.accent,
                                labelStyle: TextStyle(color: sel ? Colors.white : null),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Shooting Difficulty Level',
                            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _difficulties.map((d) {
                              final sel = _tempDifficulty == d;
                              final label = d == 'All' ? 'All' : '$d ★';
                              return ChoiceChip(
                                label: Text(label),
                                selected: sel,
                                onSelected: (_) => setState(() => _tempDifficulty = d),
                                selectedColor: AppColors.accent,
                                labelStyle: TextStyle(color: sel ? Colors.white : null),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        _selectedCity = _tempSelectedCity;
                        _selectedSiteId = _tempSelectedSiteId;
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
                  onPressed: () {
                    setState(() {
                      _tempSelectedCity = null;
                      _tempSelectedSiteId = null;
                      _tempCategory = 'All';
                      _tempStatus = 'All';
                      _tempDifficulty = 'All';
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTabTile({
    required _FilterPanelTab tab,
    required String title,
  }) {
    final selected = _activeFilterPanelTab == tab;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _activeFilterPanelTab = tab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.white : const Color(0xFFF8F6F0),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.34)
                  : AppColors.border,
            ),
          ),
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppColors.accent : AppColors.textSubtitleOnFrost,
            ),
          ),
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
        // Number tokens collapse with ellipsis for long page ranges.
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
    bool tourAnchorCard = false,
    bool tourAnchorSave = false,
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

    Widget bookmarkButton = SizedBox(
      width: (compact ? 28 : 32) * scale,
      height: (compact ? 28 : 32) * scale,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        iconSize: (compact ? 18 : 20) * scale,
        icon: Icon(
          saved.isSaved(s.id)
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
          color: AppColors.accent,
        ),
        onPressed: () async {
          try {
            await saved.toggleSaved(s.id);
          } catch (_) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Failed to update saved species. Please try again.',
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
    );
    if (tourAnchorSave) {
      bookmarkButton = TourAnchor(
        id: TourTargetIds.homeSaveButton,
        child: bookmarkButton,
      );
    }

    Widget tagChip({
      required Widget label,
      required Color bgColor,
      required Color borderColor,
    }) {
      return Chip(
        label: label,
        labelPadding: tagLabelPadding,
        visualDensity: tagDensity,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        shape: tagShape,
        side: BorderSide(width: 1, color: borderColor),
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
      );
    }

    final infoColumn = Padding(
      padding: infoPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  commonName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.libreBaskerville(
                    fontSize: compact
                        ? Adaptive.clamp(context, 16, min: 13, max: 19)
                        : Adaptive.clamp(context, 20, min: 16, max: 24),
                    fontWeight: FontWeight.w700,
                    color: AppColors.accent,
                  ),
                ),
              ),
              SizedBox(width: 4 * scale),
              bookmarkButton,
            ],
          ),
          Text(
            scientificName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontStyle: FontStyle.italic,
              color: AppColors.textSubtitleOnFrost,
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
              tagChip(
                bgColor: const Color(0xFFF5F0E4),
                borderColor: AppColors.primary.withValues(alpha: 0.12),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pets_rounded,
                      size: compact ? 13 : 14,
                      color: AppColors.textSubtitleOnFrost,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      categoryText,
                      style: tagTextStyle.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              tagChip(
                bgColor: bg,
                borderColor: bg,
                label: Text(
                  statusText,
                  style: tagTextStyle.copyWith(color: fg),
                ),
              ),
            ],
          ),
          SizedBox(height: 6 * scale),
          Row(
            children: [
              Text(
                'Difficulty:',
                style: GoogleFonts.inter(
                  fontSize: compact
                      ? Adaptive.clamp(context, 10, min: 9, max: 12)
                      : Adaptive.clamp(context, 12, min: 10, max: 14),
                  color: AppColors.textSubtitleOnFrost,
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

    // Local helper keeps card tap handler concise in both layouts.
    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SpeciesDetailScreen(
            speciesId: s.id,
            selectedCity: _selectedCity,       // 🟢 SEND THE CITY FILTER
            selectedSiteId: _selectedSiteId,   // 🟢 SEND THE SITE FILTER
          ),
        ),
      );
    }

    if (compact) {
      Widget card = Card(
        key: ValueKey<String>('species-card-${s.id}-compact'),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: InkWell(
          onTap: openDetail,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SpeciesNetworkImage(
                  key: ValueKey<String>('species-image-${s.id}-${s.imageUrl}'),
                  url: s.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
              infoColumn,
            ],
          ),
        ),
      );
      if (tourAnchorCard) {
        card = TourAnchor(
          id: TourTargetIds.homeSpeciesCard,
          child: card,
        );
      }
      return card;
    }

    Widget card = Card(
      key: ValueKey<String>('species-card-${s.id}-list'),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: InkWell(
        onTap: openDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: double.infinity,
              height: imgH,
              child: SpeciesNetworkImage(
                key: ValueKey<String>('species-image-${s.id}-${s.imageUrl}'),
                url: s.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            infoColumn,
          ],
        ),
      ),
    );
    if (tourAnchorCard) {
      card = TourAnchor(
        id: TourTargetIds.homeSpeciesCard,
        child: card,
      );
    }
    return card;
  }
}
