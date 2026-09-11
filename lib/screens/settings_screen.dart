import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          Consumer<ThemeProvider>(builder: (_, th, __) => SwitchListTile(title: const Text('Modo oscuro'), value: th.mode==ThemeMode.dark, onChanged: (v)=>th.toggle(v))),
          ListTile(
            title: const Text('Probar notificación'),
            subtitle: const Text('Dispara check 3 días'),
            onTap: () async {
              await NotificationService.checkAndNotify();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificación enviada')),
                );
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Exportar Backup JSON'),
            subtitle: const Text('Guarda en Descargas'),
            onTap: () async {
              final p = await BackupService.exportJson();
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Backup: $p')));
              }
            },
          ),
          ListTile(
            title: const Text('Importar Backup JSON'),
            onTap: () async {
              final r = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['json'],
              );
              if (r != null) {
                await BackupService.importJson(r.files.single.path!);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('Importado')));
                }
              }
            },
          ),
          const Divider(),
          const ListTile(
            title: Text('Exportar CSV'),
            subtitle: Text('Elige filtro'),
          ),
          ListTile(
            title: const Text('CSV Todos'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresCsv(filtro: 'todos'),
          ),
          ListTile(
            title: const Text('CSV Por vencer (≤3 días)'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresCsv(filtro: 'por_vencer'),
          ),
          ListTile(
            title: const Text('CSV Vencidos'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresCsv(filtro: 'vencido'),
          ),
          const Divider(),
          const ListTile(title: Text('Exportar PDF')),
          ListTile(
            title: const Text('PDF Todos'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresPdf(filtro: 'todos'),
          ),
          ListTile(
            title: const Text('PDF Por vencer'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresPdf(filtro: 'por_vencer'),
          ),
          ListTile(
            title: const Text('PDF Vencidos'),
            onTap:
                () async =>
                    await BackupService.exportDeudoresPdf(filtro: 'vencido'),
          ),
        ],
      ),
    );
  }
}
