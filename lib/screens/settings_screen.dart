import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/backup_service.dart';
import '../services/notification_service.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _S();
}

class _S extends State<SettingsScreen> {
  String filtro = 'todos';
  bool bioAvailable = false, bioEnabled = false;
  @override
  void initState() {
    super.initState();
    _loadBio();
  }

  Future<void> _loadBio() async {
    final auth = AuthService();
    bioAvailable = await auth.canUseBiometrics();
    bioEnabled = await auth.isBiometricEnabled();
    if (mounted) setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AJUSTES'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    leading: Icon(Icons.palette, color: Color(0xFFD32F2F)),
                    title: Text(
                      'APARIENCIA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    dense: true,
                  ),
                  Consumer<ThemeProvider>(
                    builder:
                        (_, th, __) => SwitchListTile(
                          secondary: const Icon(Icons.dark_mode),
                          title: const Text('Modo oscuro'),
                          subtitle: const Text('Manual en ajustes'),
                          value: th.mode == ThemeMode.dark,
                          onChanged: (v) => th.toggle(v),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    leading: Icon(Icons.lock, color: Color(0xFFD32F2F)),
                    title: Text(
                      'SEGURIDAD',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    dense: true,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: const Text('Desbloqueo con huella'),
                    subtitle: Text(
                      bioAvailable
                          ? 'PIN sigue disponible como respaldo'
                          : 'No disponible en este dispositivo',
                    ),
                    value: bioEnabled && bioAvailable,
                    onChanged:
                        !bioAvailable
                            ? null
                            : (v) async {
                              if (v) {
                                final ok =
                                    await AuthService().authenticate();
                                if (!ok) return;
                              }
                              await AuthService().setBiometricEnabled(v);
                              setState(() => bioEnabled = v);
                            },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: Color(0xFFD32F2F),
                    ),
                    title: Text(
                      'NOTIFICACIONES',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    dense: true,
                  ),
                  ListTile(
                    leading: const Icon(Icons.send),
                    title: const Text('Probar notificación'),
                    subtitle: const Text('Dispara check 3 días'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await NotificationService.checkAndNotify();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notificación enviada')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ListTile(
                    leading: Icon(Icons.storage, color: Color(0xFFD32F2F)),
                    title: Text(
                      'DATOS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    dense: true,
                  ),
                  const Divider(),
                  const Text(
                    '  RESPALDO',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.save),
                    title: const Text('Exportar Backup JSON'),
                    subtitle: const Text('Guarda en Descargas'),
                    trailing: const Icon(Icons.chevron_right),
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
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Importar Backup JSON'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final r = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                      );
                      if (r != null) {
                        await BackupService.importJson(r.files.single.path!);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Importado')),
                          );
                        }
                      }
                    },
                  ),
                  const Divider(),
                  const Text(
                    '  EXPORTAR DEUDORES',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'todos', label: Text('Todos')),
                        ButtonSegment(
                          value: 'por_vencer',
                          label: Text('Por vencer'),
                        ),
                        ButtonSegment(
                          value: 'vencido',
                          label: Text('Vencidos'),
                        ),
                      ],
                      selected: {filtro},
                      onSelectionChanged:
                          (s) => setState(() => filtro = s.first),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.table_chart),
                            label: const Text('CSV'),
                            onPressed:
                                () => BackupService.exportDeudoresCsv(
                                  filtro: filtro,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.tonalIcon(
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                            onPressed:
                                () => BackupService.exportDeudoresPdf(
                                  filtro: filtro,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Central Boxing v1.0.0',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
          // La ultima tarjeta nunca queda bajo la barra del sistema:
          // con botones reserva su altura, con gestos solo 12.
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }
}
