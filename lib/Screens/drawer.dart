import 'package:doch_frontend/Screens/drawerPages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Provider/theme_provider.dart';
import '../localization/appLocalizations.dart';

class AppDrawer extends StatelessWidget {
  final bool isLoggedIn;

  const AppDrawer({super.key, this.isLoggedIn = true});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      child: Column(
        children: [_buildHeader(context, isLoggedIn), _buildMenuItems(context)],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLoggedIn) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: Color.fromARGB(255, 3, 90, 105)),
      accountName: Text(
        isLoggedIn
            ? 'Name'
            : AppLocalizations.of(context)?.translate('guest') ?? 'Guest',
        style: const TextStyle(fontSize: 24),
      ),
      accountEmail: Text(
        isLoggedIn
            ? 'Email@example.com'
            : AppLocalizations.of(context)?.translate('sign_in_message') ??
                'Please sign in',
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.grey,
        child: Icon(
          isLoggedIn ? Icons.person : Icons.person_outline,
          color: Colors.black,
          size: 40,
        ),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(
              AppLocalizations.of(context)?.translate('profile') ?? 'Profile',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.message),
            title: Text(
              AppLocalizations.of(context)?.translate('feedback_support') ??
                  'Feedback & Support',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeedbackSupportPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(
              AppLocalizations.of(context)?.translate('settings') ?? 'Settings',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(
              AppLocalizations.of(context)?.translate('about') ?? 'About',
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(
              AppLocalizations.of(context)?.translate('logout') ?? 'Log out',
            ),
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context)?.translate('logout_confirm_title') ??
                'Confirm Logout',
          ),
          content: Text(
            AppLocalizations.of(context)?.translate('logout_confirm_message') ??
                'Are you sure you want to log out?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                AppLocalizations.of(context)?.translate('cancel') ?? 'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                // Add your logout logic here
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the drawer
                // Navigate to login page or perform logout
              },
              child: Text(
                AppLocalizations.of(context)?.translate('logout') ?? 'Log out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
