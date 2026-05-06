import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

Future<void> createPdf(List<Map<String, dynamic>> schedule) async {
  final pdf = pw.Document();

  pw.Widget buildBadge(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: color,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Text(
        text.toUpperCase(),
        style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
      ),
    );
  }

  Duration getStudyDuration(String difficulty) {
    switch (difficulty.toLowerCase().trim()) {
      case 'hard':
        return const Duration(minutes: 70);
      case 'medium':
        return const Duration(minutes: 45);
      case 'easy':
      default:
        return const Duration(minutes: 25);
    }
  }

  String explainTask(Map<String, dynamic> task) {
    final priority = (task['priority'] ?? 'low').toString().toLowerCase();
    final difficulty = (task['difficulty'] ?? 'easy').toString().toLowerCase();

    final deadline = task['deadline'];

    if (deadline == null || deadline is! DateTime) {
      return "Scheduled based on difficulty (${difficulty}) and priority.";
    }

    final hoursLeft = deadline.difference(DateTime.now()).inHours;

    if (hoursLeft <= 0) {
      return "⚠ Overdue → immediate scheduling";
    }

    if (hoursLeft < 6) {
      return "🚨 Urgent deadline → prioritized first";
    }

    if (priority == 'high') {
      return "🔥 High priority → moved earlier in schedule";
    }

    if (difficulty == 'hard') {
      return "🧠 Hard task → longer focus block assigned";
    }

    return "📊 Balanced scheduling strategy applied";
  }

  // ---------------------------
  // PDF PAGE
  // ---------------------------
  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        // TITLE
        pw.Center(
          child: pw.Text(
            "Smart Study Schedule",
            style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.SizedBox(height: 8),

        pw.Center(
          child: pw.Text(
            "Generated on ${DateTime.now().toString().split('.')[0]}",
            style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
          ),
        ),

        pw.SizedBox(height: 20),

        // TASKS
        ...schedule.map((task) {
          final title = (task['title'] ?? "Untitled Task").toString();

          final priority = (task['priority'] ?? "low")
              .toString()
              .toLowerCase()
              .trim();

          final difficulty = (task['difficulty'] ?? "easy")
              .toString()
              .toLowerCase()
              .trim();

          final start = task['start'] as DateTime?;
          final end = task['end'] as DateTime?;

          final duration = getStudyDuration(difficulty);

          final timeText = (start != null && end != null)
              ? "${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - "
                    "${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}"
              : "No time assigned";

          PdfColor priorityColor = PdfColors.green;

          if (priority == 'medium') priorityColor = PdfColors.orange;
          if (priority == 'high') priorityColor = PdfColors.red;

          final score = task['score'] ?? 0;

          return pw.Container(
            margin: const pw.EdgeInsets.only(bottom: 12),
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // TITLE + TIME
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        title,
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Text(timeText, style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),

                pw.SizedBox(height: 8),

                // BADGES
                pw.Row(
                  children: [
                    buildBadge(priority, priorityColor),
                    pw.SizedBox(width: 6),
                    buildBadge(difficulty, PdfColors.blue),
                  ],
                ),

                pw.SizedBox(height: 6),

                // 🔥 STUDY DURATION (NOW ACTUALLY USED)
                pw.Text(
                  "Study duration: ${duration.inMinutes} minutes",
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.blueGrey,
                  ),
                ),

                pw.SizedBox(height: 6),

                // EXPLANATION
                pw.Text(
                  explainTask(task),
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  "Study duration: ${duration.inMinutes} minutes",
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.blueGrey,
                  ),
                ),

                pw.SizedBox(height: 6),

                pw.Text(
                  "Study duration: ${duration.inMinutes} minutes",
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.blueGrey,
                  ),
                ),

                pw.SizedBox(height: 4),

                pw.Text(
                  "Urgency Score: ${score.toStringAsFixed(1)}",
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.red),
                ),

                pw.SizedBox(height: 6),
              ],
            ),
          );
        }).toList(),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'smart_schedule.pdf',
  );
}
