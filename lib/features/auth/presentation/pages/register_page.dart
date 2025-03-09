import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/register_usecase.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _signUpGlobalKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _showPassword = true;

  late AuthBloc _authBloc;

  @override
  void initState() {
    _authBloc = sl<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  void _register() {
    if (_signUpGlobalKey.currentState!.validate()) {
      if (_password.text != _confirmPassword.text) {
        context.snakebar(context.tr(I18nKeys.passwordsDontMatch));
        return;
      }

      _authBloc.add(
        RegisterEvent(
          params: RegisterParams(
            fullname: _name.text,
            email: _email.text,
            password: _password.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        // Use BlocConsumer
        listener: (context, state) {
          if (state is AuthError) {
            context.snakebar(state.failure.message ?? 'Registration Failed');
          } else if (state is AuthLoaded) {
            context.go(Paths.home);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Show registration form
            return AuthSafeWrap(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(key: _signUpGlobalKey, child: _buildForm(context)),
              ),
            );
          }
        },
      ),
    );
  }

  Column _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back Icon Button
        GestureDetector(
          onTap: () {
            context.pop();
          },
          child: const Icon(Icons.chevron_left, size: 40),
        ),
        24.sb(),
        Text(
          context.tr(I18nKeys.registerAccount),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        30.sb(),
        Column(
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(hintText: context.tr(I18nKeys.username)),
              validator: (value) => value!.isEmpty ? context.tr(I18nKeys.enterUsername) : null,
            ),

            16.sb(),
            TextFormField(
              controller: _email,
              decoration: InputDecoration(hintText: context.tr(I18nKeys.email)),
              validator:
                  (value) =>
                      value!.isEmpty || !value.contains('@')
                          ? context.tr(I18nKeys.enterEmail)
                          : null,
            ),

            16.sb(),
            TextFormField(
              controller: _password,
              obscureText: _showPassword,
              decoration: InputDecoration(
                hintText: context.tr(I18nKeys.password),
                suffixIcon: GestureDetector(
                  onTap: () {
                    setState(() => _showPassword = !_showPassword);
                  },
                  child: Icon(
                    _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: (value) => value!.isEmpty ? context.tr(I18nKeys.enterPassword) : null,
            ),

            16.sb(),
            TextFormField(
              controller: _confirmPassword,
              obscureText: _showPassword,
              decoration: InputDecoration(hintText: context.tr(I18nKeys.confirmPassword)),
              validator:
                  (value) => value!.isEmpty ? context.tr(I18nKeys.enterConfirmPassword) : null,
            ),
            30.sb(),

            AuthActionButton(text: context.tr(I18nKeys.continueLabel), onPressed: _register),
          ],
        ),
      ],
    );
  }
}
