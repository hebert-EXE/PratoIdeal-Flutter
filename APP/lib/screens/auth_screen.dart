import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/google_auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_typography.dart';
import '../utils/app_colors.dart';
import '../widgets/ui/ui.dart';

/// Tela única de Login/Cadastro, espelhando o `AuthForm` do web (tema escuro,
/// botão em gradiente, login Google, toggle entre os modos).
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.startInLogin = true});

  final bool startInLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Paleta fixa escura (independe do tema do app), como no web.
  static const _bg = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF18181B); // zinc-900
  static const _border = Color(0xFF27272A); // zinc-800
  static const _muted = Color(0xFF71717A); // zinc-500

  late bool _isLogin = widget.startInLogin;
  bool _obscure = true;
  bool _termsAccepted = false;
  bool _googleLoading = false;
  bool _submitting = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() => setState(() => _isLogin = !_isLogin);

  Future<void> _submit() async {
    if (!_termsAccepted) {
      AppToast.show(context, 'Aceite os Termos para continuar.',
          type: ToastType.error);
      return;
    }
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final provider = context.read<UserProvider>();

    if (!_isLogin && password.length < 8) {
      AppToast.show(context, 'A senha deve ter no mínimo 8 caracteres.',
          type: ToastType.error);
      return;
    }

    setState(() => _submitting = true);
    try {
      if (_isLogin) {
        await provider.loginWithEmail(email, password);
        // AuthGate troca para a Home automaticamente.
      } else {
        await provider.register(_nameCtrl.text.trim(), email, password);
        if (!mounted) return;
        setState(() => _isLogin = true);
        AppToast.show(context, 'Conta criada! Faça login para entrar.',
            type: ToastType.success);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.show(context, _friendly(e), type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _googleLoading = true);
    try {
      final ok = await context.read<UserProvider>().loginWithGoogle();
      if (!ok && mounted) {
        // cancelado pelo usuário — silencioso
      }
    } on GoogleAuthException catch (e) {
      if (mounted) AppToast.show(context, e.message, type: ToastType.error);
    } catch (e) {
      if (mounted) {
        AppToast.show(context, _friendly(e), type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String _friendly(Object e) =>
      e.toString().replaceAll('Exception: ', '').replaceFirst('Falha no login: ', 'E-mail ou senha incorretos. ');

  @override
  Widget build(BuildContext context) {
    final isLoading =
        _submitting || context.watch<UserProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandWordmark(fontSize: 26)),
                  const SizedBox(height: 40),
                  Text(
                    _isLogin ? 'Muito bem-vindo!' : 'Crie sua conta',
                    textAlign: TextAlign.center,
                    style: AppTypography.display(Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? 'Entre para descobrir novos restaurantes'
                        : 'Junte-se à nossa comunidade gastronômica',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _muted, fontSize: 15),
                  ),
                  const SizedBox(height: 32),

                  if (!_isLogin) ...[
                    _field(
                      controller: _nameCtrl,
                      hint: 'Nome completo',
                      icon: Icons.person_outline,
                      action: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _field(
                    controller: _emailCtrl,
                    hint: 'E-mail',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _field(
                    controller: _passwordCtrl,
                    hint: _isLogin ? 'Senha' : 'Senha (mínimo 8 caracteres)',
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    action: TextInputAction.done,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: _muted,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _termsRow(),
                  const SizedBox(height: 20),

                  GradientButton(
                    label: _isLogin ? 'Entrar' : 'Criar conta',
                    icon: Icons.arrow_forward,
                    isLoading: isLoading,
                    enabled: _termsAccepted,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 28),
                  _divider(),
                  const SizedBox(height: 20),

                  _googleButton(),

                  const SizedBox(height: 32),
                  _toggleRow(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    TextInputAction? action,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: action,
      onSubmitted: onSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _muted),
        prefixIcon: Icon(icon, color: _muted, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: _surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: const BorderSide(color: AppColors.authGradientStart),
        ),
      ),
    );
  }

  Widget _termsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _termsAccepted,
            onChanged: (v) => setState(() => _termsAccepted = v ?? false),
            activeColor: AppColors.authGradientStart,
            side: const BorderSide(color: _muted),
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(color: _muted, fontSize: 13),
              children: [
                TextSpan(text: 'Li e concordo com os '),
                TextSpan(
                  text: 'Termos de Uso',
                  style: TextStyle(color: AppColors.authGradientStart),
                ),
                TextSpan(text: ' e a '),
                TextSpan(
                  text: 'Política de Privacidade',
                  style: TextStyle(color: AppColors.authGradientStart),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Ou continue com',
              style: TextStyle(color: _muted, fontSize: 13)),
        ),
        Expanded(child: Divider(color: _border)),
      ],
    );
  }

  Widget _googleButton() {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        onTap: _googleLoading ? null : _googleSignIn,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: _border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_googleLoading)
                const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else ...[
                const Icon(Icons.g_mobiledata, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Text('Google',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggleRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _isLogin ? 'Ainda não tem conta? ' : 'Já possui conta? ',
          style: const TextStyle(color: _muted),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Text(
            _isLogin ? 'Cadastre-se' : 'Faça login',
            style: const TextStyle(
              color: AppColors.authGradientStart,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
