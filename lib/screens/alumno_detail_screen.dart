import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/alumno.dart';
import '../providers/alumno_provider.dart';
import '../services/pago_service.dart';
import 'alumno_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/notification_service.dart';

class AlumnoDetailScreen extends StatefulWidget {
  final Alumno alumno;
  const AlumnoDetailScreen({super.key, required this.alumno});
  @override
  State<AlumnoDetailScreen> createState() => _AlumnoDetailState();
}

class _AlumnoDetailState extends State<AlumnoDetailScreen> {
  Future<void> _confirmEliminarPago(
    BuildContext context,
    int pagoId,
    double monto,
    DateTime fecha,
  ) async {
    final c = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar pago'),
            content: Text(
              '¿Eliminar el pago de \$$monto del ${DateFormat('dd/MM/yyyy', 'es').format(fecha)}?\n\n¿Estás seguro?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
    if (c != true || !mounted) return;
    await PagoService.eliminarPago(pagoId, widget.alumno.id!);
    await context.read<AlumnoProvider>().load();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Pago eliminado')));
    }
  }

  Future<void> _abrirWhatsApp(String telefono, String mensaje) async {
    final wa = telefono.replaceAll(RegExp(r'[^0-9]'), '');
    await launchUrl(
      Uri.parse('https://wa.me/$wa?text=${Uri.encodeComponent(mensaje)}'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _opcionesWhatsApp(BuildContext context, Alumno a) async {
    final vencido = a.estado == 'vencido';
    final fecha = DateFormat('dd/MM/yyyy', 'es').format(a.fechaVencimiento);
    final pago = NotificationService.buildWhatsAppMessage(
      a.nombre,
      fecha,
      a.monto.toString(),
      vencido,
    );
    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.payments),
                  title: const Text('Recordatorio de pago'),
                  subtitle: Text(
                    vencido ? 'Cuota vencida el $fecha' : 'Vence el $fecha',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _abrirWhatsApp(a.telefono, pago);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.group_add),
                  title: const Text('Bienvenida + grupo'),
                  subtitle: const Text('Familia Central Boxing Tehuacán'),
                  onTap: () {
                    Navigator.pop(context);
                    _abrirWhatsApp(
                      a.telefono,
                      NotificationService.buildWelcomeMessage(a.nombre),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.alumno;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            title: Text(a.nombre),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Color(0xFFD32F2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullScreenFoto(
                                        path: a.fotoPath,
                                        nombre: a.nombre,
                                      ),
                                ),
                              ),
                          child: Hero(
                            tag: 'alumno${a.id}',
                            child: CircleAvatar(
                              radius: 42,
                              backgroundImage:
                                  a.fotoPath != null
                                      ? FileImage(File(a.fotoPath!))
                                      : null,
                              child:
                                  a.fotoPath == null
                                      ? const Icon(Icons.person, size: 42)
                                      : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a.nombre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          label: Text(
                            a.estado,
                            style: const TextStyle(fontSize: 12),
                          ),
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              a.estado == 'vencido'
                                  ? Colors.red
                                  : a.estado == 'por_vencer'
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlumnoFormScreen(alumno: a),
                      ),
                    ).then((_) => setState(() {})),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final c = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('Eliminar'),
                          content: const Text('¿Eliminar alumno?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                  );
                  if (c == true) {
                    await context.read<AlumnoProvider>().remove(a.id!);
                    if (mounted) Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.phone),
                            title: Text(a.telefono),
                          ),
                          ListTile(
                            leading: const Icon(Icons.event),
                            title: Text(
                              'Inscripción: ${DateFormat('dd/MM/yyyy', 'es').format(a.fechaInscripcion)}',
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              'Vencimiento: ${DateFormat('dd/MM/yyyy', 'es').format(a.fechaVencimiento)}',
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.cake),
                            title: Text(
                              '${a.fechaNacimiento != null ? DateFormat('dd/MM/yyyy', 'es').format(DateTime.parse(a.fechaNacimiento!)) : 'Sin fecha'} (${a.edadTexto})',
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.payments),
                            title: Text('Monto: \$${a.monto}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Marcar Pagado'),
                          onPressed: () async {
                            await PagoService.registrarPago(a.id!, a.monto);
                            await context.read<AlumnoProvider>().load();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pago registrado'),
                                ),
                              );
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.message),
                          label: const Text('WhatsApp'),
                          onPressed: () => _opcionesWhatsApp(context, a),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text(
                    'Historial de Pagos',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  FutureBuilder(
                    future: PagoService.historial(a.id!),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final list = snap.data!;
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(8),
                          child: Text('Sin pagos'),
                        );
                      }
                      return Column(
                        children:
                            list
                                .map(
                                  (p) => ListTile(
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    title: Text(
                                      '\$${p.monto} - ${p.mesCubierto}',
                                    ),
                                    subtitle: Text(
                                      '${DateFormat('dd/MM/yyyy', 'es').format(p.fechaPago)} ${p.metodo ?? ''}',
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Eliminar pago',
                                      onPressed:
                                          () => _confirmEliminarPago(
                                            context,
                                            p.id!,
                                            p.monto,
                                            p.fechaPago,
                                          ),
                                    ),
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenFoto extends StatelessWidget {
  final String? path;
  final String nombre;
  const FullScreenFoto({super.key, this.path, required this.nombre});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(nombre)),
      body: Center(
        child: InteractiveViewer(
          child:
              path != null
                  ? Image.file(
                    File(path!),
                    errorBuilder:
                        (_, __, ___) => Image.asset('assets/logo.png'),
                  )
                  : Image.asset('assets/logo.png'),
        ),
      ),
    );
  }
}
