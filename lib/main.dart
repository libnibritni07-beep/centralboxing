import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'providers/alumno_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher(){ Workmanager().executeTask((task, d) async { await NotificationService.checkAndNotify(); return Future.value(true); }); }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask("vencimientos","checkVencimientos", frequency: const Duration(hours: 24), initialDelay: const Duration(minutes: 1));
  runApp(const App());
}

class App extends StatefulWidget { const App({super.key}); @override State<App> createState()=>_S(); }
class _S extends State<App>{
  bool logged=false; bool loading=true;
  @override void initState(){ super.initState(); _check(); }
  Future<void> _check() async { final has=await AuthService().hasPin(); if(!has) loading=false; else loading=false; setState((){}); }
  @override Widget build(BuildContext context){
    return ChangeNotifierProvider(create:(_)=>AlumnoProvider(), child: MaterialApp(title:'Central Boxing', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red)), home: loading? const Scaffold(body:Center(child:CircularProgressIndicator())) : logged? const DashboardScreen() : LoginScreen(onOk: ()=>setState(()=>logged=true))));
  }
}
