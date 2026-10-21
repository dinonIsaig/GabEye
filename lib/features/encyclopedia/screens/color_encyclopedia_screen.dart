import 'package:flutter/material.dart';
import 'package:gabeye/components/navbar/article_navbar.dart';
import 'package:gabeye/core/routing/app_routes.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import '../services/color_encyclopedia_service.dart';
import '../widgets/color_quiz_dialog.dart';
import '../widgets/color_quiz_intro_dialog.dart';

class ColorEncyclopediaScreen extends StatefulWidget {
  const ColorEncyclopediaScreen({super.key});

  @override
  State<ColorEncyclopediaScreen> createState() =>
      _ColorEncyclopediaScreenState();
}

class _ColorEncyclopediaScreenState extends State<ColorEncyclopediaScreen> {
  // Initialize synchronously so the page renders immediately without any blank screen
  late List<IsccNbsColorEntry> _allColors;

  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _currentPage = 0;
  static const int _pageSize = 20;

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filterCategories = [
    'All',
    'Red',
    'Pink',
    'Orange',
    'Brown',
    'Yellow',
    'Olive',
    'Green',
    'Blue',
    'Violet',
    'Purple',
    'Neutral',
  ];

  @override
  void initState() {
    super.initState();
    _allColors = IsccNbsColorDataset.getAllColorsSync();
    _loadDatasetAsync();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDatasetAsync() async {
    final dataset = await IsccNbsColorDataset.loadDataset();
    if (mounted && dataset.isNotEmpty) {
      setState(() {
        _allColors = dataset;
      });
    }
  }

  List<IsccNbsColorEntry> get _filteredColors {
    return _allColors.where((color) {
      // Category filter
      final umbrella = ColorEncyclopediaService.extractUmbrellaTerm(color.name);
      if (_selectedCategory != 'All') {
        if (_selectedCategory == 'Neutral') {
          if (umbrella != 'White' &&
              umbrella != 'Gray' &&
              umbrella != 'Black') {
            return false;
          }
        } else if (umbrella.toLowerCase() != _selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatches = color.name.toLowerCase().contains(q);
        final hexMatches = color.hex.toLowerCase().contains(q);
        final umbrellaMatches = umbrella.toLowerCase().contains(q);
        if (!nameMatches && !hexMatches && !umbrellaMatches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  void _onPlayTapped() {
    ColorQuizIntroDialog.show(
      context,
      onStart: () {
        ColorQuizDialog.show(context, dataset: _allColors);
      },
    );
  }

  void _showColorDetails(IsccNbsColorEntry entry) {
    final color = ColorEncyclopediaService.entryToColor(entry);
    final umbrella = ColorEncyclopediaService.extractUmbrellaTerm(entry.name);
    final explanation = ColorEncyclopediaService.getEducationalExplanation(
      entry,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // True color swatch box
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black26, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                entry.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Umbrella Family: $umbrella',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Hex Code', entry.hex.toUpperCase()),
                    const Divider(height: 12),
                    _buildDetailRow(
                      'RGB',
                      'R: ${entry.r ?? 0}, G: ${entry.g ?? 0}, B: ${entry.b ?? 0}',
                    ),
                    const Divider(height: 12),
                    _buildDetailRow(
                      'HSV',
                      'H: ${entry.hue.round()}°, S: ${(entry.saturation * 100).round()}%, V: ${(entry.value * 100).round()}%',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                explanation,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.35,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: GabEyeArticleNavbar(
          title: 'Color Encyclopedia',
          onBack: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final viewportWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
            final contentWidth = (viewportWidth - 32).clamp(0.0, 800.0);

            return SingleChildScrollView(
              child: SizedBox(
                width: viewportWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroHeader(context),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      child: Center(
                        child: SizedBox(
                          width: contentWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildIntroCard(context, isDark),
                              const SizedBox(height: 14),
                              _buildPlayChallengeCard(context, isDark),
                              const SizedBox(height: 16),
                              _buildSearchAndFilters(context, isDark),
                              const SizedBox(height: 16),
                              _buildColorGrid(context, isDark),
                              const SizedBox(height: 16),
                              _buildPaginationControls(context, isDark),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroHeader(BuildContext context) {
    return SizedBox(
      height: 130,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Image.asset(
                'assets/images/articleHeading.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) {
                  return Container(color: AppColors.deepNavy);
                },
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 16,
            child: const Text(
              'Color Encyclopedia',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surface.withValues(alpha: 0.6)
            : AppColors.iconChipTint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book_outlined,
                size: 20,
                color: isDark
                    ? AppColors.darkPrimaryButton
                    : AppColors.deepNavy,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Standardized Color Names (ISCC-NBS)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkPrimaryButton
                        : AppColors.deepNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Ever wondered what shade lies between pink and red, or olive and green? The ISCC-NBS universal system replaces vague guesses with exact, standardized names (such as "Vivid Red" or "Light Grayish Blue") by measuring true lightness and saturation. Browse 260+ standard colors below to expand your vocabulary.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayChallengeCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.darkPrimaryButton : AppColors.deepNavy)
              .withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkPrimaryButton.withValues(alpha: 0.15)
                  : AppColors.iconChipTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.style_outlined,
              color: isDark ? AppColors.darkPrimaryButton : AppColors.deepNavy,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color Flashcard Quiz',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Test your eye with 5 quick color flashcards!',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark
                  ? AppColors.darkPrimaryButton
                  : AppColors.deepNavy,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 55),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: _onPlayTapped,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text(
              'Play Quiz',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by color name or hex (e.g. Vivid Red, #D5)...',
            hintStyle: TextStyle(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                        _currentPage = 0;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
          ),
          onChanged: (val) {
            setState(() {
              _searchQuery = val.trim();
              _currentPage = 0;
            });
          },
        ),

        const SizedBox(height: 10),

        // Category Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filterCategories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: FilterChip(
                  label: Text(
                    cat,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: isDark
                      ? AppColors.darkPrimaryButton
                      : AppColors.deepNavy,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  checkmarkColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.transparent
                          : colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = cat;
                      _currentPage = 0;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildColorGrid(BuildContext context, bool isDark) {
    final colors = _filteredColors;
    final totalColors = colors.length;

    if (totalColors == 0) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 10),
            Text(
              'No colors found matching your filter.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final startIndex = _currentPage * _pageSize;
    final endIndex = (startIndex + _pageSize < totalColors)
        ? startIndex + _pageSize
        : totalColors;
    final pageColors = colors.sublist(startIndex, endIndex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            children: [
              Text(
                'Showing ${startIndex + 1}–$endIndex of $totalColors colors',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Page ${_currentPage + 1} of ${((totalColors - 1) ~/ _pageSize) + 1}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Two Column Grid with fixed height cards to prevent overflow
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pageColors.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            mainAxisExtent: 74,
          ),
          itemBuilder: (ctx, idx) {
            final entry = pageColors[idx];
            return _buildColorCard(ctx, entry, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildColorCard(
    BuildContext context,
    IsccNbsColorEntry entry,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actualColor = ColorEncyclopediaService.entryToColor(entry);

    return InkWell(
      onTap: () => _showColorDetails(entry),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: isDark ? 0.25 : 0.4),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Authentic Color Box (Isolated & Immune to theme alterations)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: actualColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Color Name and Hex
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.2,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.hex.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(BuildContext context, bool isDark) {
    final totalColors = _filteredColors.length;
    if (totalColors <= _pageSize) return const SizedBox.shrink();

    final totalPages = ((totalColors - 1) ~/ _pageSize) + 1;
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_left, size: 18),
          label: const Text('Previous', style: TextStyle(fontSize: 12)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '${_currentPage + 1} / $totalPages',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: const Icon(Icons.chevron_right, size: 18),
          label: const Text('Next', style: TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}
