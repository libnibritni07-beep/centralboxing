import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/alumno.dart';
class AlumnoCard extends StatelessWidget {
  final Alumno a; final VoidCallback onTap;
  const AlumnoCard({super.key, required this.a, required this.onTap});
  Color get c => a.estado=='vencido'?Colors.red : a.estado=='por_vencer'?Colors.orange : Colors.green;
  @override Widget build(BuildContext context){
    return Card(child: ListTile(leading: CircleAvatar(backgroundColor:c, child: Text(a.nombre[0].toUpperCase(), style: const TextStyle(color: Colors.white))), title: Text(a.nombre), subtitle: Text('Vence ${DateFormat('dd/MM/yyyy').format(a.fechaVencimiento)} • ${a.edadTexto} • \$${a.monto}'), trailing: Container(width:12,height:12,decoration:BoxDecoration(color:c, shape:BoxShape.circle)), onTap:onTap));
  }
}
