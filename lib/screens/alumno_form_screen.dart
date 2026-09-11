import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/alumno.dart';
import '../providers/alumno_provider.dart';
import '../services/pago_service.dart';
import 'package:intl/intl.dart';

class AlumnoFormScreen extends StatefulWidget {
  final Alumno? alumno;
  const AlumnoFormScreen({super.key, this.alumno});
  @override
  State<AlumnoFormScreen> createState() => _S();
}

class _S extends State<AlumnoFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController nombre, telefono, monto;
  DateTime vencimiento = PagoService.siguienteVencimiento(DateTime.now());
  DateTime? fechaNac;
  @override
  void initState() {
    super.initState();
    final a = widget.alumno;
    nombre = TextEditingController(text: a?.nombre ?? '');
    telefono = TextEditingController(
      text: a?.telefono.replaceAll(RegExp(r'^\+52'), '') ?? '',
    );
    monto = TextEditingController(text: a?.monto.toString() ?? '');
    if (a != null) {
      vencimiento = a.fechaVencimiento;
      fechaNac =
          a.fechaNacimiento != null ? DateTime.parse(a.fechaNacimiento!) : null;
    }
  }

  int get edadPrev {
    if (fechaNac == null) return 0;
    final hoy = DateTime.now();
    int e = hoy.year - fechaNac!.year;
    if (hoy.month < fechaNac!.month ||
        (hoy.month == fechaNac!.month && hoy.day < fechaNac!.day)) {
      e--;
    }
    return e;
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final prov = context.read<AlumnoProvider>();
    final tel = '+52${telefono.text.replaceAll(RegExp(r'[^0-9]'), '')}';
    final al = Alumno(
      id: widget.alumno?.id,
      nombre: nombre.text,
      telefono: tel,
      fechaInscripcion: widget.alumno?.fechaInscripcion ?? DateTime.now(),
      fechaVencimiento: vencimiento,
      monto: double.parse(monto.text),
      fechaNacimiento: fechaNac?.toIso8601String(),
    );
    if (widget.alumno == null) {
      await prov.add(al);
    } else {
      await prov.update(al);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alumno == null ? 'Nuevo Alumno' : 'Editar'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: nombre,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            TextFormField(
              controller: telefono,
              decoration: const InputDecoration(
                labelText: 'Tel/WhatsApp',
                prefixText: '+52 ',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                final d = v?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                if (d.isEmpty) return 'Requerido';
                if (d.length != 10) return 'Debe tener 10 dígitos';
                return null;
              },
            ),
            TextFormField(
              controller: monto,
              decoration: const InputDecoration(labelText: 'Monto'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(
                'Vencimiento: ${DateFormat('dd/MM/yyyy').format(vencimiento)}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                  initialDate: vencimiento,
                );
                if (d != null) setState(() => vencimiento = d);
              },
            ),
            ListTile(
              title: Text(
                fechaNac == null
                    ? 'Fecha nacimiento (opcional)'
                    : 'Nacimiento: ${DateFormat('dd/MM/yyyy').format(fechaNac!)} ${edadPrev > 0 ? "($edadPrev años)" : ""}',
              ),
              trailing: const Icon(Icons.cake),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                  initialDate: fechaNac ?? DateTime(2000),
                );
                if (d != null) setState(() => fechaNac = d);
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _save, child: const Text('Guardar')),
          ],
        ),
      ),
    );
  }
}
