import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import '../db/database_helper.dart';

class BackupService {
  static Future<String> exportJson() async {
    final db = await DatabaseHelper.instance.db;
    final alumnos = await db.query('alumnos');
    final pagos = await db.query('pagos');
    final data = jsonEncode({'alumnos': alumnos, 'pagos': pagos});
    final dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/central_boxing_backup_${DateTime.now().toIso8601String().split('T').first}.json');
    await file.writeAsString(data);
    return file.path;
  }
  static Future<void> importJson(String path) async {
    final content = await File(path).readAsString();
    final data = jsonDecode(content);
    final db = await DatabaseHelper.instance.db;
    await db.delete('pagos'); await db.delete('alumnos');
    for(final a in data['alumnos']) await db.insert('alumnos', Map<String,dynamic>.from(a));
    for(final p in data['pagos']) await db.insert('pagos', Map<String,dynamic>.from(p));
  }
  static Future<String> exportDeudoresCsv() async {
    final db = await DatabaseHelper.instance.db;
    final rows = await db.rawQuery("SELECT * FROM alumnos WHERE activo=1");
    final deudores = rows.where((a){
      final v=DateTime.parse(a['fecha_vencimiento'] as String); final hoy=DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
      return v.difference(hoy).inDays <=3;
    }).toList();
    final csv = const ListToCsvConverter().convert([['Nombre','Telefono','Vencimiento','Monto'], ...deudores.map((a)=>[a['nombre'],a['telefono'],a['fecha_vencimiento'],a['monto']])]);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/deudores.csv'); await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text:'Deudores Central Boxing');
    return file.path;
  }
  static Future<String> exportDeudoresPdf() async {
    final db = await DatabaseHelper.instance.db;
    final rows = await db.query('alumnos', where:'activo=1');
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (c)=>pw.Column(children:[pw.Text('Deudores Central Boxing'), pw.TableHelper.fromTextArray(headers:['Nombre','Tel','Vencimiento','Monto'], data: rows.map((a)=>[a['nombre'].toString(),a['telefono'].toString(),(a['fecha_vencimiento'] as String).split('T').first, a['monto'].toString()]).toList())])));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/deudores.pdf'); await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)]);
    return file.path;
  }
}
