import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: const Text('Ajustes')), body: ListView(children:[
      ListTile(title: const Text('Probar notificación'), subtitle: const Text('Dispara check 3 días'), onTap: ()async{ await NotificationService.checkAndNotify(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Notificación enviada')));} ),
      const Divider(),
      ListTile(title: const Text('Exportar Backup JSON'), subtitle: const Text('Guarda en Descargas'), onTap: ()async{ final p=await BackupService.exportJson(); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Backup: $p')));} ),
      ListTile(title: const Text('Importar Backup JSON'), onTap: ()async{ final r=await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions:['json']); if(r!=null){ await BackupService.importJson(r.files.single.path!); if(context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Importado')));} }),
      const Divider(),
      ListTile(title: const Text('Exportar Deudores CSV'), onTap: ()async=>await BackupService.exportDeudoresCsv()),
      ListTile(title: const Text('Exportar Deudores PDF'), onTap: ()async=>await BackupService.exportDeudoresPdf()),
    ]));
  }
}
