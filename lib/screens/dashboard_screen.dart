import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/alumno_provider.dart';
import '../widgets/alumno_card.dart';
import 'alumno_form_screen.dart';
import 'alumno_detail_screen.dart';

class DashboardScreen extends StatefulWidget { const DashboardScreen({super.key}); @override State<DashboardScreen> createState()=>_S(); }
class _S extends State<DashboardScreen>{
  @override void initState(){super.initState(); WidgetsBinding.instance.addPostFrameCallback((_)=>context.read<AlumnoProvider>().load());}
  @override Widget build(BuildContext context){
    final p = context.watch<AlumnoProvider>();
    return Scaffold(appBar: AppBar(title: const Text('Central Boxing')), body: Column(children:[
      Padding(padding: const EdgeInsets.all(8), child: Row(children:[
        _card('Al día', p.countAlDia, Colors.green), _card('Por vencer', p.countPorVencer, Colors.orange), _card('Vencidos', p.countVencido, Colors.red),
      ])),
      Padding(padding: const EdgeInsets.all(8), child: TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText:'Buscar', border: OutlineInputBorder()), onChanged:(v){p.query=v; p.load();})),
      SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children:['todos','al_dia','por_vencer','vencido'].map((f)=>Padding(padding: const EdgeInsets.symmetric(horizontal:4), child: FilterChip(label: Text(f), selected: p.filtro==f, onSelected:(_){p.filtro=f; p.load();}))).toList())),
      Expanded(child: ListView.builder(itemCount: p.alumnos.length, itemBuilder: (_,i){ final a=p.alumnos[i]; return AlumnoCard(a:a, onTap: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>AlumnoDetailScreen(alumno:a))));}))
    ]), floatingActionButton: FloatingActionButton(onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder:(_)=>const AlumnoFormScreen())), child: const Icon(Icons.add)));
  }
  Widget _card(String t,int n,Color c)=>Expanded(child: Card(color:c.withOpacity(0.15), child: Padding(padding: const EdgeInsets.all(12), child: Column(children:[Text('$n', style: TextStyle(fontSize:24, fontWeight:FontWeight.bold, color:c)), Text(t, style: TextStyle(color:c))]))));
}
