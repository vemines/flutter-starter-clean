import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/cubits/locale_cubit.dart';
import '../../../../app/cubits/theme_cubit.dart';
import '../../../../app/locale.dart';
import '../../../../app/routes.dart';
import '../../../../configs/locale_config.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/blocs/auth_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _newPassword = TextEditingController();

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(context.tr(I18nKeys.changePassword)),
          content: SizedBox(
            width: 500,
            child: TextFormField(
              controller: _newPassword,
              obscureText: true,
              decoration: InputDecoration(hintText: context.tr(I18nKeys.enterNewPassword)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr(I18nKeys.cancel)),
            ),
            TextButton(
              onPressed: () {
                final authBloc = sl<AuthBloc>();
                if (_newPassword.text.isNotEmpty && authBloc.state is AuthLoaded) {
                  sl<AuthBloc>().add(
                    UpdatePasswordEvent(
                      newPassword: _newPassword.text,
                      userId: (authBloc.state as AuthLoaded).auth.id,
                    ),
                  );
                }
                Navigator.of(context).pop();
                context.pushReplacement(Paths.login);
              },
              child: Text(context.tr(I18nKeys.changePasswordAction)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr(I18nKeys.settings))),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return ListView(
            children: [
              if (authState is AuthLoaded) ...[
                ListTile(
                  leading: Icon(Icons.account_circle_outlined),
                  title: Text(context.tr(I18nKeys.userProfile)),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context.push('${Paths.userProfile}/${authState.auth.id}');
                  },
                ),
                const Divider(),
              ],
              _buildThemeTile(context),
              const Divider(),
              _buildLanguageTile(context),
              const Divider(),
              ListTile(
                title: Text(context.tr(I18nKeys.changePassword)),
                leading: const Icon(Icons.key),
                onTap: _showChangePasswordDialog,
              ),
              const Divider(),
              ListTile(
                title: Text(context.tr(I18nKeys.logout)),
                leading: const Icon(Icons.logout),
                onTap: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  context.pushReplacement(Paths.login);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final options = [ThemeCubit.lightThemeKey, ThemeCubit.darkThemeKey, ThemeCubit.customThemeKey];

    return BlocBuilder<ThemeCubit, ThemeData>(
      builder: (context, theme) {
        final selectedTheme = ThemeCubit.themeToString(theme);
        return _buildOptionTile(
          title: context.tr(I18nKeys.theme),
          icon: Icon(Icons.color_lens_outlined),
          selectedOption: selectedTheme,
          options: options,
          displayOptions: options,
          onChanged: (value) {
            if (value != null) context.read<ThemeCubit>().toggleTheme(value);
          },
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext context) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        final selectedLanguage = locale.languageCode;
        return _buildOptionTile(
          title: context.tr(I18nKeys.language),
          icon: Icon(Icons.language),
          selectedOption: selectedLanguage,
          options: supportedLocaleCode,
          displayOptions: [context.tr(I18nKeys.english), context.tr(I18nKeys.vietnamese)],
          onChanged: (value) {
            if (value != null) context.read<LocaleCubit>().setLocale(Locale(value));
          },
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required Icon icon,
    required String selectedOption,
    required List<String> options,
    required List<String> displayOptions,
    required ValueChanged<String?>? onChanged,
  }) {
    return ListTile(
      title: Text(title),
      leading: icon,
      subtitle: Text(_getDisplayValue(selectedOption, options, displayOptions) ?? ''),
      trailing: const Icon(Icons.arrow_drop_down),
      onTap: () {
        _showDropdownDialog(title, selectedOption, options, displayOptions, onChanged);
      },
    );
  }

  String? _getDisplayValue(String value, List<String> values, List<String> displayValues) {
    int index = values.indexOf(value);
    if (index == -1 || index >= displayValues.length) return null;
    return displayValues[index];
  }

  void _showDropdownDialog(
    String title,
    String? currentValue,
    List<String> values,
    List<String> displayValues,
    ValueChanged<String?>? onChanged,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select $title'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(values.length, (index) {
                return ListTile(
                  title: Text(displayValues[index]),
                  onTap: () {
                    if (onChanged != null) {
                      onChanged(values[index]);
                      context.pop();
                    }
                  },
                  trailing: currentValue == values[index] ? Icon(Icons.check) : null,
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
