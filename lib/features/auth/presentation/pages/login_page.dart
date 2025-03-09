import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../core/extensions/num_extension.dart';
import '../../../../core/extensions/widget_extensions.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/login_usecase.dart';
import '../blocs/auth_bloc.dart';
import '../widgets/widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  late AuthBloc _authBloc;

  @override
  void initState() {
    _authBloc = sl<AuthBloc>();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      _authBloc.add(LoginEvent(params: LoginParams(email: _email.text, password: _password.text)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (_, state) {
          if (state is AuthError) {
            context.snakebar(state.failure.message ?? 'Login Failed');
          } else if (state is AuthLoaded) {
            context.go(Paths.home);
          }
        },
        builder: (_, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            // Show login form
            return AuthSafeWrap(
              child: Padding(
                padding: 16.eiAll,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text(
                          context.tr(I18nKeys.welcomeBack),
                          textAlign: TextAlign.center,
                          style: context.textTheme.headlineMedium,
                        ),
                      ),
                      36.sb(),
                      TextFormField(
                        controller: _email,
                        decoration: InputDecoration(labelText: context.tr(I18nKeys.email)),
                        validator:
                            (value) => value!.isEmpty ? context.tr(I18nKeys.enterEmail) : null,
                      ),
                      16.sb(),
                      TextFormField(
                        controller: _password,
                        decoration: InputDecoration(labelText: context.tr(I18nKeys.password)),
                        obscureText: true,
                        validator:
                            (value) => value!.isEmpty ? context.tr(I18nKeys.enterPassword) : null,
                      ),
                      24.sb(),
                      AuthActionButton(text: context.tr(I18nKeys.login), onPressed: _login),
                      12.sb(),
                      Text(
                        context.tr(I18nKeys.or),
                        style: context.textTheme.titleMedium!.copyWith(
                          color: context.colorScheme.onSecondaryContainer,
                        ),
                      ),
                      12.sb(),
                      SocialSignin(
                        icon: Image.asset('assets/images/ic-google.png', width: 30),
                        text: context.tr(I18nKeys.loginWithGoogle),
                      ),
                      20.sb(),
                      SocialSignin(
                        icon: Image.asset('assets/images/ic-facebook.png', width: 30),
                        text: context.tr(I18nKeys.loginWithGoogle),
                      ),
                      24.sb(),
                      TextButton(
                        onPressed: () => context.push(Paths.register),
                        child: Text(
                          context.tr(I18nKeys.notHaveAccount),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
