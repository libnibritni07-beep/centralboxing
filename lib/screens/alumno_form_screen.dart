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
  @override State<AlumnoFormScreen> createState() => _AlumnoFormState();
}
class _AlumnoFormState extends State<AlumnoFormScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController nombre, telefono, monto;
  DateTime fechaInscripcion = DateTime.now();
  DateTime? fechaNac;
  @override void initState(){
    super.initState();
    final a=widget.alumno;
    nombre=TextEditingController(text:a?.nombre??'');
    telefono=TextEditingController(text:a?.telefono.replaceAll(RegExp(r'^\+52'),'')??'');
    monto=TextEditingController(text:a?.monto.toString()??'');
    if(a!=null){ fechaInscripcion=a.fechaInscripcion; fechaNac=a.fechaNacimiento!=null?DateTime.parse(a.fechaNacimiento!):null; }
  }
  int get edadPrev{
    if(fechaNac==null) return 0;
    final hoy=DateTime.now(); int e=hoy.year-fechaNac!.year; if(hoy.month<fechaNac!.month||(hoy.month==fechaNac!.month&&hoy.day<fechaNac!.day)) e--; return e;
  }
  Future<void> _save() async {
    if(!_form.currentState!.validate()) return;
    final tel='+52${telefono.text.replaceAll(RegExp(r'[^0-9]'), '')}';
    final al=Alumno(id:widget.alumno?.id, nombre:nombre.text, telefono:tel, fechaInscripcion: fechaInscripcion, fechaVencimiento: fechaInscripcion, monto:double.parse(monto.text), fechaNacimiento: fechaNac?.toIso8601String());
    final prov=context.read<AlumnoProvider>();
    if(widget.alumno==null) await prov.add(al); else await prov.update(al);
    if(mounted) Navigator.pop(context);
  }
  Future<void> _pickInscripcion() async {
    final d=await showDatePicker(context:context, locale: const Locale('es','MX'), helpText:'SELECCIONA FECHA', cancelText:'CANCELAR', confirmText:'ACEPTAR', fieldLabelText:'Día/Mes/Año', firstDate:DateTime(2020), lastDate:DateTime.now().add(const Duration(days:365)), initialDate:fechaInscripcion);
    if(d!=null) setState(()=>fechaInscripcion=d);
  }
  Future<void> _pickNacimiento() async {
    final d=await showDatePicker(context:context, locale: const Locale('es','MX'), helpText:'SELECCIONA FECHA', cancelText:'CANCELAR', confirmText:'ACEPTAR', fieldLabelText:'Día/Mes/Año', firstDate:DateTime(1940), lastDate:DateTime.now(), initialDate:fechaNac ?? DateTime(2000,1,1));
    if(d!=null) setState(()=>fechaNac=d);
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text(widget.alumno==null?'NUEVO ALUMNO':'EDITAR ALUMNO'), centerTitle:true), body: Form(key:_form, child: ListView(padding: const EdgeInsets.all(16), children:[
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const ListTile(leading: Icon(Icons.person, color: Color(0xFFD32F2F)), title: Text('DATOS PERSONALES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1)), dense:true, contentPadding: EdgeInsets.zero),
        TextFormField(controller:nombre, decoration: const InputDecoration(labelText:'Nombre', prefixIcon: Icon(Icons.badge), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled:true), validator:(v)=>v!.isEmpty?'Requerido':null),
        const SizedBox(height:12),
        TextFormField(controller:telefono, decoration: const InputDecoration(labelText:'Tel/WhatsApp', prefixText:'+52 ', helperText:'10 dígitos ej: 55 1234 5678', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled:true), keyboardType:TextInputType.phone, maxLength:10, inputFormatters:[FilteringTextInputFormatter.digitsOnly], validator:(v){ final d=v?.replaceAll(RegExp(r'[^0-9]'),'')??''; if(d.isEmpty) return 'Requerido'; if(d.length!=10) return 'Debe tener 10 dígitos'; return null;}),
        const SizedBox(height:12),
        InkWell(onTap:_pickNacimiento, child: InputDecorator(decoration: const InputDecoration(labelText:'Fecha de nacimiento (opcional)', prefixIcon: Icon(Icons.cake), suffixIcon: Icon(Icons.calendar_month), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled:true), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children:[Text(fechaNac==null?'Sin fecha': DateFormat('dd/MM/yyyy','es').format(fechaNac!), style: TextStyle(color: fechaNac==null? Colors.grey[600]: null)), if(fechaNac!=null) Chip(label: Text('$edadPrev años'), visualDensity: VisualDensity.compact)]))),
      ]))),
      const SizedBox(height:12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        const ListTile(leading: Icon(Icons.card_membership, color: Color(0xFFD32F2F)), title: Text('MEMBRESÍA', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing:1)), dense:true, contentPadding: EdgeInsets.zero),
        TextFormField(controller:monto, decoration: const InputDecoration(labelText:'Monto', prefixText:'\$ ', helperText:'Mensual fijo', prefixIcon: Icon(Icons.payments), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled:true), keyboardType:TextInputType.number, validator:(v)=>v!.isEmpty?'Requerido':null),
        const SizedBox(height:12),
        InkWell(onTap:_pickInscripcion, child: InputDecorator(decoration: const InputDecoration(labelText:'Fecha de inscripción', suffixIcon: Icon(Icons.calendar_today), helperText:'Hoy, modificable', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))), filled:true), child: Text(DateFormat('dd/MM/yyyy','es').format(fechaInscripcion), style: const TextStyle(fontWeight: FontWeight.bold)))),
      ]))),
      const SizedBox(height:20),
      SizedBox(width: double.infinity, child: FilledButton.icon(icon: const Icon(Icons.save), label: const Text('GUARDAR'), onPressed:_save)),
    ])));
  }
}
