// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class SPl extends S {
  SPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'SCALEBOOK';

  @override
  String get welcomeTagline => 'Twój techniczny dziennik budowy i portfolio';

  @override
  String get startAsGuest => 'ZACZNIJ JAKO GOŚĆ';

  @override
  String get login => 'ZALOGUJ SIĘ';

  @override
  String get register => 'STWÓRZ KONTO';

  @override
  String get homeTitle => 'TWÓJ WARSZTAT';

  @override
  String activeProjectsCount(int count, int limit) {
    return '$count / $limit aktywne projekty';
  }

  @override
  String get limitReached => 'LIMIT OSIĄGNIĘTY';

  @override
  String guestLimitMessage(int limit) {
    return 'Jako Gość możesz mieć maksymalnie $limit projekty. Załóż konto, aby zyskać nielimitowane miejsce na warsztacie!';
  }

  @override
  String get deleteProjectTitle => 'USUŃ PROJEKT';

  @override
  String deleteProjectConfirm(String title) {
    return 'Czy na pewno chcesz usunąć projekt \"$title\"? Pamiętaj, że nie będzie możliwości przywrócenia projektu ani jego historii budowy.';
  }

  @override
  String get deletePermanently => 'USUŃ NA ZAWSZE';

  @override
  String get cancel => 'ANULUJ';

  @override
  String get save => 'ZAPISZ';

  @override
  String get edit => 'EDYTUJ';

  @override
  String get delete => 'USUŃ';

  @override
  String get settings => 'USTAWIENIA';

  @override
  String get profile => 'PROFIL';

  @override
  String get modeler => 'Modelarz';

  @override
  String get scalebookProfile => 'Profil ScaleBook';

  @override
  String get dataAndBackup => 'DANE I KOPIA ZAPASOWA';

  @override
  String get exportCollection => 'Eksportuj kolekcję (ZIP)';

  @override
  String get exportCollectionSubtitle =>
      'Kopia zapasowa wszystkich zdjęć i wpisów';

  @override
  String get importCollection => 'Importuj kolekcję (ZIP)';

  @override
  String get importCollectionSuccess =>
      'Kolekcja została zaimportowana pomyślnie!';

  @override
  String get support => 'WSPARCIE';

  @override
  String get rateScaleBook => 'Oceń ScaleBook';

  @override
  String get rateScaleBookSubtitle =>
      'Twoja opinia pomaga mi rozwijać aplikację';

  @override
  String get buyMeACoffee => 'Postaw mi kawę';

  @override
  String get buyMeACoffeeSubtitle => 'Wesprzyj rozwój ScaleBook';

  @override
  String get application => 'APLIKACJA';

  @override
  String get language => 'Język';

  @override
  String get polish => 'Polski';

  @override
  String get english => 'Angielski';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get deleteAccount => 'Usuń konto';

  @override
  String get deleteAccountConfirm =>
      'Czy na pewno chcesz usunąć konto i wszystkie dane? Tej operacji nie można cofnąć.';

  @override
  String get techAuth => 'AUTORYZACJA TECHNICZNA';

  @override
  String get email => 'E-MAIL';

  @override
  String get password => 'HASŁO';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get resetPassword => 'Resetuj hasło';

  @override
  String get resetPasswordTitle => 'Odzyskiwanie hasła';

  @override
  String get resetPasswordDescription =>
      'Podaj swój adres e-mail, aby otrzymać link do zmiany hasła.';

  @override
  String get sendResetLink => 'Wyślij link';

  @override
  String get resetLinkSent =>
      'Link do resetowania hasła został wysłany na Twój e-mail.';

  @override
  String get changePassword => 'Zmień hasło';

  @override
  String get changePasswordTitle => 'Zmiana hasła';

  @override
  String get changePasswordDescription => 'Podaj nowe hasło do swojego konta.';

  @override
  String get newPasswordLabel => 'NOWE HASŁO';

  @override
  String get passwordChangedSuccess => 'Hasło zostało pomyślnie zmienione.';

  @override
  String get required => 'Wymagane';

  @override
  String get notes => 'NOTATKI';

  @override
  String get newNote => 'NOWA NOTATKA';

  @override
  String get editNote => 'EDYTUJ NOTATKĘ';

  @override
  String get noteName => 'NAZWA NOTATKI (WYMAGANE)';

  @override
  String get noteContent => 'TREŚĆ NOTATKI (WYMAGANE)';

  @override
  String get linkOptional => 'LINK (OPCJONALNIE)';

  @override
  String get photosOptional => 'ZDJĘCIA (OPCJONALNIE)';

  @override
  String get saveNote => 'ZAPISZ NOTATKĘ';

  @override
  String get saveChanges => 'ZAPISZ ZMIANY';

  @override
  String get gallery => 'Galeria';

  @override
  String get camera => 'Aparat';

  @override
  String get pulpit => 'Pulpit';

  @override
  String get stash => 'Garderoba';

  @override
  String get showcase => 'Gablota';

  @override
  String get showcaseTitle => 'MOJA GABLOTA';

  @override
  String get searchInNotes => 'SZUKAJ W NOTATKACH...';

  @override
  String get noNotes => 'BRAK NOTATEK';

  @override
  String get noNotesFound => 'NIE ZNALEZIONO NOTATEK';

  @override
  String get addFirstNote => 'Dodaj swoją pierwszą notatkę modelarską!';

  @override
  String get tryChangingSearch => 'Spróbuj zmienić frazę wyszukiwania';

  @override
  String get deleteNoteTitle => 'USUŃ NOTATKĘ';

  @override
  String deleteNoteConfirm(String title) {
    return 'Czy na pewno chcesz usunąć notatkę \"$title\"?';
  }

  @override
  String get noteDetail => 'SZCZEGÓŁY NOTATKI';

  @override
  String get shareNoteAsPng => 'Udostępnij jako grafikę';

  @override
  String myModelingNote(String title) {
    return 'Moja notatka modelarska: $title';
  }

  @override
  String error(String message) {
    return 'Błąd: $message';
  }

  @override
  String get deleteAccountTitle => 'USUŃ KONTO?';

  @override
  String get deletePermanentlyAction => 'USUŃ TRWALE';

  @override
  String errorDeletingAccount(String message) {
    return 'Błąd podczas usuwania konta: $message';
  }

  @override
  String get editProfile => 'EDYTUJ PROFIL';

  @override
  String get firstName => 'IMIĘ';

  @override
  String get statusInProgress => 'W TRAKCIE';

  @override
  String get statusPaused => 'ODŁOŻONE';

  @override
  String get statusFinished => 'GOTOWY';

  @override
  String get statusStash => 'GARDEROBA';

  @override
  String get statusSold => 'SPRZEDANE';

  @override
  String get share => 'UDOSTĘPNIJ';

  @override
  String get newModel => 'NOWY MODEL';

  @override
  String get boxPhotoRequired => 'ZDJĘCIE OPAKOWANIA (WYMAGANE)';

  @override
  String get addToStash => 'DODAJ DO GARDEROBY';

  @override
  String get stashSectionDescription => 'Model trafi do sekcji \"Garderoba\"';

  @override
  String get modelNameLabel => 'NAZWA MODELU';

  @override
  String get scaleLabel => 'SKALA';

  @override
  String get purchaseDate => 'DATA ZAKUPU';

  @override
  String get startDate => 'DATA ROZPOCZĘCIA';

  @override
  String get addToWorkshop => 'DODAJ DO WARSZTATU';

  @override
  String get modelNameRequired => 'Nazwa jest obowiązkowa';

  @override
  String get scaleRequired => 'Skala jest obowiązkowa';

  @override
  String get addPhotoError => 'Dodaj zdjęcie opakowania przed zapisaniem.';

  @override
  String savingError(String message) {
    return 'Błąd podczas zapisywania: $message';
  }

  @override
  String get scaleMatesLinkText => 'Nie masz zdjęcia pudełka? Znajdź je na ';

  @override
  String get demoModeWarning => '⚠️ TRYB DEMO (BRAK KLUCZY API) ⚠️';

  @override
  String get errorUserAlreadyExists =>
      'To konto już istnieje. Wybierz opcję logowania zamiast rejestracji.';

  @override
  String get errorInvalidCredentials =>
      'Błędny adres e-mail lub hasło. Spróbuj ponownie.';

  @override
  String get errorNetworkProblem =>
      'Problem z połączeniem. Sprawdź swoje połączenie z internetem.';

  @override
  String get errorWeakPassword => 'Hasło jest zbyt słabe lub niepoprawne.';

  @override
  String get errorUnexpectedAuth =>
      'Wystąpił nieoczekiwany błąd autoryzacji. Spróbuj ponownie później.';

  @override
  String get deleteStep => 'USUŃ ETAP';

  @override
  String get deleteStepConfirm => 'Czy na pewno chcesz usunąć ten etap budowy?';

  @override
  String get preparingStepPhoto => 'Przygotowywanie zdjęcia etapu...';

  @override
  String get generatingPoster => 'Generowanie plakatu postępów...';

  @override
  String get sharingCollection => 'Uruchamiam udostępnianie...';

  @override
  String myProgressTitle(String title) {
    return 'Moje postępy: $title';
  }

  @override
  String buildStepProgressTitle(String title) {
    return 'Postęp prac: $title';
  }

  @override
  String get addStepDescription => 'Dodaj krótki opis etapu prac.';

  @override
  String errorSaving(String error) {
    return 'Błąd podczas zapisywania: $error';
  }

  @override
  String get editStepLabel => 'EDYTUJ ETAP';

  @override
  String get newBuildStep => 'NOWY ETAP BUDOWY';

  @override
  String get stepDate => 'DATA ETAPU';

  @override
  String get stepDescriptionLabel => 'OPIS ETAPU PRAC';

  @override
  String get stepDescriptionHint => 'Co dziś zrobiono przy modelu?';

  @override
  String get saveStep => 'ZAPISZ ETAP';

  @override
  String get addPhoto => 'DODAJ ZDJĘCIE';

  @override
  String get noteNameLabel => 'NAZWA NOTATKI (WYMAGANE)';

  @override
  String get noteNameHint => 'np. Mieszanie farb do karoserii';

  @override
  String get noteContentLabel => 'TREŚĆ NOTATKI (WYMAGANE)';

  @override
  String get noteContentHint => 'Wpisz swoje uwagi...';

  @override
  String get noteLinkLabel => 'LINK (OPCJONALNIE)';

  @override
  String get noteLinkHint => 'np. https://youtube.com/...';

  @override
  String get notePhotosLabel => 'ZDJĘCIA (OPCJONALNIE)';

  @override
  String get nameRequired => 'Nazwa jest obowiązkowa';

  @override
  String get contentRequired => 'Treść jest obowiązkowa';

  @override
  String get stashTitle => 'GARDEROBA';

  @override
  String get pdfList => 'LISTA PDF';

  @override
  String get generatingPdfCatalog => 'GENEROWANIE KATALOGU PDF...';

  @override
  String get manyPhotosWarning => 'To może chwilę potrwać przy wielu zdjęciach';

  @override
  String get sortByDate => 'Sortuj według daty';

  @override
  String get searchInStash => 'SZUKAJ W GARDEROBIE...';

  @override
  String get noModelsFound => 'NIE ZNALEZIONO MODELI';

  @override
  String modelsInQueue(int count) {
    return '$count MODELE W KOLEJCE';
  }

  @override
  String get stashEmpty => 'TWOJA GARDEROBA JEST PUSTA';

  @override
  String get stashEmptyHint => 'Dodaj modele, które czekają na swoją kolej!';

  @override
  String get startModel => 'ZACZĄĆ MODEL';

  @override
  String get moveToWorkshopHint => 'Przenieś na warsztat z dzisiejszą datą';

  @override
  String get movingToWorkshop => 'Przenoszenie modelu na warsztat...';

  @override
  String get movedToWorkshop => 'Model przeniesiony na warsztat!';

  @override
  String get sold => 'SPRZEDANE';

  @override
  String get removeFromCollectionHint => 'Usuń trwale z kolekcji';

  @override
  String get confirmSale => 'POTWIERDŹ SPRZEDAŻ';

  @override
  String soldConfirmationMessage(String title) {
    return 'Czy na pewno sprzedałeś projekt \"$title\"? Zostanie on usunięty z bazy na zawsze wraz ze wszystkimi zdjęciami.';
  }

  @override
  String get deletingModel => 'Usuwanie modelu...';

  @override
  String get modelDeleted => 'Model został usunięty.';

  @override
  String get soldDeleteAction => 'SPRZEDANE - USUŃ';

  @override
  String criticalError(String error) {
    return 'Błąd krytyczny: $error';
  }

  @override
  String pdfExportError(String error) {
    return 'Błąd eksportu PDF: $error';
  }

  @override
  String get selectProgress => 'WYBIERZ POSTĘPY';

  @override
  String get noBuildSteps => 'BRAK ETAPÓW BUDOWY';

  @override
  String errorPrefix(String error) {
    return 'Błąd: $error';
  }

  @override
  String exportError(String error) {
    return 'Błąd eksportu: $error';
  }

  @override
  String get close => 'ZAMKNIJ';
}
