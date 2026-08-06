import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/tradex_widgets.dart';
import 'tradex_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final user = TextEditingController(text: 'admin');
  final pass = TextEditingController(text: 'titan123');
  bool obscure = true;
  bool loading = false;
  String? error;

  Future<void> login() async {
    setState(() {
      loading = true;
      error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    if (user.text.trim() == 'admin' && pass.text == 'titan123') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const TradeXShell()),
      );
    } else {
      setState(() => error = 'Invalid demo credentials.');
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackdrop(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 470),
                child: XGlassPanel(
                  padding: const EdgeInsets.all(30),
                  glowColor: TradeXColors.cyan,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [TradeXColors.cyan, TradeXColors.violet],
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: TradeXColors.cyan.withOpacity(.25),
                              blurRadius: 32,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Color(0xFF06101A),
                          size: 44,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'SCIOOL TRADE X PRO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'AI-Powered Trading Command Center',
                        style: TextStyle(color: TradeXColors.muted),
                      ),
                      const SizedBox(height: 28),
                      TextField(
                        controller: user,
                        decoration: const InputDecoration(
                          labelText: 'Identity / Username',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: pass,
                        obscureText: obscure,
                        onSubmitted: (_) => login(),
                        decoration: InputDecoration(
                          labelText: 'Security Key',
                          prefixIcon: const Icon(Icons.lock_rounded),
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => obscure = !obscure),
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_rounded
                                  : Icons.visibility_off_rounded,
                            ),
                          ),
                        ),
                      ),
                      if (error != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            error!,
                            style: const TextStyle(color: TradeXColors.red),
                          ),
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: loading ? null : login,
                          icon: loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.login_rounded),
                          label: Text(
                            loading
                                ? 'AUTHENTICATING...'
                                : 'ENTER COMMAND CENTER',
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 15,
                            color: TradeXColors.green,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Demo mode • Protected risk controls',
                            style: TextStyle(
                              color: TradeXColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackdrop extends StatelessWidget {
  const _LoginBackdrop();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topLeft,
          radius: 1.5,
          colors: [
            Color(0xFF18275C),
            TradeXColors.background,
            Color(0xFF040612),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TradeXColors.cyan.withOpacity(.045)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 54) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 54) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
