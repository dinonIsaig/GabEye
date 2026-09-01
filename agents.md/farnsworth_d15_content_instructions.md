# Instructions: Farnsworth D-15 Article Updates

## 1. Incorporate the Ishihara vs. D-15 comparison table into the code structure

The current `ArticleSection` model only supports `title`, `description`, and an
optional image/feature list — there's no way to render tabular data. Add table
support as follows:

1. **Add a data model** for a comparison table, next to `ArticleSection`:
   ```dart
   class ComparisonTable {
     final List<String> columnHeaders; // e.g. ['', 'Ishihara (dot test)', 'This test (D-15)']
     final List<List<String>> rows;    // each row: [rowLabel, col1Value, col2Value]

     ComparisonTable({required this.columnHeaders, required this.rows});
   }
   ```
2. **Extend `ArticleSection`** with an optional field:
   ```dart
   final ComparisonTable? table;
   ```
3. **Add a `ComparisonTableWidget`** that renders `ComparisonTable` using a
   `Table` widget: bold header row, bold row labels in the first column,
   rounded container with a light border/background to match the screenshot.
4. **Wire it into `ArticleSectionWidget`**: after the description text, if
   `section.table != null`, render `ComparisonTableWidget(table: section.table!)`.
5. **Populate the table** on the "How Is It Different From Other Tests?"
   section of `ArticleContent.farnsworthD15Content()`:
   ```dart
   ComparisonTable(
     columnHeaders: ['', 'Ishihara (dot test)', 'This test (D-15)'],
     rows: [
       ['What it catches', 'Mostly red green issues', 'Red green and blue yellow issues'],
       ['What you do', 'Spot a number', 'Sort discs by color'],
     ],
   )
   ```

## 2. Check every paragraph against a 25-word limit

For **each** `description` string in `ArticleContent.farnsworthD15Content()`:

1. Count the words in the paragraph (split on whitespace).
2. If the count is **25 words or fewer**, leave it as is.
3. If it **exceeds 25 words**, revise it:
   - Split it into two shorter `ArticleSection` entries (one with a `title`,
     the follow-up with `title: null` so it reads as a continuation), **or**
   - Trim the sentence directly, keeping the core meaning.
4. Re-count after revising to confirm each paragraph is under 25 words.
5. Repeat this check any time new copy is added to an article — it's not a
   one-time pass.

This was applied to the existing Farnsworth D-15 copy: the original "What is
the Farnsworth D-15 Test?" and "How Does It Figure Out My CVD Type?" paragraphs
were each over 25 words and have been split into shorter paragraphs.

## 3. Remove the "What Do My Results Mean?" section

Delete the entire `ArticleSection` with `title: 'What Do My Results Mean?'`
from `ArticleContent.farnsworthD15Content()`. Its content should not be merged
into another section — just remove the block outright, since the "Remember"
section already covers the personalization/no-diagnosis point.
