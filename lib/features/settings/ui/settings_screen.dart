import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/services/backup_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USTAWIENIA'), // L10N
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSectionHeader(context, 'PROFIL'), // L10N
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.navyBlue),
            title: const Text('Anatol Karamanyan'),
            subtitle: const Text('Modelarz od 2020'), // L10N
            trailing: const Icon(Icons.edit, size: 20),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'DANE I KOPIA ZAPASOWA'), // L10N
          ListTile(
            leading: const Icon(Icons.archive, color: AppColors.navyBlue),
            title: const Text('Eksportuj kolekcję (ZIP)'), // L10N
            subtitle: const Text('Kopia zapasowa wszystkich zdjęć i wpisów'), // L10N
            onTap: () async {
              try {
                await GetIt.I<BackupService>().shareBackup();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Błąd: $e')), // L10N
                  );
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.unarchive, color: AppColors.navyBlue),
            title: const Text('Importuj kolekcję (ZIP)'), // L10N
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'WSPARCIE'), // L10N
          ListTile(
            leading: const Icon(Icons.coffee, color: AppColors.red),
            title: const Text('Postaw mi kawę'), // L10N
            subtitle: const Text('Wesprzyj rozwój ScaleBook'), // L10N
            trailing: const Icon(Icons.open_in_new, size: 20),
            onTap: () {},
          ),
          const Divider(),
          _buildSectionHeader(context, 'APLIKACJA'), // L10N
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.navyBlue),
            title: const Text('Język'), // L10N
            trailing: const Text('Polski'), // L10N
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.grey),
            title: const Text('Wyloguj się'), // L10N
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('Usuń konto'), // L10N
            onTap: () {},
          ),
          const SizedBox(height: 32),
          const SizedBox(height: 32),
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.navyBlue, width: 2),
              ),
              child: ClipOval(
                child: Image.asset('assets/images/app_logo.png'),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'ScaleBook v1.0.0', // L10N
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.grey),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
      ),
    );
  }
}
