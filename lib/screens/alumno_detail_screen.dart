import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/alumno.dart';
import '../providers/alumno_provider.dart';
import '../services/pago_service.dart';
import 'alumno_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class AlumnoDetailScreen extends StatefulWidget {
  final Alumno alumno;
  const AlumnoDetailScreen({super.key, required this.alumno});
  @override State<AlumnoDetailScreen> createState()=>_S();
}
class _S extends State<AlumnoDetailScreen>{
  @override Widget build(BuildContext context){
    final a=widget.alumno;
    return Scaffold(appBar: AppBar(title: Text(a.nombre), actions:[
      IconButton(icon: const Icon(Icons.edit), onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>AlumnoFormScreen(alumno:a))).then((_)=>setState((){}))),
      IconButton(icon: const Icon(Icons.delete), onPressed: ()async{ final c=await showDialog<bool>(context:context, builder:(_)=>AlertDialog(title: const Text('Eliminar'), content: const Text('¿Eliminar alumno?'), actions:[TextButton(onPressed:()=>Navigator.pop(context,false), child:const Text('Cancelar')), TextButton(onPressed:()=>Navigator.pop(context,true), child:const Text('Eliminar'))])); if(c==true){ await context.read<AlumnoProvider>().remove(a.id!); if(mounted) Navigator.pop(context);} }),
    ]), body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
      Text('Tel: ${a.telefono}'), Text('Vencimiento: ${DateFormat('dd/MM/yyyy').format(a.fechaVencimiento)} - ${a.estado}'), Text('Nacimiento: ${a.fechaNacimiento!=null?DateFormat('dd/MM/yyyy').format(DateTime.parse(a.fechaNacimiento!)):'-'} (${a.edadTexto})'), Text('Monto: \$${a.monto}'),
      const SizedBox(height:12),
      Row(children:[
        ElevatedButton.icon(icon: const Icon(Icons.check), label: const Text('Marcar Pagado'), onPressed: ()async{
          await PagoService.registrarPago(a.id!, a.monto);
          await context.read<AlumnoProvider>().load();
          if(mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Pago registrado'))); Navigator.pop(context); }
        }),
        const SizedBox(width:8),
        ElevatedButton.icon(icon: const Icon(Icons.message), label: const Text('WhatsApp'), onPressed: ()async{
          final txt='Hola ${a.nombre}! Te habla Central Boxing. Tu cuota vence el ${DateFormat('dd/MM/yyyy').format(a.fechaVencimiento)} Monto \$${a.monto}. Te esperamos!';
          final wa=a.telefono.replaceAll(RegExp(r'[^0-9]'), ''); final uri=Uri.parse('https://wa.me/$wa?text=${Uri.encodeComponent(txt)}');
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }),
      ]),
      const Divider(height:24),
      const Text('Historial de Pagos', style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(child: FutureBuilder(future: PagoService.historial(a.id!), builder: (_,snap){
        if(!snap.hasData) return const Center(child:CircularProgressIndicator());
        final list=snap.data!; if(list.isEmpty) return const Text('Sin pagos');
        return ListView.builder(itemCount: list.length, itemBuilder: (_,i){ final p=list[i]; return ListTile(title: Text('\$${p.monto} - ${p.mesCubierto}'), subtitle: Text('${DateFormat('dd/MM/yyyy').format(p.fechaPago)} ${p.metodo??''}'));});
      })),
    ])));
  }
}
