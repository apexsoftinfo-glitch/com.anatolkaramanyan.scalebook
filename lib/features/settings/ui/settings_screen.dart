import 'package:flutter/material.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:scalebook/features/session/presentation/cubit/locale_cubit.dart';
import '../../../core/design_system/app_colors.dart';
import '../../../core/services/backup_service.dart';
import '../../../core/services/review_service.dart';
import '../../session/domain/models/user_session.dart';
import '../../session/domain/repositories/session_repository.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../../profiles/models/profile_model.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessionRepo = GetIt.I<SessionRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).settings), // L10N
      ),
      body: BlocBuilder<SessionCubit, UserSession>(
        builder: (context, state) {
          final profile = state.mapOrNull(
            (session) => session.profile,
          );

          return ListView(
            children: [
              const SizedBox(height: 16),
              _buildSectionHeader(context, S.of(context).profile), // L10N
              ListTile(
                leading: const Icon(Icons.person, color: AppColors.navyBlue),
                title: Text(profile?.firstName ?? 'Modelarz'), // L10N
                subtitle: Text(S.of(context).scalebookProfile), // L10N
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () => _showEditProfileDialog(context, sessionRepo, profile),
              ),
              if (state.userId != null && !state.isAnonymous)
                ListTile(
                  leading: const Icon(Icons.lock_outline, color: AppColors.navyBlue),
                  title: Text(S.of(context).changePassword),
                  onTap: () => _showChangePasswordDialog(context, sessionRepo),
                ),
              const Divider(),
              _buildSectionHeader(context, S.of(context).dataAndBackup), // L10N
              Builder(
                builder: (tileContext) => ListTile(
                  leading: const Icon(Icons.archive, color: AppColors.navyBlue),
                  title: Text(S.of(context).exportCollection), // L10N
                  subtitle: Text(S.of(context).exportCollectionSubtitle), // L10N
                  onTap: () async {
                    try {
                      final renderObject = tileContext.findRenderObject();
                      final rect = renderObject is RenderBox ? renderObject.localToGlobal(Offset.zero) & renderObject.size : null;
                      await GetIt.I<BackupService>().shareBackup(sharePositionOrigin: rect);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(S.of(context).error(e.toString()))), // L10N
                        );
                      }
                    }
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.unarchive, color: AppColors.navyBlue),
                title: Text(S.of(context).importCollection), // L10N
                onTap: () async {
                  final result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['zip'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final file = File(result.files.single.path!);
                    if (context.mounted) {
                      try {
                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        
                        await GetIt.I<BackupService>().restoreBackup(file);
                        
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context).importCollectionSuccess)), // L10N
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // Close loading
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(S.of(context).error(e.toString()))), // L10N
                          );
                        }
                      }
                    }
                  }
                },
              ),


              const Divider(),
              _buildSectionHeader(context, S.of(context).support), // L10N
              ListTile(
                leading: const Icon(Icons.star_rate_rounded, color: AppColors.navyBlue),
                title: Text(S.of(context).rateScaleBook), // L10N
                subtitle: Text(S.of(context).rateScaleBookSubtitle), // L10N
                onTap: () => GetIt.I<ReviewService>().requestReview(force: true),
              ),
              ListTile(
                leading: const Icon(Icons.coffee, color: AppColors.red),
                title: Text(S.of(context).buyMeACoffee), // L10N
                subtitle: Text(S.of(context).buyMeACoffeeSubtitle), // L10N
                trailing: const Icon(Icons.qr_code_2, size: 24, color: AppColors.navyBlue),
                onTap: () => _showSupportDialog(context),
              ),
              const Divider(),
              _buildSectionHeader(context, S.of(context).application), // L10N
              BlocBuilder<LocaleCubit, Locale>(
                builder: (context, locale) {
                  return ListTile(
                    leading: const Icon(Icons.language, color: AppColors.navyBlue),
                    title: Text(S.of(context).language), // L10N
                    trailing: Text(locale.languageCode == 'pl' ? S.of(context).polish : S.of(context).english), // L10N
                    onTap: () => _showLanguageDialog(context),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.grey),
                title: Text(S.of(context).logout), // L10N
                onTap: () async {
                  await sessionRepo.signOut();
                  if (context.mounted) Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: Text(S.of(context).deleteAccount), // L10N
                onTap: () => _showDeleteConfirmation(context, sessionRepo),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    SessionRepository repo,
    ProfileModel? profile,
  ) {
    final controller = TextEditingController(text: profile?.firstName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).editProfile),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: S.of(context).firstName,
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              if (profile != null) {
                final updated = profile.copyWith(firstName: controller.text);
                await repo.updateProfile(updated);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, SessionRepository repo) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).changePasswordTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.of(context).changePasswordDescription),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: S.of(context).newPasswordLabel,
                border: const OutlineInputBorder(),
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.isEmpty) return;
              try {
                await repo.changePassword(controller.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).passwordChangedSuccess)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).error(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(S.of(context).save),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(S.of(context).polish),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('pl'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(S.of(context).english),
              onTap: () {
                context.read<LocaleCubit>().setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, SessionRepository repo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).deleteAccountTitle),
        content: Text(
          S.of(context).deleteAccountConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ANULUJ'), // L10N
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(context); // Close dialog
                await repo.deleteAccount();
                if (context.mounted) Navigator.pop(context); // Close settings
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).errorDeletingAccount(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).deletePermanentlyAction),
          ),
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

  void _showSupportDialog(BuildContext context) {
    const String supportUrl = 'https://buycoffee.to/scalebook';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: AppColors.red),
            const SizedBox(width: 12),
            Text(S.of(context).support),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Twoje wsparcie pozwala mi rozwijać ScaleBook i dodawać nowe funkcje!', // L10N
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(supportUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('POSTAW KAWĘ'), // L10N
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'LUB ZESKANUJ KOD QR', // L10N
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.navyBlue.withValues(alpha: 0.1)),
              ),
              child: Image.asset(
                'assets/images/support_qr.png',
                width: 160,
                height: 160,
                errorBuilder: (context, error, stackTrace) => Column(
                  children: [
                    const Icon(Icons.qr_code, size: 60, color: AppColors.grey),
                    const SizedBox(height: 8),
                    Text('Dodaj plik assets/images/support_qr.png', // L10N
                      style: TextStyle(fontSize: 8, color: AppColors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).cancel),
          ),
        ],
      ),
    );
  }

}
