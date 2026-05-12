import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/hadith.dart';

/// Generates PDF documents from hadith data and hands them to the OS's
/// "share / print / save-to-Files" sheet via the `printing` package.
///
/// Why a server-less PDF flow:
///   - No backend, no upload — matches the app's no-cloud guarantee.
///   - The user can save to Files, print on paper, or AirPrint /
///     Google Cloud Print to a physical printer.
///   - Generated entirely from bundled JSON + Cairo font; works offline.
///
/// The Cairo font is registered with the document so Arabic shaping uses
/// the same family the rest of the app uses, and English passages share
/// the same typeface for consistency.
class PdfExportService {
  static pw.Font? _cairoRegular;
  static pw.Font? _cairoBold;

  /// Lazily load + cache Cairo TTF data. Avoids re-reading the asset on
  /// every export. Called transparently by the export methods.
  static Future<void> _loadFonts() async {
    if (_cairoRegular != null && _cairoBold != null) return;
    final regular = await rootBundle
        .load('assets/fonts/static/Cairo-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/static/Cairo-Bold.ttf');
    _cairoRegular = pw.Font.ttf(regular);
    _cairoBold = pw.Font.ttf(bold);
  }

  /// Produce a PDF of a single hadith.
  static Future<Uint8List> exportSingle({
    required Hadith hadith,
    required int index,
    bool arabic = true,
  }) async {
    await _loadFonts();
    final pdf = pw.Document(
      title: 'Hadith $index — Forty Hadith Nawawi',
      author: 'Forty Hadith Nawawi (open source)',
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.fromLTRB(50, 60, 50, 50),
        textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(
          base: _cairoRegular!,
          bold: _cairoBold!,
        ),
        build: (context) => [
          _buildHeader(index, arabic),
          pw.SizedBox(height: 24),
          _buildTitle(hadith, arabic),
          pw.SizedBox(height: 16),
          _buildHadithBody(hadith, arabic),
          if (hadith.citation != null) ...[
            pw.SizedBox(height: 12),
            _buildCitation(hadith.citation!, arabic),
          ],
          pw.SizedBox(height: 24),
          _buildExplanation(hadith, arabic),
          pw.SizedBox(height: 32),
          _buildFooter(arabic),
        ],
      ),
    );

    return pdf.save();
  }

  /// Produce a single PDF containing all hadiths in [hadiths].
  static Future<Uint8List> exportAll({
    required List<Hadith> hadiths,
    bool arabic = true,
  }) async {
    await _loadFonts();
    final pdf = pw.Document(
      title: 'Forty Hadith Nawawi — Complete Collection',
      author: 'Forty Hadith Nawawi (open source)',
    );

    // Cover page.
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(
          base: _cairoRegular!,
          bold: _cairoBold!,
        ),
        build: (context) => pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                arabic ? 'الأربعون النووية' : 'Forty Hadith Nawawi',
                style: pw.TextStyle(fontSize: 48, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 24),
              pw.Text(
                arabic
                    ? 'اثنان وأربعون حديثاً نبوياً'
                    : '42 Prophetic Hadiths',
                style: const pw.TextStyle(fontSize: 24, color: PdfColors.grey700),
              ),
              pw.SizedBox(height: 80),
              pw.Text(
                arabic
                    ? 'صدقة جارية · مفتوح المصدر'
                    : 'Sadaqah Jariyah · Open Source',
                style: const pw.TextStyle(fontSize: 18, color: PdfColors.grey600),
              ),
            ],
          ),
        ),
      ),
    );

    // One MultiPage per hadith ensures page breaks fall at hadith
    // boundaries; the explanation can span pages within a hadith.
    for (var i = 0; i < hadiths.length; i++) {
      final h = hadiths[i];
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.fromLTRB(50, 60, 50, 50),
          textDirection: arabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(
            base: _cairoRegular!,
            bold: _cairoBold!,
          ),
          build: (context) => [
            _buildHeader(i + 1, arabic),
            pw.SizedBox(height: 16),
            _buildTitle(h, arabic),
            pw.SizedBox(height: 12),
            _buildHadithBody(h, arabic),
            if (h.citation != null) ...[
              pw.SizedBox(height: 8),
              _buildCitation(h.citation!, arabic),
            ],
            pw.SizedBox(height: 20),
            _buildExplanation(h, arabic),
          ],
        ),
      );
    }

    return pdf.save();
  }

  /// Trigger the OS share / print dialog for the given PDF bytes.
  static Future<void> shareOrPrint({
    required Uint8List bytes,
    required String fileName,
  }) async {
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  // ─── Layout helpers ───────────────────────────────────────────────

  static pw.Widget _buildHeader(int index, bool arabic) {
    final label = arabic ? 'الحديث $index' : 'Hadith $index';
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 16,
            color: PdfColor.fromHex('#C9A961'),
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Container(height: 1, color: PdfColor.fromHex('#1F6E3A')),
      ],
    );
  }

  static pw.Widget _buildTitle(Hadith hadith, bool arabic) {
    final title = arabic ? hadith.titleAr : hadith.titleEn;
    if (title.isEmpty) return pw.SizedBox();
    return pw.Center(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 22,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#1F6E3A'),
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildHadithBody(Hadith hadith, bool arabic) {
    final body = arabic ? hadith.hadithAr : hadith.hadithEn;
    final lines = body.split('\n');
    final displayText = lines.length > 1 ? lines.skip(1).join('\n').trim() : body;
    return pw.Text(
      displayText,
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        height: 1.7,
      ),
      textAlign: pw.TextAlign.justify,
    );
  }

  static pw.Widget _buildCitation(HadithCitation citation, bool arabic) {
    final narrator = arabic ? citation.narratorAr : citation.narratorEn;
    final source = arabic ? citation.collectionAr : citation.collectionEn;
    final intro = arabic ? 'رواه' : 'Narrated by';
    final from = arabic ? 'عن' : 'from';
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#F4ECD8'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Text(
        '$intro $source $from $narrator',
        style: pw.TextStyle(
          fontSize: 12,
          color: PdfColor.fromHex('#6E5B47'),
          fontStyle: pw.FontStyle.italic,
        ),
      ),
    );
  }

  static pw.Widget _buildExplanation(Hadith hadith, bool arabic) {
    final desc = arabic ? hadith.descriptionAr : hadith.descriptionEn;
    if (desc.isEmpty) return pw.SizedBox();
    return pw.Column(
      crossAxisAlignment: arabic
          ? pw.CrossAxisAlignment.end
          : pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          arabic ? 'الشرح' : 'Explanation',
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#1F6E3A'),
          ),
        ),
        pw.SizedBox(height: 8),
        // Strip markdown markers for a clean plain-text rendering in PDF.
        // A future iteration could render the markdown properly using a
        // dedicated parser; for now the text is readable as-is.
        pw.Text(
          _stripMarkdown(desc),
          style: const pw.TextStyle(fontSize: 12, height: 1.6),
          textAlign: pw.TextAlign.justify,
        ),
      ],
    );
  }

  static pw.Widget _buildFooter(bool arabic) {
    final text = arabic
        ? 'صدقة جارية · مفتوح المصدر · لا تنسَ من دعا لكاتبه'
        : 'Sadaqah Jariyah · Open Source · Please make du\'a for those who shared it';
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 12),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Center(
        child: pw.Text(
          text,
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
      ),
    );
  }

  /// Minimal markdown stripper. Removes the noise (`#`, `*`, `>`, etc.)
  /// so the PDF is plain-text readable. We don't render headings styled
  /// in PDF — keeping it simple and predictable.
  static String _stripMarkdown(String md) {
    return md
        .replaceAll(RegExp(r'^\s*#{1,6}\s*', multiLine: true), '')
        .replaceAll(RegExp(r'^\s*>\s*', multiLine: true), '')
        .replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1')
        .replaceAll(RegExp(r'\*([^*]+)\*'), r'$1')
        .replaceAll(RegExp(r'^\s*-\s+', multiLine: true), '• ')
        .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');
  }
}
