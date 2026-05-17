import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:scalebook/l10n/app_localizations.dart';
import '../../../../core/design_system/app_colors.dart';

class CoffeeDonationModal extends StatelessWidget {
  const CoffeeDonationModal({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.coffee, color: AppColors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.of(context).coffeeModalTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            S.of(context).coffeeModalDescription,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            S.of(context).coffeeModalLater,
            style: const TextStyle(color: AppColors.grey),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            const String supportUrl = 'https://buycoffee.to/scalebook';
            final url = Uri.parse(supportUrl);
            
            try {
              // Zamknij okienko przed otwarciem linku
              if (context.mounted) Navigator.pop(context);
              // Spróbuj otworzyć z domyślnymi ustawieniami systemu
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } catch (e) {
              debugPrint('Launch URL error: $e');
            }
          },
          icon: const Icon(Icons.favorite),
          label: Text(S.of(context).coffeeModalButton),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
