import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../core/fecha_mask_formatter.dart';
import '../models/alumno.dart';
import '../providers/alumno_provider.dart';
import '../services/pago_service.dart';
import 'package:intl/intl.dart';

class AlumnoFormScreen extends StatefulWidget {
  final Alumno? alumno;
  const AlumnoFormScreen({super.key, this.alumno});
  @override
  State<AlumnoFormScreen> createState() => _AlumnoFormState();
}

class _AlumnoFormState extends State<AlumnoFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController nombre, telefono, monto;
  late TextEditingController fechaNacCtrl, fechaInscCtrl;
  DateTime fechaInscripcion = DateTime.now();
  DateTime? fechaNac;
  String? fotoPath;

  static String _fmt(DateTime d) => DateFormat('dd/MM/yyyy', 'es').format(d);

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
      fechaInscripcion = a.fechaInscripcion;
      fechaNac =
          a.fechaNacimiento != null ? DateTime.parse(a.fechaNacimiento!) : null;
      fotoPath = a.fotoPath;
    }
    fechaInscCtrl = TextEditingController(text: _fmt(fechaInscripcion));
    fechaNacCtrl = TextEditingController(
      text: fechaNac == null ? '' : _fmt(fechaNac!),
    );
    fechaInscCtrl.addListener(_syncInscFromText);
    fechaNacCtrl.addListener(_syncNacFromText);
  }

  @override
  void dispose() {
    nombre.dispose();
    telefono.dispose();
    monto.dispose();
    fechaNacCtrl.dispose();
    fechaInscCtrl.dispose();
    super.dispose();
  }

  void _syncInscFromText() {
    final d = parseFecha(fechaInscCtrl.text);
    if (d != null && d != fechaInscripcion) {
      setState(() => fechaInscripcion = d);
    }
  }

  void _syncNacFromText() {
    final t = fechaNacCtrl.text.trim();
    final d = t.isEmpty ? null : parseFecha(t);
    if (d != fechaNac) {
      setState(() => fechaNac = d);
    }
  }

  void _syncFechasFromText() {
    final insc = parseFecha(fechaInscCtrl.text);
    if (insc != null) fechaInscripcion = insc;
    final t = fechaNacCtrl.text.trim();
    fechaNac = t.isEmpty ? null : parseFecha(t);
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

  DateTime get vencimientoCalculado =>
      PagoService.siguienteVencimiento(fechaInscripcion);
  Future<void> _pickFoto() async {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFD32F2F),
                  ),
                  title: const Text('Tomar foto'),
                  onTap: () async {
                    Navigator.pop(context);
                    final f = await ImagePicker().pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                    if (f != null) setState(() => fotoPath = f.path);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo),
                  title: const Text('Elegir de galería'),
                  onTap: () async {
                    Navigator.pop(context);
                    final f = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (f != null) setState(() => fotoPath = f.path);
                  },
                ),
                if (fotoPath != null)
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Eliminar foto'),
                    onTap: () => setState(() => fotoPath = null),
                  ),
              ],
            ),
          ),
    );
  }

  Future<String?> _guardarFoto() async {
    if (fotoPath == null) return widget.alumno?.fotoPath;
    if (fotoPath == widget.alumno?.fotoPath) return fotoPath;
    final dir = await getApplicationDocumentsDirectory();
    final dest =
        '${dir.path}/alumno_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(fotoPath!).copy(dest);
    return dest;
  }

  Future<void> _save() async {
    _syncFechasFromText();
    if (!_form.currentState!.validate()) return;
    final tel = '+52${telefono.text.replaceAll(RegExp(r'[^0-9]'), '')}';
    final savedFoto = await _guardarFoto();
    final al = Alumno(
      id: widget.alumno?.id,
      nombre: nombre.text,
      telefono: tel,
      fechaInscripcion: fechaInscripcion,
      fechaVencimiento: vencimientoCalculado,
      monto: double.parse(monto.text),
      fechaNacimiento: fechaNac?.toIso8601String(),
      fotoPath: savedFoto,
    );
    final prov = context.read<AlumnoProvider>();
    if (widget.alumno == null) {
      await prov.add(al);
    } else {
      await prov.update(al);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickInscripcion() async {
    final d = await showDatePicker(
      context: context,
      locale: const Locale('es', 'MX'),
      helpText: 'SELECCIONA FECHA',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
      fieldLabelText: 'Día/Mes/Año',
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: fechaInscripcion,
    );
    if (d != null) {
      fechaInscCtrl.text = _fmt(d);
      setState(() => fechaInscripcion = d);
    }
  }

  Future<void> _pickNacimiento() async {
    final d = await showDatePicker(
      context: context,
      locale: const Locale('es', 'MX'),
      helpText: 'SELECCIONA FECHA',
      cancelText: 'CANCELAR',
      confirmText: 'ACEPTAR',
      fieldLabelText: 'Día/Mes/Año',
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      initialDate: fechaNac ?? DateTime(2000, 1, 1),
    );
    if (d != null) {
      fechaNacCtrl.text = _fmt(d);
      setState(() => fechaNac = d);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.alumno == null
              ? 'NUEVO ALUMNO'
              : 'EDITAR: ${widget.alumno!.nombre.toUpperCase()}',
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        fotoPath != null ? FileImage(File(fotoPath!)) : null,
                    child:
                        fotoPath == null
                            ? const Icon(Icons.person, size: 40)
                            : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      onPressed: _pickFoto,
                      child: const Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      leading: Icon(Icons.person, color: Color(0xFFD32F2F)),
                      title: Text(
                        'DATOS PERSONALES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    TextFormField(
                      controller: nombre,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                      ),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: telefono,
                      decoration: const InputDecoration(
                        labelText: 'Tel/WhatsApp',
                        prefixText: '+52 ',
                        helperText: '10 dígitos ej: 55 1234 5678',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
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
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fechaNacCtrl,
                      decoration: InputDecoration(
                        labelText: 'Fecha de nacimiento (opcional)',
                        hintText: 'dd/mm/aaaa',
                        prefixIcon: const Icon(Icons.cake),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (fechaNacCtrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Limpiar',
                                onPressed:
                                    () => setState(
                                      () => fechaNacCtrl.clear(),
                                    ),
                              ),
                            IconButton(
                              icon: const Icon(Icons.calendar_month),
                              tooltip: 'Elegir del calendario',
                              onPressed: _pickNacimiento,
                            ),
                          ],
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FechaMaskFormatter(),
                      ],
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return null;
                        final d = parseFecha(t);
                        if (d == null) {
                          return 'Fecha inválida (dd/mm/aaaa)';
                        }
                        if (d.isBefore(DateTime(1940)) ||
                            d.isAfter(DateTime.now())) {
                          return 'Fuera de rango';
                        }
                        return null;
                      },
                    ),
                    if (fechaNac != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text('$edadPrev años'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(
                      leading: Icon(
                        Icons.card_membership,
                        color: Color(0xFFD32F2F),
                      ),
                      title: Text(
                        'MEMBRESÍA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    TextFormField(
                      controller: monto,
                      decoration: const InputDecoration(
                        labelText: 'Monto',
                        prefixText: '\$ ',
                        helperText: 'Mensual fijo',
                        prefixIcon: Icon(Icons.payments),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: fechaInscCtrl,
                      decoration: InputDecoration(
                        labelText: 'Fecha de inscripción',
                        hintText: 'dd/mm/aaaa',
                        helperText: 'Hoy, modificable',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          tooltip: 'Elegir del calendario',
                          onPressed: _pickInscripcion,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                      ),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FechaMaskFormatter(),
                      ],
                      validator: (v) {
                        final d = parseFecha(v ?? '');
                        if (d == null) {
                          return 'Fecha inválida (dd/mm/aaaa)';
                        }
                        if (d.isBefore(DateTime(2020)) ||
                            d.isAfter(
                              DateTime.now().add(const Duration(days: 365)),
                            )) {
                          return 'Fuera de rango';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de vencimiento',
                        suffixIcon: Icon(Icons.lock, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        filled: true,
                        enabled: false,
                      ),
                      child: Text(
                        DateFormat(
                          'dd/MM/yyyy',
                          'es',
                        ).format(vencimientoCalculado),
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR'),
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
