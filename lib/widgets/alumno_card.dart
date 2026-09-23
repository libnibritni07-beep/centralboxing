import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alumno.dart';

class AlumnoCard extends StatelessWidget {
  final Alumno a;
  final VoidCallback onTap;
  const AlumnoCard({super.key, required this.a, required this.onTap});
  Color get c =>
      a.estado == 'vencido'
          ? Colors.red
          : a.estado == 'por_vencer'
          ? Colors.orange
          : Colors.green;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c, width: 1),
      ),
      child: ListTile(
        leading: Hero(
          tag: 'alumno${a.id}',
          child: CircleAvatar(
            backgroundColor: c,
            backgroundImage:
                a.fotoPath != null ? FileImage(File(a.fotoPath!)) : null,
            child:
                a.fotoPath == null
                    ? Text(
                      a.nombre[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    )
                    : null,
          ),
        ),
        title: Text(
          a.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Vence ${DateFormat('dd/MM/yyyy').format(a.fechaVencimiento)} • ${a.edadTexto} • \$${a.monto}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            ),
            if (a.estado != 'al_dia')
              const Icon(Icons.message, size: 16, color: Colors.green),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
