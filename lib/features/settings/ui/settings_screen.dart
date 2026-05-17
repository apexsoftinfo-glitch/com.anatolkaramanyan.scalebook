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
import 'dart:async';

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
              
              // 1. PROFILE
              _buildExpandableSection(
                context: context,
                title: S.of(context).profile,
                icon: Icons.person_outline,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: AppColors.navyBlue),
                    title: Text(profile?.firstName ?? 'Modelarz'), // L10N
                    subtitle: Text(state.email ?? S.of(context).scalebookProfile), // L10N
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () => _showEditProfileDialog(context, sessionRepo, profile),
                  ),
                  if (state.userId != null && !state.isAnonymous)
                    ListTile(
                      leading: const Icon(Icons.lock_outline, color: AppColors.navyBlue),
                      title: Text(S.of(context).changePassword),
                      onTap: () => _showChangePasswordDialog(context, sessionRepo),
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
              ),

              const Divider(),

              // 2. DATA AND BACKUP
              _buildExpandableSection(
                context: context,
                title: S.of(context).dataAndBackup,
                icon: Icons.storage_outlined,
                children: [
                  Builder(
                    builder: (tileContext) => ListTile(
                      leading: const Icon(Icons.archive, color: AppColors.navyBlue),
                      title: Text(S.of(context).exportCollection), // L10N
                      subtitle: Text(S.of(context).exportCollectionSubtitle), // L10N
                      onTap: () async {
                        final progressController = StreamController<double>();
                        try {
                          _showProgressDialog(context, S.of(context).backingUp, progressController.stream);

                          // Give UI time to render the dialog before heavy processing
                          await Future.delayed(const Duration(milliseconds: 150));
                          if (!context.mounted) return;

                          final renderObject = tileContext.findRenderObject();
                          final rect = renderObject is RenderBox ? renderObject.localToGlobal(Offset.zero) & renderObject.size : null;
                          
                          await GetIt.I<BackupService>().shareBackup(
                            sharePositionOrigin: rect,
                            onProgress: (p) => progressController.add(p),
                          );

                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog
                          }
                        } catch (e) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close dialog if open
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(S.of(context).error(e.toString()))), // L10N
                            );
                          }
                        } finally {
                          progressController.close();
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
                        final progressController = StreamController<double>();
                        if (context.mounted) {
                          try {
                            _showProgressDialog(context, S.of(context).restoring, progressController.stream);
                            
                            // Give UI time to render the dialog before heavy processing
                            await Future.delayed(const Duration(milliseconds: 150));
                            if (!context.mounted) return;

                            await GetIt.I<BackupService>().restoreBackup(
                              file,
                              onProgress: (p) => progressController.add(p),
                            );

                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              _showSuccessDialog(context, S.of(context).importCollectionSuccess);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              Navigator.pop(context); // Close dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).error(e.toString()))), // L10N
                              );
                            }
                          } finally {
                            progressController.close();
                          }
                        }
                      }
                    },
                  ),
                ],
              ),

              const Divider(),

              // 3. SUPPORT (Expandable for Rate, but Coffee visible)
              _buildExpandableSection(
                context: context,
                title: S.of(context).support,
                icon: Icons.favorite_border,
                children: [
                  ListTile(
                    leading: const Icon(Icons.star_rate_rounded, color: AppColors.navyBlue),
                    title: Text(S.of(context).rateScaleBook), // L10N
                    subtitle: Text(S.of(context).rateScaleBookSubtitle), // L10N
                    onTap: () => GetIt.I<ReviewService>().requestReview(force: true),
                  ),
                ],
              ),

              // ALWAYS VISIBLE: Buy Me A Coffee
              ListTile(
                leading: const Icon(Icons.coffee, color: AppColors.red),
                title: Text(S.of(context).buyMeACoffee), // L10N
                subtitle: Text(S.of(context).buyMeACoffeeSubtitle), // L10N
                trailing: const Icon(Icons.qr_code_2, size: 24, color: AppColors.navyBlue),
                onTap: () => _showSupportDialog(context),
              ),

              const Divider(),

              // 4. APPLICATION
              _buildExpandableSection(
                context: context,
                title: S.of(context).application,
                subtitle: 'v1.0.0+2',
                icon: Icons.settings_applications_outlined,
                children: [
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
                    leading: const Icon(Icons.info_outline, color: AppColors.navyBlue),
                    title: Text(S.of(context).aboutApp),
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 32),
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

  Widget _buildExpandableSection({
    required BuildContext context,
    required String title,
    String? subtitle,
    required IconData icon,
    required List<Widget> children,
    bool initiallyExpanded = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: AppColors.navyBlue),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  letterSpacing: 0.5,
                ),
              ),
          ],
        ),
        children: children,
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
              onPressed: () {
                final url = Uri.parse(supportUrl);
                launchUrl(url, mode: LaunchMode.externalApplication).catchError((e) {
                  debugPrint('Error launching url: $e');
                  return false;
                });
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

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).aboutAppTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.of(context).aboutAppDescription,
              textAlign: TextAlign.justify,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).donationInfo,
              style: const TextStyle(fontSize: 12, color: AppColors.grey, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                const String supportUrl = 'https://buycoffee.to/scalebook';
                final url = Uri.parse(supportUrl);
                launchUrl(url, mode: LaunchMode.externalApplication).catchError((e) {
                  debugPrint('Error launching url: $e');
                  return false;
                });
              },
              icon: const Icon(Icons.coffee),
              label: Text(S.of(context).buyMeACoffee),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).close),
          ),
        ],
      ),
    );
  }

  void _showProgressDialog(BuildContext context, String title, Stream<double> progressStream) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreamBuilder<double>(
        stream: progressStream,
        initialData: 0.0,
        builder: (context, snapshot) {
          final progress = snapshot.data ?? 0.0;
          return AlertDialog(
            backgroundColor: AppColors.navyBlue,
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.red),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navyBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'SUCCESS!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(S.of(context).close),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
