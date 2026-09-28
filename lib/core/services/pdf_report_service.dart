import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart' show BuildContext;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:gabeye/core/services/vision_profile_service.dart';
import 'package:gabeye/features/assessment/models/cap.dart';
import 'package:gabeye/features/assessment/services/scoring_service.dart';

/// Generates a detailed, publication-quality PDF report of the user's Vision Profile
/// and Farnsworth D-15 assessment metrics for eye care professionals' reference.
class PdfReportService {
  PdfReportService._();

  static Future<void> generateAndExportPdf(
    BuildContext context, {
    D15ScoreResult? scoreResult,
    List<int>? arrangedCaps,
  }) async {
    final caps = arrangedCaps ?? VisionProfileService.instance.arrangedCaps;
    final result = scoreResult ?? VisionProfileService.instance.value;

    final filename = result != null
        ? 'GabEye_Vision_Report_${result.shortName}_${DateTime.now().millisecondsSinceEpoch}.pdf'
        : 'GabEye_Vision_Report_Baseline_${DateTime.now().millisecondsSinceEpoch}.pdf';

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => buildPdfDocument(
        scoreResult: result,
        arrangedCaps: caps,
        pageFormat: format,
      ),
      name: filename,
    );
  }

  /// Builds the raw PDF document bytes.
  static Future<Uint8List> buildPdfDocument({
    required D15ScoreResult? scoreResult,
    required List<int> arrangedCaps,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pdf = pw.Document(
      title: 'GabEye Vision Profile Report',
      author: 'GabEye Vision Health System',
      subject: 'Farnsworth D-15 Color Vision Assessment & Quantitative Report',
    );

    final result = scoreResult ?? ScoringService.calculateScore(arrangedCaps);
    
    final severityColor = _getSeverityPdfColor(result.severityLabel);
    final diagnosisColor = _getDiagnosisPrimaryColor(result.diagnosisType);
    final formattedDate = _formatCurrentDate();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        header: (pw.Context ctx) => _buildPdfHeader(formattedDate),
        footer: (pw.Context ctx) => _buildPdfFooter(ctx),
        build: (pw.Context ctx) => [
          pw.SizedBox(height: 12),
          _buildExecutiveSummary(result, severityColor, diagnosisColor),
          pw.SizedBox(height: 16),
          _buildQuantitativeMetricsTable(result),
          pw.SizedBox(height: 16),
          _buildCapArrangementSection(arrangedCaps, result),
          // Sized box removed here; spacing is now handled securely inside the unbreakable Wrap below
          _buildConfusionPlotSection(arrangedCaps, result, pageFormat),
          pw.SizedBox(height: 16),
          _buildClinicalInterpretationGuide(),
          pw.SizedBox(height: 16),
          _buildMedicalDisclaimer(),
        ],
      ),
    );

    return pdf.save();
  }

  // ---------------------------------------------------------------------------
  // PDF Section Builders
  // ---------------------------------------------------------------------------

  static pw.Widget _buildPdfHeader(String formattedDate) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.blueGrey700, width: 1.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GabEye',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'COLOR VISION HEALTH & DALTONIZATION ANALYTICS',
                style: const pw.TextStyle(
                  fontSize: 7,
                  color: PdfColors.grey700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'CLINICAL VISION ASSESSMENT REPORT',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey900,
                ),
              ),
              pw.Text(
                'Farnsworth D-15 Quantitative Analysis',
                style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700),
              ),
              pw.Text(
                'Date: $formattedDate',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context ctx) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.only(top: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'GabEye | Professional Vision Reference | Confidential Medical Data',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
          pw.Text(
            'Page ${ctx.pageNumber} of ${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(D15ScoreResult result, PdfColor severityColor, PdfColor diagnosisColor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PRIMARY DIAGNOSIS SUMMARY',
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    _sanitizeText(result.diagnosisName),
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: diagnosisColor, 
                    ),
                  ),
                ],
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  color: severityColor, 
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  _sanitizeText('Severity: ${result.severityLabel}'),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey300, thickness: 0.5),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: _buildSummaryField('Affected Photopigments / Cones', result.conesAffected),
              ),
              pw.Expanded(
                child: _buildSummaryField('Classification Band', result.rangeHeadline),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Clinical Summary:',
            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            _sanitizeText(result.description.isNotEmpty ? result.description : result.rangeBody),
            style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey900, lineSpacing: 1.3),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryField(String label, String value) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700)),
        pw.Text(_sanitizeText(value), style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
      ],
    );
  }

  static pw.Widget _buildQuantitativeMetricsTable(D15ScoreResult result) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'QUANTITATIVE D-15 METRICS (Vingrys & King-Smith Methodology)',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
        ),
        pw.SizedBox(height: 6),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.2),
            1: pw.FlexColumnWidth(1.2),
            2: pw.FlexColumnWidth(1.6),
            3: pw.FlexColumnWidth(3.0),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
              children: [
                _buildTableCell('Metric Indicator', isHeader: true),
                _buildTableCell('Observed Value', isHeader: true),
                _buildTableCell('Clinical Cutoff', isHeader: true),
                _buildTableCell('Diagnostic Significance', isHeader: true),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Confusion Index (C-Index)'),
                _buildTableCell(result.cIndex.toStringAsFixed(2), bold: true),
                _buildTableCell('<= 1.78 (Normal)'),
                _buildTableCell('Quantifies overall error magnitude. >1.78 indicates significant deficiency.'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Selectivity Index (S-Index)'),
                _buildTableCell(result.sIndex.toStringAsFixed(2), bold: true),
                _buildTableCell('>= 2.00 (Polar)'),
                _buildTableCell('Quantifies error alignment along a single axis. >=2.0 indicates polar deficiency.'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Major Error Angle'),
                _buildTableCell('${result.angle.toStringAsFixed(1)} deg', bold: true),
                _buildTableCell('Axis Sectors*'),
                _buildTableCell('Identifies specific axis: Protan (+3 to +17), Deutan (-11 to -4), Tritan (-90 to -70).'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Major Radius (r0)'),
                _buildTableCell(result.majorRadius.toStringAsFixed(2)),
                _buildTableCell('9.23 (Ref)'),
                _buildTableCell('Magnitude of error dispersion along the major axis.'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Minor Radius (r1)'),
                _buildTableCell(result.minorRadius.toStringAsFixed(2)),
                _buildTableCell('--'),
                _buildTableCell('Magnitude of error dispersion along the minor axis.'),
              ],
            ),
            pw.TableRow(
              children: [
                _buildTableCell('Total Error Score (Stotal)'),
                _buildTableCell(result.totalError.toStringAsFixed(2)),
                _buildTableCell('--'),
                _buildTableCell('Overall chromaticity vector length sqrt(r0^2 + r1^2).'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false, bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: pw.Text(
        _sanitizeText(text),
        style: pw.TextStyle(
          fontSize: isHeader ? 8 : 7.5,
          fontWeight: isHeader || bold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.blueGrey900 : PdfColors.grey900,
        ),
      ),
    );
  }

  static pw.Widget _buildCapArrangementSection(List<int> arrangedCaps, D15ScoreResult result) {
    final fullSequence = [0, ...arrangedCaps];
    final Set<int> majorCrossingCaps = {};
    for (var err in result.crossings) {
      if (err.isMajor) {
        majorCrossingCaps.add(err.capA);
        majorCrossingCaps.add(err.capB);
      }
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'D-15 CAP ARRANGEMENT SEQUENCE & CROSSINGS',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
        ),
        pw.SizedBox(height: 6),
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey50,
            borderRadius: pw.BorderRadius.circular(6),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Ordered Cap Sequence:',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
              ),
              pw.SizedBox(height: 6),
              pw.Wrap(
                spacing: 4,
                runSpacing: 4,
                children: fullSequence.map((capNum) {
                  final colorData = ColorCap.allCaps[capNum];
                  final isPilot = capNum == 0;
                  final hasMajorCrossing = majorCrossingCaps.contains(capNum);

                  final pdfRgb = PdfColor(
                    colorData.rgb.r,
                    colorData.rgb.g,
                    colorData.rgb.b,
                  );

                  final borderColor = isPilot ? PdfColors.black : (hasMajorCrossing ? PdfColors.red800 : PdfColors.grey400);
                  final borderWidth = isPilot ? 1.5 : (hasMajorCrossing ? 1.5 : 0.5);

                  return pw.Container(
                    width: 28,
                    height: 22,
                    decoration: pw.BoxDecoration(
                      color: pdfRgb,
                      borderRadius: pw.BorderRadius.circular(4),
                      border: pw.Border.all(
                        color: borderColor,
                        width: borderWidth,
                      ),
                    ),
                    alignment: pw.Alignment.center,
                    child: pw.Text(
                      isPilot ? 'P' : '$capNum',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'Transposition Errors & Crossovers (${result.crossings.length} Total):',
          style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.grey800),
        ),
        pw.SizedBox(height: 4),
        if (result.crossings.isEmpty)
          pw.Text(
            'No crossing errors detected. Perfect cap arrangement.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.green800),
          )
        else
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: const {
              0: pw.FlexColumnWidth(1.5),
              1: pw.FlexColumnWidth(1.5),
              2: pw.FlexColumnWidth(2.0),
              3: pw.FlexColumnWidth(3.0),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('From Cap', isHeader: true),
                  _buildTableCell('To Cap', isHeader: true),
                  _buildTableCell('Cap Distance', isHeader: true),
                  _buildTableCell('Error Classification', isHeader: true),
                ],
              ),
              ...result.crossings.map((err) {
                return pw.TableRow(
                  children: [
                    _buildTableCell('Cap ${err.capA}'),
                    _buildTableCell('Cap ${err.capB}'),
                    _buildTableCell('Distance: ${err.distance}'),
                    _buildTableCell(
                      err.isMajor ? 'Major Crossover (dist >= 4)' : 'Minor Swap (dist < 4)',
                      bold: err.isMajor,
                    ),
                  ],
                );
              }),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildConfusionPlotSection(List<int> arrangedCaps, D15ScoreResult result, PdfPageFormat format) {
    final double availableWidth = format.availableWidth - 64; 
    
    final double boxSize = math.min(availableWidth * 0.65, 260);
    final double innerSize = boxSize - 16;
    final double center = innerSize / 2;
    final double radius = center - 24; 
    final double cap0Angle = math.pi;

    final List<pw.Widget> stackChildren = [
      pw.CustomPaint(
        size: PdfPoint(innerSize, innerSize),
        painter: (PdfGraphics canvas, PdfPoint size) {
          _paintPdfConfusionDiagram(canvas, size, arrangedCaps, center, center, radius, cap0Angle);
        },
      ),
    ];

    for (int i = 0; i < 16; i++) {
      final angle = cap0Angle + (i / 16.0) * 2 * math.pi;
      final labelRadius = radius + 15;
      final lx = center + labelRadius * math.cos(angle);

      // Changed from '-' to '+' to invert the label drawing map correctly to clockwise
      final ly = center + labelRadius * math.sin(angle);

      stackChildren.add(
        pw.Positioned(
          left: lx - 10,
          bottom: ly - 10,
          child: pw.Container(
            width: 20,
            height: 20,
            alignment: pw.Alignment.center,
            child: pw.Text(
              '$i',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey900,
              ),
            ),
          ),
        ),
      );
    }

    // Wrapping the entire section in a Wrap ensures that the title and plot are treated as an 
    // atomic, unbreakable block, preventing the header from being split on the preceding page.
    return pw.Wrap(
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.SizedBox(height: 24), // Added padding space above the card/title as requested
            pw.Text(
              'CIE L*u*v* CHROMATICITY CONFUSION DIAGRAM',
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900),
            ),
            pw.SizedBox(height: 16), 
            pw.Center(
              child: pw.Container(
                width: boxSize,
                height: boxSize,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                ),
                child: pw.Stack(
                  children: stackChildren,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static void _paintPdfConfusionDiagram(
    PdfGraphics canvas, 
    PdfPoint size, 
    List<int> arrangedCaps,
    double centerX,
    double centerY,
    double radius,
    double cap0Angle,
  ) {
    final double originalCode2Start = 135 * math.pi / 180;
    final double rotationOffset = cap0Angle - originalCode2Start;

    canvas.setStrokeColor(PdfColors.grey400);
    canvas.setLineWidth(1.0);
    canvas.drawEllipse(centerX, centerY, radius, radius);
    canvas.strokePath();

    void drawPdfAxis(double angleRad, PdfColor color, double shiftX, double shiftY) {
      final x_f_shift = shiftX * math.cos(rotationOffset) - shiftY * math.sin(rotationOffset);
      final y_f_shift = shiftX * math.sin(rotationOffset) + shiftY * math.cos(rotationOffset);

      final axisCenterX = centerX + x_f_shift;
      final axisCenterY = centerY + y_f_shift; // Changed from '-' to '+' to invert Y axes 

      final finalAngle = angleRad + rotationOffset;
      final dx_f = math.cos(finalAngle) * radius;
      final dy_f = math.sin(finalAngle) * radius;

      final startX = axisCenterX - dx_f;
      final startY = axisCenterY - dy_f; // Changed from '+' to '-' 
      final endX = axisCenterX + dx_f;
      final endY = axisCenterY + dy_f;   // Changed from '-' to '+'
      
      canvas.setStrokeColor(color);
      canvas.setLineWidth(1.2);

      const int dashCount = 15;
      for (int i = 0; i < dashCount; i++) {
        if (i % 2 == 0) {
          final tStart = i / dashCount;
          final tEnd = (i + 1) / dashCount;
          final pStartX = startX + (endX - startX) * tStart;
          final pStartY = startY + (endY - startY) * tStart;
          final pEndX = startX + (endX - startX) * tEnd;
          final pEndY = startY + (endY - startY) * tEnd;
          canvas.drawLine(pStartX, pStartY, pEndX, pEndY);
          canvas.strokePath();
        }
      }
    }

    drawPdfAxis(-124 * math.pi / 180, PdfColor.fromInt(0xFFF5CB20), -40, 25); // Deutan (Murky)
    drawPdfAxis(-146 * math.pi / 180, PdfColor.fromInt(0xFFF19C92), -23, 30); // Protan (Salmon)
    drawPdfAxis(-62 * math.pi / 180, PdfColor.fromInt(0xFF018F8F), 13, 0);   // Tritan (Blue)

    final fullList = [0, ...arrangedCaps];

    for (int i = 0; i < fullList.length - 1; i++) {
      final capA = fullList[i];
      final capB = fullList[i + 1];

      final angleA = cap0Angle + (capA / 16.0) * 2 * math.pi;
      final angleB = cap0Angle + (capB / 16.0) * 2 * math.pi;

      final pAx = centerX + radius * math.cos(angleA);
      final pAy = centerY + radius * math.sin(angleA); // Changed from '-' to '+'
      final pBx = centerX + radius * math.cos(angleB);
      final pBy = centerY + radius * math.sin(angleB); // Changed from '-' to '+'

      final step = (capA - capB).abs();
      PdfColor segmentColor;
      double strokeWidth;

      if (step == 1 || step == 15) {
        segmentColor = PdfColors.grey500;
        strokeWidth = 1.5;
      } else if (step == 2 || step == 14) {
        segmentColor = PdfColor.fromInt(0xFF4CAF50); // Minor swap (Success green)
        strokeWidth = 2.0;
      } else {
        segmentColor = PdfColor.fromInt(0xFFD32F2F); // Major crossover (Error red)
        strokeWidth = 2.5;
      }

      canvas.setStrokeColor(segmentColor);
      canvas.setLineWidth(strokeWidth);
      canvas.drawLine(pAx, pAy, pBx, pBy);
      canvas.strokePath();
    }

    for (int i = 0; i < 16; i++) {
      final angle = cap0Angle + (i / 16.0) * 2 * math.pi;
      final ptX = centerX + radius * math.cos(angle);
      final ptY = centerY + radius * math.sin(angle); // Changed from '-' to '+'

      if (i == 0) {
        canvas.setFillColor(PdfColors.black);
        canvas.drawEllipse(ptX, ptY, 10, 10);
        canvas.fillPath();
      }

      final colorData = ColorCap.allCaps[i];
      final pdfRgb = PdfColor(colorData.rgb.r, colorData.rgb.g, colorData.rgb.b);

      canvas.setFillColor(pdfRgb);
      canvas.drawEllipse(ptX, ptY, 8, 8);
      canvas.fillPath();

      canvas.setStrokeColor(PdfColors.black);
      canvas.setLineWidth(0.5);
      canvas.drawEllipse(ptX, ptY, 8, 8);
      canvas.strokePath();
    }
  }

  static pw.Widget _buildClinicalInterpretationGuide() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.blue200, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            _sanitizeText('NOTES FOR EYE CARE PROFESSIONALS'),
            style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            _sanitizeText('- Standard Cutoff (C-Index = 1.78): Established by Vingrys & King-Smith (1988) based on 95th percentile confidence limits for normal trichromats.\n'
            '- Axis Selectivity (S-Index >= 2.0): S-Index represents the ratio of major to minor dispersion radii (r0/r1). Values >= 2.0 indicate specific cone-pigment deficiency alignment.\n'
            '- Daltonization Uniforms: GabEye uses these quantitative metrics to dynamically calibrate GLSL LMS Daltonization shader algorithms for LMS photopigment error correction.'),
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey800, lineSpacing: 1.3),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildMedicalDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        _sanitizeText('DISCLAIMER: This report is generated by GabEye using standardized CIE L*u*v* Farnsworth D-15 quantitative scoring algorithms. '
        'This document is intended as a screening reference for qualified eye care professionals (optometrists, ophthalmologists). '
        'Screening results should be validated with formal clinical equipment in controlled lighting environments.'),
        style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey700, lineSpacing: 1.2),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Utilities
  // ---------------------------------------------------------------------------

  /// Systematically removes problematic Unicode characters that crash base PDF fonts 
  static String _sanitizeText(String text) {
    return text
        .replaceAll('•', '-')
        .replaceAll('°', ' deg')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('≤', '<=')
        .replaceAll('≥', '>=')
        .replaceAll('±', '+/-');
  }

  static PdfColor _getDiagnosisPrimaryColor(ColorDeficiencyType type) {
    switch (type) {
      case ColorDeficiencyType.protan:
        return PdfColor.fromInt(0xFFA33612); // Matches AppSemanticColors.salmon
      case ColorDeficiencyType.deutan:
        return PdfColor.fromInt(0xFFF5CB20); // Matches AppSemanticColors.murky
      case ColorDeficiencyType.tritan:
        return PdfColor.fromInt(0xFF018F8F); // Matches AppSemanticColors.tritan
      case ColorDeficiencyType.normal:
        return PdfColor.fromInt(0xFF4CAF50); // Fallback Success Green
      case ColorDeficiencyType.unclassified:
      case ColorDeficiencyType.random:
        return PdfColor.fromInt(0xFF4E4E4E); // Fallback Neutral Grey
    }
  }

  static PdfColor _getSeverityPdfColor(String label) {
    final lowerLabel = label.toLowerCase();
    if (lowerLabel.contains('mild')) {
      return PdfColor.fromInt(0xFFFBC02D);
    } else if (lowerLabel.contains('moderate')) {
      return PdfColor.fromInt(0xFFF57C00);
    } else if (lowerLabel.contains('strong')) {
      return PdfColor.fromInt(0xFFD32F2F);
    } else if (lowerLabel.contains('normal')) {
      return PdfColor.fromInt(0xFF388E3C);
    }
    return PdfColor.fromInt(0xFF1976D2);
  }

  static String _formatCurrentDate() {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}