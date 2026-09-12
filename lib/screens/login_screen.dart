import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onOk;
  const LoginScreen({super.key, required this.onOk});
  @override State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focus = List.generate(4, (_) => FocusNode());
  bool has = false, loading = true;
  @override void initState(){ super.initState(); _init(); }
  Future<void> _init() async { has = await _auth.hasPin(); setState(()=> loading=false); }
  String get pin => _controllers.map((c)=>c.text).join();
  void _onChanged(String v, int i){
    if(v.isNotEmpty && i<3) _focus[i+1].requestFocus();
    if(v.isEmpty && i>0) _focus[i-1].requestFocus();
    setState((){});
  }
  void _submit() async {
    if(pin.length<4) return;
    if(!has){ await _auth.setPin(pin); widget.onOk(); }
    else { if(await _auth.checkPin(pin)) widget.onOk(); else if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('PIN incorrecto'))); }
  }
  @override Widget build(BuildContext context){
    if(loading) return const Scaffold(body:Center(child:CircularProgressIndicator()));
    return Scaffold(body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors:[Color(0xFF111111), Color(0xFFD32F2F)], begin:Alignment.topCenter, end:Alignment.bottomCenter)), child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Card(elevation:8, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Hero(tag:'logo', child: Image.asset('assets/logo.png', height:100, errorBuilder:(_,__,___)=> const Icon(Icons.sports_mma, size:80, color: Color(0xFFD32F2F)))),
      const SizedBox(height:12),
      const Text('CENTRAL BOXING', style: TextStyle(fontSize:22, fontWeight: FontWeight.bold, letterSpacing:2)),
      const SizedBox(height:4),
      Text(has?'INGRESAR PIN':'CREAR PIN', style: TextStyle(color: Colors.grey, letterSpacing:1)),
      const SizedBox(height:24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (i)=> Container(width:56, margin: const EdgeInsets.symmetric(horizontal:6), child: TextField(controller:_controllers[i], focusNode:_focus[i], obscureText:true, textAlign:TextAlign.center, keyboardType:TextInputType.number, maxLength:1, style: const TextStyle(fontSize:20, fontWeight:FontWeight.bold), decoration: InputDecoration(counterText:'', filled:true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), onChanged:(v)=>_onChanged(v,i))))),
      const SizedBox(height:24),
      SizedBox(width: double.infinity, child: FilledButton.icon(icon: const Icon(Icons.lock), label: Text(has?'ENTRAR':'GUARDAR'), onPressed: pin.length==4? _submit : null)),
    ])))))));
  }
}
