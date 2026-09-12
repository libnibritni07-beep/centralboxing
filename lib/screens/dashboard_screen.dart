import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alumno_provider.dart';
import '../widgets/alumno_card.dart';
import '../widgets/stats_card.dart';
import 'alumno_form_screen.dart';
import 'alumno_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _S();
}

class _S extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<AlumnoProvider>().load(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AlumnoProvider>();
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 80,
            centerTitle: true,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 28,
                  errorBuilder:
                      (_, __, ___) => const Icon(
                        Icons.sports_mma,
                        size: 22,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'CENTRAL BOXING',
                  style: TextStyle(
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFFD32F2F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const FlexibleSpaceBar(background: SizedBox.shrink()),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  StatsCard(
                    title: 'Al día',
                    count: p.countAlDia,
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  const SizedBox(width: 8),
                  StatsCard(
                    title: 'Por vencer',
                    count: p.countPorVencer,
                    color: Colors.orange,
                    icon: Icons.warning,
                  ),
                  const SizedBox(width: 8),
                  StatsCard(
                    title: 'Vencidos',
                    count: p.countVencido,
                    color: Colors.red,
                    icon: Icons.error,
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  filled: true,
                ),
                onChanged: (v) {
                  p.query = v;
                  p.load();
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children:
                    ['todos', 'al_dia', 'por_vencer', 'vencido']
                        .map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: FilterChip(
                              label: Text(
                                f.replaceAll('_', ' '),
                                style: const TextStyle(fontSize: 12),
                              ),
                              selected: p.filtro == f,
                              onSelected: (_) {
                                p.filtro = f;
                                p.load();
                              },
                              selectedColor: const Color(
                                0xFFD32F2F,
                              ).withValues(alpha: 0.2),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
          SliverList.builder(
            itemCount: p.alumnos.length,
            itemBuilder: (_, i) {
              final a = p.alumnos[i];
              return Dismissible(
                key: ValueKey(a.id),
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 16),
                  child: const Icon(Icons.message, color: Colors.white),
                ),
                direction:
                    a.estado == 'vencido' || a.estado == 'por_vencer'
                        ? DismissDirection.startToEnd
                        : DismissDirection.none,
                confirmDismiss: (_) async {
                  final wa = a.telefono.replaceAll(RegExp(r'[^0-9]'), '');
                  final fecha = DateFormat(
                    'dd/MM/yyyy',
                    'es',
                  ).format(a.fechaVencimiento);
                  final vencido = a.estado == 'vencido';
                  final txt = NotificationService.buildWhatsAppMessage(
                    a.nombre,
                    fecha,
                    a.monto.toString(),
                    vencido,
                  );
                  await launchUrl(
                    Uri.parse(
                      'https://wa.me/$wa?text=${Uri.encodeComponent(txt)}',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                  return false;
                },
                child: AlumnoCard(
                  a: a,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlumnoDetailScreen(alumno: a),
                        ),
                      ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AlumnoFormScreen()),
            ),
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar'),
      ),
    );
  }
}
