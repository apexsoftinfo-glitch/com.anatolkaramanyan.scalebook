import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Serwis odpowiedzialny za logikę proszenia o ocenę aplikacji.
class ReviewService {
  static const String _reviewRequestedKey = 'review_requested';
  static const String _projectsCreatedCountKey = 'projects_created_count';
  
  final InAppReview _inAppReview = InAppReview.instance;

  /// Zapisuje fakt utworzenia nowego projektu i sprawdza, czy to moment na poproszenie o ocenę.
  Future<void> recordProjectCreated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final count = (prefs.getInt(_projectsCreatedCountKey) ?? 0) + 1;
      await prefs.setInt(_projectsCreatedCountKey, count);
      
      debugPrint('[ReviewService] Liczba utworzonych projektów: $count');
      
      // Prosimy o ocenę przy 3. utworzonym projekcie
      if (count == 3) {
        await requestReview();
      }
    } catch (e) {
      debugPrint('[ReviewService] Błąd podczas recordProjectCreated: $e');
    }
  }

  /// Wyświetla systemowy prompt o ocenę, jeśli jest dostępny i nie był jeszcze wyświetlany.
  Future<void> requestReview({bool force = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyRequested = prefs.getBool(_reviewRequestedKey) ?? false;
      
      if (!alreadyRequested || force) {
        debugPrint('[ReviewService] Próba wyświetlenia promptu o ocenę...');
        if (await _inAppReview.isAvailable()) {
          await _inAppReview.requestReview();
          if (!force) {
            await prefs.setBool(_reviewRequestedKey, true);
          }
        } else {
          debugPrint('[ReviewService] Prompt o ocenę nie jest dostępny na tym urządzeniu/platformie.');
        }
      }
    } catch (e) {
      debugPrint('[ReviewService] Błąd podczas requestReview: $e');
    }
  }

  /// Otwiera sklep (App Store / Google Play) bezpośrednio na stronie aplikacji.
  Future<void> openStoreListing() async {
    try {
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.openStoreListing();
      }
    } catch (e) {
      debugPrint('[ReviewService] Błąd podczas openStoreListing: $e');
    }
  }
}
