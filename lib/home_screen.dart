import 'package:doch_frontend/Provider/language_provider.dart';
import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeFake extends StatelessWidget {
  static var darkTheme;

  static var lightTheme;

  const HomeFake({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.translate('home') ?? 'Home'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)?.translate('welcome') ?? 'Welcome',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                languageProvider.toggleLanguage();
              },
              child: Text(
                languageProvider.locale.languageCode == 'en'
                    ? 'Change to Kurdish'
                    : 'Change to English',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              child: Text(
                themeProvider.isDarkMode
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
