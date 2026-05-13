import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import 'package:printing/printing.dart';
import '../../../../core/design_system/widgets/cutting_mat_background.dart';
import '../../../../core/design_system/app_colors.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../session/presentation/cubit/session_cubit.dart';
import '../../home/domain/models/model_project.dart';
import '../../home/presentation/cubit/home_cubit.dart';
import '../../home/presentation/cubit/home_state.dart';
import '../../home/ui/widgets/model_card.dart';
import '../../home/ui/add_model_screen.dart';
import '../../session/domain/models/user_session.dart';
import '../../../../core/design_system/widgets/limit_dialog.dart';
import '../../welcome/ui/auth_screen.dart';

import 'widgets/stash_model_list_tile.dart';

class StashScreen extends StatefulWidget {
  const StashScreen({super.key});

  @override
  State<StashScreen> createState() => _StashScreenState();
}

class _StashScreenState extends State<StashScreen> {
  String _searchQuery = '';
  bool _isNewestFirst = true;
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(S.of(context).stashTitle), // L10N
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'Widok listy' : 'Widok siatki',
          ),
          TextButton.icon(
            icon: const Icon(Icons.list_alt, color: Colors.white, size: 20),
            label: Text(S.of(context).pdfList, style: const TextStyle(color: Colors.white, fontSize: 12)),
            onPressed: () async {
              final homeState = context.read<HomeCubit>().state;
              await homeState.maybeMap(
                loaded: (s) async {
                  var projects = s.projects.where((p) => p.status == 'GARDEROBA').toList();
                  
                  if (_searchQuery.isNotEmpty) {
                    projects = projects
                        .where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                        .toList();
                  }
                  projects.sort((a, b) {
                    final dateA = a.createdAt;
                    final dateB = b.createdAt;
                    return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
                  });

                  final session = context.read<SessionCubit>().state;
                  final name = session.displayName;

                  // Show Progress Dialog
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.red),
                          const SizedBox(height: 16),
                          Text(S.of(context).generatingPdfCatalog),
                          const SizedBox(height: 8),
                          Text(S.of(context).manyPhotosWarning, style: const TextStyle(fontSize: 10, color: AppColors.grey)),
                        ],
                      ),
                    ),
                  );

                  try {
                    debugPrint('PDF: Rozpoczynam generowanie bajtów...');
                    final bytes = await PdfExportService.generateStashPdf(
                      modelerName: name,
                      models: projects,
                    );

                    if (context.mounted) {
                      debugPrint('PDF: Bajty gotowe (${bytes.length}). Zamykam dialog...');
                      Navigator.pop(context); // Hide progress dialog
                      
                      // Small delay to let the dialog animation finish
                      await Future.delayed(const Duration(milliseconds: 500));
                      
                      debugPrint('PDF: Wywołuję systemowe udostępnianie...');
                      await Printing.sharePdf(
                        bytes: bytes,
                        filename: 'Garderoba_ScaleBook.pdf',
                      );
                      debugPrint('PDF: Udostępnianie wywołane pomyślnie.');
                    }
                  } catch (e) {
                    debugPrint('PDF: BŁĄD W STASH_SCREEN: $e');
                    if (context.mounted) {
                      // Try to close dialog if it's still there
                      try { Navigator.pop(context); } catch (_) {}
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).pdfExportError(e.toString())),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                orElse: () async {},
              );
            },
          ),
          IconButton(
            icon: Icon(_isNewestFirst ? Icons.south : Icons.north),
            tooltip: S.of(context).sortByDate,
            onPressed: () {
              setState(() {
                _isNewestFirst = !_isNewestFirst;
              });
            },
          ),
        ],
      ),
      body: CuttingMatBackground(
        child: BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return state.maybeMap(
              loaded: (s) {
                // 1. Filter by status
                var projects = s.projects.where((p) => p.status == 'GARDEROBA').toList();

                // 2. Filter by search query
                if (_searchQuery.isNotEmpty) {
                  projects = projects
                      .where((p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // 3. Sort by date
                projects.sort((a, b) {
                  final dateA = a.createdAt;
                  final dateB = b.createdAt;
                  return _isNewestFirst ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
                });

                return _buildContent(context, projects);
              },
              error: (s) => Center(child: Text(s.message)),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
      floatingActionButton: BlocBuilder<SessionCubit, UserSession>(
        builder: (context, session) {
          return FloatingActionButton(
            heroTag: 'stash_fab',
            onPressed: () {
              final count = context.read<HomeCubit>().projectCount;
              final limit = session.limit;

              if (limit != null && count >= limit) {
                showDialog(
                  context: context,
                  builder: (dialogContext) => LimitDialog(
                    title: S.of(context).limitReached,
                    message: S.of(context).guestLimitMessage(limit),
                    actionLabel: S.of(context).register,
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AuthScreen(isRegister: true)),
                      );
                    },
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (childContext) => BlocProvider.value(
                    value: context.read<HomeCubit>(),
                    child: const AddModelScreen(initialIsStash: true),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<dynamic> projects) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Search Field
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: S.of(context).searchInStash,
              prefixIcon: const Icon(Icons.search, color: AppColors.navyBlue),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 16),
          if (projects.isEmpty && _searchQuery.isEmpty)
            _buildEmptyState()
          else if (projects.isEmpty && _searchQuery.isNotEmpty)
            Expanded(
              child: Center(
                child: Text(
                  S.of(context).noModelsFound,
                  style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
                ),
              ),
            )
          else ...[
            Text(
              S.of(context).modelsInQueue(projects.length),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.navyBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isGridView 
                ? GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.0,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final model = projects[index];
                      return GestureDetector(
                        onTap: () => _showActionMenu(context, model),
                        child: ModelCard(
                          title: model.title,
                          scale: model.scale,
                          progress: model.progress,
                          status: model.status,
                          imageUrl: model.mainImageUrl,
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final model = projects[index];
                      return StashModelListTile(
                        title: model.title,
                        scale: model.scale,
                        imageUrl: model.mainImageUrl,
                        onTap: () => _showActionMenu(context, model),
                      );
                    },
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shelves, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            Text(
              S.of(context).stashEmpty,
              style: const TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).stashEmptyHint,
              style: const TextStyle(color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionMenu(BuildContext context, dynamic model) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showModalBottomSheet(
      context: context,
      builder: (modalContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.play_arrow, color: Colors.green),
              title: Text(S.of(context).startModel),
              subtitle: Text(S.of(context).moveToWorkshopHint),
              onTap: () async {
                try {
                  Navigator.pop(modalContext);
                  
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).movingToWorkshop),
                        duration: const Duration(seconds: 1),
                      ),
                    );

                  final updated = (model as ModelProject).copyWith(
                    status: 'WARSZTAT',
                    createdAt: DateTime.now(),
                  );
                  await cubit.updateProject(updated);
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S.of(context).movedToWorkshop)),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(S.of(context).criticalError(e.toString())),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.sell, color: AppColors.red),
              title: Text(S.of(context).sold),
              subtitle: Text(S.of(context).removeFromCollectionHint),
              onTap: () {
                Navigator.pop(modalContext);
                _showSoldConfirmation(context, model.id, model.title);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSoldConfirmation(BuildContext context, String id, String title) {
    final cubit = BlocProvider.of<HomeCubit>(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).confirmSale),
        content: Text(
          S.of(context).soldConfirmationMessage(title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              try {
                Navigator.pop(dialogContext);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.of(context).deletingModel),
                    duration: const Duration(seconds: 1),
                  ),
                );

                await cubit.deleteProject(id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(S.of(context).modelDeleted)),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(S.of(context).criticalError(e.toString())),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            child: Text(S.of(context).soldDeleteAction),
          ),
        ],
      ),
    );
  }
}
