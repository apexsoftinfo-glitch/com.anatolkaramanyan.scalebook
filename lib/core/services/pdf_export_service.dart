import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../features/home/domain/models/model_project.dart';

class PdfExportService {
  static Future<Uint8List> generateProgressPdf({
    required dynamic project,
    required List<dynamic> steps,
  }) async {
    try {
      final pdf = pw.Document();
      
      // Load fonts
      pw.Font? fontRegular;
      pw.Font? fontBold;
      try {
        fontRegular = await PdfGoogleFonts.robotoRegular().timeout(const Duration(seconds: 10));
        fontBold = await PdfGoogleFonts.robotoBold().timeout(const Duration(seconds: 10));
      } catch (_) {}

      // Load all images for selected steps
      final stepImages = await Future.wait(
        steps.map((s) => _loadPdfImage(s.imageUrl)),
      );

      // Group steps by 4 for A4 pages
      for (var i = 0; i < steps.length; i += 4) {
        final chunk = steps.skip(i).take(4).toList();
        final chunkImages = stepImages.skip(i).take(4).toList();
        
        // Determine page format: if last chunk and count is odd, use A5
        final isLastChunk = i + 4 >= steps.length;
        final isOdd = chunk.length % 2 != 0;
        final format = (isLastChunk && isOdd) ? PdfPageFormat.a5 : PdfPageFormat.a4;

        pdf.addPage(
          pw.Page(
            pageFormat: format,
            theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('ARKUSZ POSTĘPÓW: ${project.title.toUpperCase()}', 
                    style: pw.TextStyle(fontSize: format == PdfPageFormat.a5 ? 12 : 14, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                  pw.Divider(color: PdfColors.grey300),
                  pw.SizedBox(height: 10),
                  
                  // Grid layout for steps
                  pw.Expanded(
                    child: pw.GridView(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                      children: List.generate(chunk.length, (index) {
                        final step = chunk[index];
                        final img = chunkImages[index];
                        return pw.Container(
                          padding: const pw.EdgeInsets.all(5),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColors.grey200),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              if (img != null)
                                pw.Expanded(
                                  child: pw.Center(
                                    child: pw.Image(img, fit: pw.BoxFit.contain),
                                  ),
                                )
                              else
                                pw.Expanded(
                                  child: pw.Center(
                                    child: pw.Text('BRAK ZDJĘCIA', style: const pw.TextStyle(color: PdfColors.grey300, fontSize: 8)),
                                  ),
                                ),
                              pw.SizedBox(height: 5),
                              pw.Text('${step.date.day}.${step.date.month}.${step.date.year}', 
                                style: const pw.TextStyle(fontSize: 8, color: PdfColors.blueGrey700)),
                              pw.SizedBox(height: 2),
                              pw.Text(step.note, 
                                style: const pw.TextStyle(fontSize: 9),
                                maxLines: 3,
                                overflow: pw.TextOverflow.clip,
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }

      return await pdf.save();
    } catch (e) {
      debugPrint('BŁĄD PDF PROGRESS: $e');
      rethrow;
    }
  }

  static Future<Uint8List> generateProjectHistoryPdf({
    required ModelProject project,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd.MM.yyyy');
      
      // Load fonts
      pw.Font? fontRegular;
      pw.Font? fontBold;
      try {
        fontRegular = await PdfGoogleFonts.robotoRegular().timeout(const Duration(seconds: 10));
        fontBold = await PdfGoogleFonts.robotoBold().timeout(const Duration(seconds: 10));
      } catch (_) {}

      // Load main image and step images
      final mainImage = await _loadPdfImage(project.mainImageUrl);
      final stepImages = await Future.wait(
        project.steps.map((s) => _loadPdfImage(s.imageUrl)),
      );

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: fontRegular, bold: fontBold),
          header: (pw.Context context) => pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(bottom: 10),
            child: pw.Text('ScaleBook - Historia Budowy', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ),
          build: (pw.Context context) => [
            // Project Header
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (mainImage != null)
                  pw.Container(
                    width: 150,
                    height: 100,
                    child: pw.Image(mainImage, fit: pw.BoxFit.cover),
                  ),
                pw.SizedBox(width: 20),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(project.title.toUpperCase(), style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Skala: ${project.scale}', style: const pw.TextStyle(fontSize: 16)),
                      pw.Text('Status: ${project.status}', style: const pw.TextStyle(fontSize: 14, color: PdfColors.red)),
                    ],
                  ),
                ),
              ],
            ),
            pw.Divider(thickness: 2, height: 30),

            // Steps
            ...List.generate(project.steps.length, (index) {
              final step = project.steps[index];
              final stepImage = stepImages[index];

              return pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(dateFormat.format(step.date), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey700)),
                        pw.Text('ETAP ${project.steps.length - index}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
                      ],
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        if (stepImage != null)
                          pw.Container(
                            width: 100,
                            height: 70,
                            margin: const pw.EdgeInsets.only(right: 15),
                            child: pw.Image(stepImage, fit: pw.BoxFit.cover),
                          ),
                        pw.Expanded(
                          child: pw.Text(step.note, style: const pw.TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                  ],
                ),
              );
            }),
          ],
        ),
      );

      return await pdf.save();
    } catch (e) {
      debugPrint('BŁĄD PDF: $e');
      rethrow;
    }
  }

  static Future<Uint8List> generateStashPdf({
    required String modelerName,
    required List<ModelProject> models,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd.MM.yyyy');
      
      // Load font for Polish characters with timeout
      pw.Font? fontRegular;
      pw.Font? fontBold;
      pw.Font? fontItalic;

      try {
        debugPrint('Pobieranie czcionek...');
        fontRegular = await PdfGoogleFonts.robotoRegular().timeout(const Duration(seconds: 10));
        fontBold = await PdfGoogleFonts.robotoBold().timeout(const Duration(seconds: 10));
        fontItalic = await PdfGoogleFonts.robotoItalic().timeout(const Duration(seconds: 10));
      } catch (e) {
        debugPrint('Błąd czcionek: $e');
      }

      // Create pages with 5 models per page
      for (var i = 0; i < models.length; i += 5) {
        final pageModels = models.skip(i).take(5).toList();
        
        debugPrint('PDF: Generowanie strony ${(i / 5 + 1).toInt()} dla ${pageModels.length} modeli');
        for (var m in pageModels) {
          debugPrint('PDF: Model: ${m.title}, Zdjęcie: ${m.mainImageUrl ?? 'BRAK'}');
        }

        // Download/Load images for the current page in parallel
        final modelImages = await Future.wait(
          pageModels.map((model) => _loadPdfImage(model.mainImageUrl)),
        );

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            theme: pw.ThemeData.withFont(
              base: fontRegular,
              bold: fontBold,
              italic: fontItalic,
            ),
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'KATALOG MODELI - GARDEROBA',
                        style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        'Modelarz: $modelerName',
                        style: pw.TextStyle(fontSize: 14, fontStyle: pw.FontStyle.italic),
                      ),
                    ],
                  ),
                  pw.Divider(thickness: 2),
                  pw.SizedBox(height: 20),

                  // Model List
                  ...List.generate(pageModels.length, (index) {
                    final model = pageModels[index];
                    final image = modelImages[index];

                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 20),
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                      ),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // Model Photo
                          pw.Container(
                            width: 120,
                            height: 80,
                            child: image != null
                                ? pw.Image(image, fit: pw.BoxFit.cover)
                                : pw.Center(child: pw.Text('Brak zdjęcia')),
                          ),
                          pw.SizedBox(width: 20),
                          // Model Details
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  model.title.toUpperCase(),
                                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text('Skala: ${model.scale}'),
                                pw.Text('Data zakupu: ${dateFormat.format(model.createdAt)}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  // Footer
                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Wygenerowano z aplikacji ScaleBook', style: const pw.TextStyle(fontSize: 10)),
                      pw.Text('Strona ${(i / 5 + 1).toInt()}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      }

      debugPrint('Zapisywanie dokumentu PDF...');
      return await pdf.save();
    } catch (e) {
      debugPrint('BŁĄD KRYTYCZNY GENEROWANIA: $e');
      rethrow;
    }
  }

  static Future<pw.MemoryImage?> _loadPdfImage(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      if (path.startsWith('http')) {
        debugPrint('PDF: Pobieranie zdjęcia: $path');
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(path)).timeout(const Duration(seconds: 10));
        final response = await request.close().timeout(const Duration(seconds: 10));
        
        if (response.statusCode == 200) {
          final bytes = await consolidateHttpClientResponseBytes(response);
          debugPrint('PDF: Pobrano zdjęcie (${bytes.length} bajtów)');
          return pw.MemoryImage(bytes);
        } else {
          debugPrint('PDF: Błąd serwera zdjęć: ${response.statusCode}');
        }
      } else {
        // Handle local files (relative or absolute)
        String fullPath = path;
        if (!path.startsWith('/')) {
          final docsDir = await getApplicationDocumentsDirectory();
          fullPath = p.join(docsDir.path, path);
        }

        final file = File(fullPath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          debugPrint('PDF: Wczytano zdjęcie lokalne: $fullPath (${bytes.length} bajtów)');
          return pw.MemoryImage(bytes);
        } else {
          debugPrint('PDF: Plik nie istnieje: $fullPath');
        }
      }
    } catch (e) {
      debugPrint('PDF: Błąd krytyczny ładowania zdjęcia ($path): $e');
    }
    return null;
  }
}
