import 'package:flutter/material.dart';
import 'package:gabeye/core/theme/app_colors.dart';
import 'package:gabeye/features/knn/models/iscc_nbs_color_dataset.dart';
import '../services/color_encyclopedia_service.dart';

enum QuizAnswerState { none, correct, umbrella, wrong }

/// Interactive 5-color flashcard quiz dialog.
class ColorQuizDialog extends StatefulWidget {
  final List<IsccNbsColorEntry> dataset;

  const ColorQuizDialog({super.key, required this.dataset});

  static Future<void> show(BuildContext context, {required List<IsccNbsColorEntry> dataset}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ColorQuizDialog(dataset: dataset),
    );
  }

  @override
  State<ColorQuizDialog> createState() => _ColorQuizDialogState();
}

class _ColorQuizDialogState extends State<ColorQuizDialog> {
  late List<ColorQuizQuestion> _questions;
  int _currentIndex = 0;
  String? _selectedOption;
  QuizAnswerState _answerState = QuizAnswerState.none;

  int _exactCount = 0;
  int _umbrellaCount = 0;
  int _wrongCount = 0;
  bool _quizCompleted = false;

  @override
  void initState() {
    super.initState();
    _startNewQuiz();
  }

  void _startNewQuiz() {
    _questions = ColorEncyclopediaService.generateQuiz(widget.dataset);
    _currentIndex = 0;
    _selectedOption = null;
    _answerState = QuizAnswerState.none;
    _exactCount = 0;
    _umbrellaCount = 0;
    _wrongCount = 0;
    _quizCompleted = false;
  }

  void _handleOptionSelected(String option) {
    if (_answerState != QuizAnswerState.none) return;

    final currentQ = _questions[_currentIndex];
    setState(() {
      _selectedOption = option;
      if (option == currentQ.actualName) {
        _answerState = QuizAnswerState.correct;
        _exactCount++;
      } else if (option == currentQ.umbrellaTerm) {
        _answerState = QuizAnswerState.umbrella;
        _umbrellaCount++;
      } else {
        _answerState = QuizAnswerState.wrong;
        _wrongCount++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _answerState = QuizAnswerState.none;
      });
    } else {
      setState(() {
        _quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: _quizCompleted
              ? _buildCompletionView(context, isDark)
              : _buildQuestionView(context, isDark),
        ),
      ),
    );
  }

  Widget _buildQuestionView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_questions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Unable to load color quiz questions.',
            style: TextStyle(color: colorScheme.onSurface),
          ),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final color = ColorEncyclopediaService.entryToColor(currentQ.entry);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Progress & Close Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkPrimaryButton.withValues(alpha: 0.15)
                      : AppColors.iconChipTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Color ${_currentIndex + 1} of ${_questions.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimaryButton : AppColors.deepNavy,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Exit Quiz',
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Authentic Color Box (Isolated from Theme Alterations)
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Question Prompt (in plain English)
          Text(
            'What is the name of this color?',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          // 3 Options
          ...currentQ.options.map((option) {
            return _buildOptionButton(
              context: context,
              option: option,
              currentQ: currentQ,
              isDark: isDark,
            );
          }),

          // Educational Feedback Card (Appears upon answer selection)
          if (_answerState != QuizAnswerState.none) ...[
            const SizedBox(height: 14),
            _buildFeedbackCard(context, currentQ),
            const SizedBox(height: 14),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkPrimaryButton
                    : AppColors.deepNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _nextQuestion,
              child: Text(
                _currentIndex < _questions.length - 1
                    ? 'Next Color'
                    : 'See Results',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required String option,
    required ColorQuizQuestion currentQ,
    required bool isDark,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedOption == option;
    final hasAnswered = _answerState != QuizAnswerState.none;

    Color? backgroundColor;
    Color borderColor = colorScheme.outlineVariant;
    Color textColor = colorScheme.onSurface;
    IconData? trailingIcon;

    if (hasAnswered) {
      if (option == currentQ.actualName) {
        // Correct option
        backgroundColor = Colors.green.withValues(alpha: isDark ? 0.25 : 0.12);
        borderColor = Colors.green.shade600;
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
        trailingIcon = Icons.check_circle_outline;
      } else if (isSelected && option == currentQ.umbrellaTerm) {
        // Umbrella chosen
        backgroundColor = Colors.amber.withValues(alpha: isDark ? 0.25 : 0.15);
        borderColor = Colors.amber.shade700;
        textColor = isDark ? Colors.amber.shade300 : Colors.orange.shade900;
        trailingIcon = Icons.info_outline;
      } else if (isSelected) {
        // Wrong chosen
        backgroundColor = Colors.red.withValues(alpha: isDark ? 0.25 : 0.12);
        borderColor = Colors.red.shade600;
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
        trailingIcon = Icons.cancel_outlined;
      } else {
        borderColor = colorScheme.outlineVariant.withValues(alpha: 0.3);
        textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      }
    } else {
      // borderColor already defaults to colorScheme.outlineVariant
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: InkWell(
        onTap: hasAnswered ? null : () => _handleOptionSelected(option),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor ?? colorScheme.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: (isSelected || (hasAnswered && option == currentQ.actualName))
                  ? 1.8
                  : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 20, color: textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(BuildContext context, ColorQuizQuestion currentQ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final explanation = ColorEncyclopediaService.getEducationalExplanation(currentQ.entry);

    Color bg;
    Color border;
    Color titleColor;
    String titleText;
    String bodyText;
    IconData icon;

    switch (_answerState) {
      case QuizAnswerState.correct:
        bg = Colors.green.withValues(alpha: isDark ? 0.2 : 0.1);
        border = Colors.green.withValues(alpha: 0.5);
        titleColor = isDark ? Colors.green.shade300 : Colors.green.shade800;
        titleText = 'Spot on!';
        bodyText = 'That is the exact standardized name. $explanation';
        icon = Icons.check_circle;
        break;
      case QuizAnswerState.umbrella:
        bg = Colors.amber.withValues(alpha: isDark ? 0.2 : 0.12);
        border = Colors.amber.withValues(alpha: 0.6);
        titleColor = isDark ? Colors.amber.shade300 : Colors.orange.shade900;
        titleText = 'Close — that is the broad category!';
        bodyText =
            'It is not actually right or wrong, but there is a more specific name. While this shade is part of the "${currentQ.umbrellaTerm}" family, its precise standard name is "${currentQ.actualName}". $explanation';
        icon = Icons.lightbulb_outline;
        break;
      case QuizAnswerState.wrong:
      default:
        bg = Colors.red.withValues(alpha: isDark ? 0.2 : 0.1);
        border = Colors.red.withValues(alpha: 0.5);
        titleColor = isDark ? Colors.red.shade300 : Colors.red.shade800;
        titleText = 'Not quite!';
        bodyText =
            'The correct standardized name is "${currentQ.actualName}". It belongs to the ${currentQ.umbrellaTerm} family. $explanation';
        icon = Icons.help_outline;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: titleColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  bodyText,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.35,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionView(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.emoji_events_outlined,
          size: 48,
          color: isDark ? AppColors.darkPrimaryButton : AppColors.deepNavy,
        ),
        const SizedBox(height: 12),
        Text(
          'Quiz Complete!',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Here is how you identified the 5 colors:',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),

        // Score Breakdown
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              _buildScoreRow('Exact Names', '$_exactCount / 5', Colors.green),
              const Divider(height: 16),
              _buildScoreRow('Umbrella Terms', '$_umbrellaCount / 5', Colors.orange),
              const Divider(height: 16),
              _buildScoreRow('Missed', '$_wrongCount / 5', Colors.red),
            ],
          ),
        ),

        const SizedBox(height: 18),
        Text(
          _exactCount >= 4
              ? 'Outstanding! You have a sharp eye for standardized color names.'
              : _exactCount + _umbrellaCount >= 3
                  ? 'Good work! You recognize color families well. With practice, the modifiers will become second nature.'
                  : 'Keep exploring the encyclopedia to build your color naming intuition!',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),

        const SizedBox(height: 22),

        // Action Buttons: Play Again & Close
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Back to Guide'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimaryButton
                      : AppColors.deepNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _startNewQuiz();
                  });
                },
                child: const Text('Play Again'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
