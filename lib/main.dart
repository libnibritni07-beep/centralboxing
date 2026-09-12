import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart' as fl;
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'providers/alumno_provider.dart';
import 'providers/theme_provider.dart';
import 'core/theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, d) async {
    await NotificationService.checkAndNotify();
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  await NotificationService.init();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "vencimientos",
    "checkVencimientos",
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(minutes: 1),
  );
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<App> createState() => _S();
}

class _S extends State<App> {
  bool logged = false;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final has = await AuthService().hasPin();
    if (!has) {
      loading = false;
    } else {
      loading = false;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlumnoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder:
            (_, t, __) => MaterialApp(
              title: 'Central Boxing',
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: t.mode,
              locale: const Locale('es', 'MX'),
              localizationsDelegates: const [
                fl.GlobalMaterialLocalizations.delegate,
                fl.GlobalWidgetsLocalizations.delegate,
                fl.GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [Locale('es', 'MX'), Locale('es')],
              home:
                  loading
                      ? const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      )
                      : logged
                      ? const DashboardScreen()
                      : LoginScreen(onOk: () => setState(() => logged = true)),
            ),
      ),
    );
  }
}
