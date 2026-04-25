import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode/barcode.dart';
import 'package:intl/intl.dart';
import 'package:unifytechxenosadmin/domain/models/product.dart';

class LabelService {
  static final _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  /// Gera e abre o diálogo de impressão para etiquetas de um produto
  static Future<void> printProductLabels({
    required Produto product,
    required int quantity,
    double widthMm = 40,
    double heightMm = 25,
  }) async {
    final pdf = pw.Document();
    
    // Carrega uma fonte com suporte a Unicode (acentos, R$, etc)
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    // Adiciona uma página para cada etiqueta
    for (var i = 0; i < quantity; i++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            widthMm * PdfPageFormat.mm,
            heightMm * PdfPageFormat.mm,
            marginAll: 2 * PdfPageFormat.mm,
          ),
          theme: pw.ThemeData.withFont(
            base: font,
            bold: fontBold,
          ),
          build: (pw.Context context) {
            return pw.Container(
              width: widthMm * PdfPageFormat.mm,
              height: heightMm * PdfPageFormat.mm,
              child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  // Nome do Produto
                  pw.Text(
                    product.nome.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 7,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    textAlign: pw.TextAlign.center,
                    maxLines: 2,
                  ),
                  pw.SizedBox(height: 2),
                  
                  // Código de Barras
                  pw.Expanded(
                    child: pw.Center(
                      child: pw.BarcodeWidget(
                        barcode: Barcode.code128(),
                        data: product.codigoBarras ?? product.idProduto.toString(),
                        drawText: false,
                      ),
                    ),
                  ),
                  
                  pw.SizedBox(height: 2),
                  
                  // Preço
                  pw.Text(
                    _currencyFormat.format(product.precoVenda),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Etiquetas - ${product.nome}',
    );
  }

}
