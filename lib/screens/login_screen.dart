import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onOk;
  const LoginScreen({super.key, required this.onOk});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focus = List.generate(4, (_) => FocusNode());
  bool has = false, loading = true;
  bool bioAvailable = false, bioEnabled = false, bioBusy = false;
  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 4; i++) {
      _focus[i].onKeyEvent = (node, event) => _handleKey(event, i);
    }
    _init();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _init() async {
    has = await _auth.hasPin();
    bioAvailable = await _auth.canUseBiometrics();
    bioEnabled = await _auth.isBiometricEnabled();
    setState(() => loading = false);
    if (has && bioAvailable && bioEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loginWithBio());
    }
  }

  Future<void> _loginWithBio() async {
    if (bioBusy) return;
    setState(() => bioBusy = true);
    final ok = await _auth.authenticate();
    if (!mounted) return;
    setState(() => bioBusy = false);
    if (ok) {
      widget.onOk();
    }
  }

  Future<void> _loginWithBioOrEnable() async {
    if (bioEnabled) {
      await _loginWithBio();
      return;
    }
    final ok = await _auth.authenticate();
    if (ok) {
      await _auth.setBiometricEnabled(true);
      if (!mounted) return;
      setState(() => bioEnabled = true);
      widget.onOk();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo verificar la huella')),
      );
    }
  }

  Future<void> _offerEnableBio() async {
    if (!bioAvailable || bioEnabled) return;
    if (!mounted) return;
    final c = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Activar huella'),
            content: const Text(
              '¿Activar desbloqueo con huella para próximas veces? Podrás seguir usando el PIN.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ahora no'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Activar'),
              ),
            ],
          ),
    );
    if (c == true) {
      final ok = await _auth.authenticate();
      if (ok) {
        await _auth.setBiometricEnabled(true);
        if (mounted) setState(() => bioEnabled = true);
      }
    }
  }

  String get pin => _controllers.map((c) => c.text).join();

  KeyEventResult _handleKey(KeyEvent event, int i) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[i].text.isEmpty &&
        i > 0) {
      _controllers[i - 1].clear();
      _focus[i - 1].requestFocus();
      setState(() {});
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _focusBest() {
    final firstEmpty = _controllers.indexWhere((c) => c.text.isEmpty);
    if (firstEmpty == -1) {
      _focus[3].requestFocus();
    } else {
      _focus[firstEmpty].requestFocus();
    }
  }

  void _clearAll() {
    for (final c in _controllers) {
      c.clear();
    }
    _focus[0].requestFocus();
    setState(() {});
  }

  void _onChanged(String v, int i) {
    if (v.length > 1) {
      final digits = v.replaceAll(RegExp(r'[^0-9]'), '').split('');
      for (var k = 0; k < 4; k++) {
        _controllers[k].text = k < digits.length ? digits[k] : '';
      }
      _focusBest();
      setState(() {});
      return;
    }
    if (v.isNotEmpty && i < 3) {
      _focus[i + 1].requestFocus();
    }
    if (v.isEmpty && i > 0) {
      _focus[i - 1].requestFocus();
    }
    setState(() {});
  }

  void _submit() async {
    if (pin.length < 4) return;
    if (!has) {
      await _auth.setPin(pin);
      widget.onOk();
      await _offerEnableBio();
    } else {
      if (await _auth.checkPin(pin)) {
        widget.onOk();
      } else if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('PIN incorrecto')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF111111), Color(0xFFD32F2F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.sports_mma,
                              size: 80,
                              color: Color(0xFFD32F2F),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'CENTRAL BOXING',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      has ? 'INGRESAR PIN' : 'CREAR PIN',
                      style: TextStyle(color: Colors.grey, letterSpacing: 1),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        4,
                        (i) => Container(
                          width: 56,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: TextField(
                            controller: _controllers[i],
                            focusNode: _focus[i],
                            obscureText: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (v) => _onChanged(v, i),
                            onTap: _focusBest,
                          ),
                        ),
                      ),
                    ),
                    if (pin.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.backspace_outlined),
                        label: const Text('Borrar'),
                        onPressed: _clearAll,
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.lock),
                        label: Text(has ? 'ENTRAR' : 'GUARDAR'),
                        onPressed: pin.length == 4 ? _submit : null,
                      ),
                    ),
                    if (has && bioAvailable)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            icon:
                                bioBusy
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.fingerprint),
                            label: Text(
                              bioEnabled
                                  ? 'Usar huella'
                                  : 'Entrar con huella (activar)',
                            ),
                            onPressed: bioBusy ? null : _loginWithBioOrEnable,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
