import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onOk;
  const LoginScreen({super.key, required this.onOk});
  @override State<LoginScreen> createState()=>_S();
}
class _S extends State<LoginScreen> {
  final _auth = AuthService();
  String pin=''; bool has=false, loading=true;
  @override void initState(){super.initState(); _init();}
  Future<void> _init() async { has=await _auth.hasPin(); setState(()=>loading=false); }
  void _submit() async {
    if(pin.length<4) return;
    if(!has){ await _auth.setPin(pin); widget.onOk(); }
    else { if(await _auth.checkPin(pin)) widget.onOk(); else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('PIN incorrecto')));}
  }
  @override Widget build(BuildContext context){
    if(loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(appBar: AppBar(title: Text(has?'Ingresar PIN':'Crear PIN')), body: Padding(padding: const EdgeInsets.all(24), child: Column(children:[
      TextField(obscureText:true, keyboardType:TextInputType.number, maxLength:4, onChanged:(v)=>pin=v, decoration: InputDecoration(labelText: has?'PIN':'Nuevo PIN 4 dígitos')),
      const SizedBox(height:16),
      ElevatedButton(onPressed:_submit, child: Text(has?'Entrar':'Guardar')),
    ])));
  }
}
