// Profile Page
import 'package:doch_frontend/Provider/language_provider.dart';
import 'package:doch_frontend/Provider/theme_provider.dart';
import 'package:doch_frontend/localization/appLocalizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        title: Text(
          AppLocalizations.of(context)?.translate('profile') ?? 'Profile',
        ),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)?.translate('profile_content') ??
              'Profile content goes here',
        ),
      ),
    );
  }
}

// Feedback & Support Page
class FeedbackSupportPage extends StatelessWidget {
  const FeedbackSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        title: Text(
          AppLocalizations.of(context)?.translate('feedback_support') ??
              'Feedback & Support',
        ),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)?.translate('feedback_content') ??
              'Feedback and support content goes here',
        ),
      ),
    );
  }
}

// Settings Page
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        title: Text(
          AppLocalizations.of(context)?.translate('settings') ?? 'Settings',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('appearance') ??
                  'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(
                AppLocalizations.of(context)?.translate('dark_mode') ??
                    'Dark Mode',
              ),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
            ),
            const Divider(),
            Text(
              AppLocalizations.of(context)?.translate('language') ?? 'Language',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(
                languageProvider.locale.languageCode == 'en'
                    ? AppLocalizations.of(
                          context,
                        )?.translate('switch_to_kurdish') ??
                        'Switch to Kurdish'
                    : AppLocalizations.of(
                          context,
                        )?.translate('switch_to_english') ??
                        'Switch to English',
              ),
              value: languageProvider.locale.languageCode != 'en',
              onChanged: (value) {
                languageProvider.toggleLanguage();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// About Page
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 3, 90, 105),
        title: Text(
          AppLocalizations.of(context)?.translate('about') ?? 'About',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlutterLogo(size: 100),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.translate('app_name') ??
                    'DoCH Mobile App',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)?.translate('app_version') ??
                    'Version 1.0.0',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)?.translate('app_description') ??
                    'This is a sample application with localization and theme support.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
