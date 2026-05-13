import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'SCALEBOOK'**
  String get appTitle;

  /// No description provided for @welcomeTagline.
  ///
  /// In pl, this message translates to:
  /// **'Twój techniczny dziennik budowy i portfolio'**
  String get welcomeTagline;

  /// No description provided for @startAsGuest.
  ///
  /// In pl, this message translates to:
  /// **'ZACZNIJ JAKO GOŚĆ'**
  String get startAsGuest;

  /// No description provided for @login.
  ///
  /// In pl, this message translates to:
  /// **'ZALOGUJ SIĘ'**
  String get login;

  /// No description provided for @register.
  ///
  /// In pl, this message translates to:
  /// **'STWÓRZ KONTO'**
  String get register;

  /// No description provided for @homeTitle.
  ///
  /// In pl, this message translates to:
  /// **'TWÓJ WARSZTAT'**
  String get homeTitle;

  /// Liczba aktywnych projektów w stosunku do limitu
  ///
  /// In pl, this message translates to:
  /// **'{count} / {limit} aktywne projekty'**
  String activeProjectsCount(int count, int limit);

  /// No description provided for @limitReached.
  ///
  /// In pl, this message translates to:
  /// **'LIMIT OSIĄGNIĘTY'**
  String get limitReached;

  /// No description provided for @guestLimitMessage.
  ///
  /// In pl, this message translates to:
  /// **'Jako Gość możesz mieć maksymalnie {limit} projekty. Załóż konto, aby zyskać nielimitowane miejsce na warsztacie!'**
  String guestLimitMessage(int limit);

  /// No description provided for @deleteProjectTitle.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ PROJEKT'**
  String get deleteProjectTitle;

  /// No description provided for @deleteProjectConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć projekt \"{title}\"? Pamiętaj, że nie będzie możliwości przywrócenia projektu ani jego historii budowy.'**
  String deleteProjectConfirm(String title);

  /// No description provided for @deletePermanently.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ NA ZAWSZE'**
  String get deletePermanently;

  /// No description provided for @cancel.
  ///
  /// In pl, this message translates to:
  /// **'ANULUJ'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pl, this message translates to:
  /// **'ZAPISZ'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In pl, this message translates to:
  /// **'EDYTUJ'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ'**
  String get delete;

  /// No description provided for @settings.
  ///
  /// In pl, this message translates to:
  /// **'USTAWIENIA'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In pl, this message translates to:
  /// **'PROFIL'**
  String get profile;

  /// No description provided for @modeler.
  ///
  /// In pl, this message translates to:
  /// **'Modelarz'**
  String get modeler;

  /// No description provided for @scalebookProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil ScaleBook'**
  String get scalebookProfile;

  /// No description provided for @dataAndBackup.
  ///
  /// In pl, this message translates to:
  /// **'DANE I KOPIA ZAPASOWA'**
  String get dataAndBackup;

  /// No description provided for @exportCollection.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj kolekcję (ZIP)'**
  String get exportCollection;

  /// No description provided for @exportCollectionSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Kopia zapasowa wszystkich zdjęć i wpisów'**
  String get exportCollectionSubtitle;

  /// No description provided for @importCollection.
  ///
  /// In pl, this message translates to:
  /// **'Importuj kolekcję (ZIP)'**
  String get importCollection;

  /// No description provided for @importCollectionSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Kolekcja została zaimportowana pomyślnie!'**
  String get importCollectionSuccess;

  /// No description provided for @support.
  ///
  /// In pl, this message translates to:
  /// **'WSPARCIE'**
  String get support;

  /// No description provided for @rateScaleBook.
  ///
  /// In pl, this message translates to:
  /// **'Oceń ScaleBook'**
  String get rateScaleBook;

  /// No description provided for @rateScaleBookSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Twoja opinia pomaga mi rozwijać aplikację'**
  String get rateScaleBookSubtitle;

  /// No description provided for @buyMeACoffee.
  ///
  /// In pl, this message translates to:
  /// **'Postaw mi kawę'**
  String get buyMeACoffee;

  /// No description provided for @buyMeACoffeeSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wesprzyj rozwój ScaleBook'**
  String get buyMeACoffeeSubtitle;

  /// No description provided for @application.
  ///
  /// In pl, this message translates to:
  /// **'APLIKACJA'**
  String get application;

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get language;

  /// No description provided for @polish.
  ///
  /// In pl, this message translates to:
  /// **'Polski'**
  String get polish;

  /// No description provided for @english.
  ///
  /// In pl, this message translates to:
  /// **'Angielski'**
  String get english;

  /// No description provided for @logout.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In pl, this message translates to:
  /// **'Usuń konto'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć konto i wszystkie dane? Tej operacji nie można cofnąć.'**
  String get deleteAccountConfirm;

  /// No description provided for @privacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka Prywatności'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In pl, this message translates to:
  /// **'Warunki Użytkowania'**
  String get termsOfUse;

  /// No description provided for @legal.
  ///
  /// In pl, this message translates to:
  /// **'PRAWNE'**
  String get legal;

  /// No description provided for @techAuth.
  ///
  /// In pl, this message translates to:
  /// **'AUTORYZACJA UŻYTKOWNIKA'**
  String get techAuth;

  /// No description provided for @email.
  ///
  /// In pl, this message translates to:
  /// **'E-MAIL'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pl, this message translates to:
  /// **'HASŁO'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In pl, this message translates to:
  /// **'Zapomniałeś hasła?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In pl, this message translates to:
  /// **'Resetuj hasło'**
  String get resetPassword;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In pl, this message translates to:
  /// **'Odzyskiwanie hasła'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In pl, this message translates to:
  /// **'Podaj swój adres e-mail, aby otrzymać link do zmiany hasła.'**
  String get resetPasswordDescription;

  /// No description provided for @sendResetLink.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In pl, this message translates to:
  /// **'Kod lub link do resetowania hasła został wysłany na Twój e-mail.'**
  String get resetLinkSent;

  /// No description provided for @resetCode.
  ///
  /// In pl, this message translates to:
  /// **'KOD Z WIADOMOŚCI E-MAIL'**
  String get resetCode;

  /// No description provided for @verifyAndReset.
  ///
  /// In pl, this message translates to:
  /// **'ZWERYFIKUJ I ZMIEŃ HASŁO'**
  String get verifyAndReset;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Hasło zostało zmienione. Możesz się teraz zalogować.'**
  String get passwordResetSuccess;

  /// No description provided for @changePassword.
  ///
  /// In pl, this message translates to:
  /// **'Zmień hasło'**
  String get changePassword;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zmiana hasła'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordDescription.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nowe hasło do swojego konta.'**
  String get changePasswordDescription;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pl, this message translates to:
  /// **'NOWE HASŁO'**
  String get newPasswordLabel;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Hasło zostało pomyślnie zmienione.'**
  String get passwordChangedSuccess;

  /// No description provided for @required.
  ///
  /// In pl, this message translates to:
  /// **'Wymagane'**
  String get required;

  /// No description provided for @notes.
  ///
  /// In pl, this message translates to:
  /// **'NOTATKI'**
  String get notes;

  /// No description provided for @newNote.
  ///
  /// In pl, this message translates to:
  /// **'NOWA NOTATKA'**
  String get newNote;

  /// No description provided for @editNote.
  ///
  /// In pl, this message translates to:
  /// **'EDYTUJ NOTATKĘ'**
  String get editNote;

  /// No description provided for @noteName.
  ///
  /// In pl, this message translates to:
  /// **'NAZWA NOTATKI (WYMAGANE)'**
  String get noteName;

  /// No description provided for @noteContent.
  ///
  /// In pl, this message translates to:
  /// **'TREŚĆ NOTATKI (WYMAGANE)'**
  String get noteContent;

  /// No description provided for @linkOptional.
  ///
  /// In pl, this message translates to:
  /// **'LINK (OPCJONALNIE)'**
  String get linkOptional;

  /// No description provided for @photosOptional.
  ///
  /// In pl, this message translates to:
  /// **'ZDJĘCIA (OPCJONALNIE)'**
  String get photosOptional;

  /// No description provided for @saveNote.
  ///
  /// In pl, this message translates to:
  /// **'ZAPISZ NOTATKĘ'**
  String get saveNote;

  /// No description provided for @saveChanges.
  ///
  /// In pl, this message translates to:
  /// **'ZAPISZ ZMIANY'**
  String get saveChanges;

  /// No description provided for @gallery.
  ///
  /// In pl, this message translates to:
  /// **'Galeria'**
  String get gallery;

  /// No description provided for @camera.
  ///
  /// In pl, this message translates to:
  /// **'Aparat'**
  String get camera;

  /// No description provided for @pulpit.
  ///
  /// In pl, this message translates to:
  /// **'Pulpit'**
  String get pulpit;

  /// No description provided for @stash.
  ///
  /// In pl, this message translates to:
  /// **'Garderoba'**
  String get stash;

  /// No description provided for @showcase.
  ///
  /// In pl, this message translates to:
  /// **'Gablota'**
  String get showcase;

  /// No description provided for @showcaseTitle.
  ///
  /// In pl, this message translates to:
  /// **'MOJA GABLOTA'**
  String get showcaseTitle;

  /// No description provided for @searchInNotes.
  ///
  /// In pl, this message translates to:
  /// **'SZUKAJ W NOTATKACH...'**
  String get searchInNotes;

  /// No description provided for @noNotes.
  ///
  /// In pl, this message translates to:
  /// **'BRAK NOTATEK'**
  String get noNotes;

  /// No description provided for @noNotesFound.
  ///
  /// In pl, this message translates to:
  /// **'NIE ZNALEZIONO NOTATEK'**
  String get noNotesFound;

  /// No description provided for @addFirstNote.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj swoją pierwszą notatkę modelarską!'**
  String get addFirstNote;

  /// No description provided for @tryChangingSearch.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj zmienić frazę wyszukiwania'**
  String get tryChangingSearch;

  /// No description provided for @deleteNoteTitle.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ NOTATKĘ'**
  String get deleteNoteTitle;

  /// No description provided for @deleteNoteConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć notatkę \"{title}\"?'**
  String deleteNoteConfirm(String title);

  /// No description provided for @noteDetail.
  ///
  /// In pl, this message translates to:
  /// **'SZCZEGÓŁY NOTATKI'**
  String get noteDetail;

  /// No description provided for @shareNoteAsPng.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij jako grafikę'**
  String get shareNoteAsPng;

  /// No description provided for @myModelingNote.
  ///
  /// In pl, this message translates to:
  /// **'Moja notatka modelarska: {title}'**
  String myModelingNote(String title);

  /// No description provided for @error.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {message}'**
  String error(String message);

  /// No description provided for @deleteAccountTitle.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ KONTO?'**
  String get deleteAccountTitle;

  /// No description provided for @deletePermanentlyAction.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ TRWALE'**
  String get deletePermanentlyAction;

  /// No description provided for @errorDeletingAccount.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas usuwania konta: {message}'**
  String errorDeletingAccount(String message);

  /// No description provided for @editProfile.
  ///
  /// In pl, this message translates to:
  /// **'EDYTUJ PROFIL'**
  String get editProfile;

  /// No description provided for @firstName.
  ///
  /// In pl, this message translates to:
  /// **'IMIĘ'**
  String get firstName;

  /// No description provided for @statusInProgress.
  ///
  /// In pl, this message translates to:
  /// **'W TRAKCIE'**
  String get statusInProgress;

  /// No description provided for @statusPaused.
  ///
  /// In pl, this message translates to:
  /// **'ODŁOŻONE'**
  String get statusPaused;

  /// No description provided for @statusFinished.
  ///
  /// In pl, this message translates to:
  /// **'GOTOWY'**
  String get statusFinished;

  /// No description provided for @congratulations.
  ///
  /// In pl, this message translates to:
  /// **'GRATULACJE!'**
  String get congratulations;

  /// No description provided for @projectFinishedMessage.
  ///
  /// In pl, this message translates to:
  /// **'Twój projekt został ukończony i przeniesiony z warsztatu do Twojej Gabloty! Pamiętaj, aby dodać tam zdjęcie końcowe gotowego modelu.'**
  String get projectFinishedMessage;

  /// No description provided for @backToWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'WRÓĆ NA WARSZTAT'**
  String get backToWorkshop;

  /// No description provided for @statusStash.
  ///
  /// In pl, this message translates to:
  /// **'GARDEROBA'**
  String get statusStash;

  /// No description provided for @statusSold.
  ///
  /// In pl, this message translates to:
  /// **'SPRZEDANE'**
  String get statusSold;

  /// No description provided for @share.
  ///
  /// In pl, this message translates to:
  /// **'UDOSTĘPNIJ'**
  String get share;

  /// No description provided for @newModel.
  ///
  /// In pl, this message translates to:
  /// **'NOWY MODEL'**
  String get newModel;

  /// No description provided for @boxPhotoRequired.
  ///
  /// In pl, this message translates to:
  /// **'ZDJĘCIE OPAKOWANIA (WYMAGANE)'**
  String get boxPhotoRequired;

  /// No description provided for @addToStash.
  ///
  /// In pl, this message translates to:
  /// **'DODAJ DO GARDEROBY'**
  String get addToStash;

  /// No description provided for @stashSectionDescription.
  ///
  /// In pl, this message translates to:
  /// **'Model trafi do sekcji \"Garderoba\"'**
  String get stashSectionDescription;

  /// No description provided for @modelNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'NAZWA MODELU'**
  String get modelNameLabel;

  /// No description provided for @scaleLabel.
  ///
  /// In pl, this message translates to:
  /// **'SKALA'**
  String get scaleLabel;

  /// No description provided for @purchaseDate.
  ///
  /// In pl, this message translates to:
  /// **'DATA ZAKUPU'**
  String get purchaseDate;

  /// No description provided for @startDate.
  ///
  /// In pl, this message translates to:
  /// **'DATA ROZPOCZĘCIA'**
  String get startDate;

  /// No description provided for @addToWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'DODAJ DO WARSZTATU'**
  String get addToWorkshop;

  /// No description provided for @modelNameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa jest obowiązkowa'**
  String get modelNameRequired;

  /// No description provided for @scaleRequired.
  ///
  /// In pl, this message translates to:
  /// **'Skala jest obowiązkowa'**
  String get scaleRequired;

  /// No description provided for @addPhotoError.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj zdjęcie opakowania przed zapisaniem.'**
  String get addPhotoError;

  /// No description provided for @savingError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas zapisywania: {message}'**
  String savingError(String message);

  /// No description provided for @scaleMatesLinkText.
  ///
  /// In pl, this message translates to:
  /// **'Nie masz zdjęcia pudełka? Znajdź je na '**
  String get scaleMatesLinkText;

  /// No description provided for @demoModeWarning.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ TRYB DEMO (BRAK KLUCZY API) ⚠️'**
  String get demoModeWarning;

  /// No description provided for @errorUserAlreadyExists.
  ///
  /// In pl, this message translates to:
  /// **'To konto już istnieje. Wybierz opcję logowania zamiast rejestracji.'**
  String get errorUserAlreadyExists;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In pl, this message translates to:
  /// **'Błędny adres e-mail lub hasło. Spróbuj ponownie.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorNetworkProblem.
  ///
  /// In pl, this message translates to:
  /// **'Problem z połączeniem. Sprawdź swoje połączenie z internetem.'**
  String get errorNetworkProblem;

  /// No description provided for @errorWeakPassword.
  ///
  /// In pl, this message translates to:
  /// **'Hasło jest zbyt słabe lub niepoprawne.'**
  String get errorWeakPassword;

  /// No description provided for @errorUnexpectedAuth.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił nieoczekiwany błąd autoryzacji. Spróbuj ponownie później.'**
  String get errorUnexpectedAuth;

  /// No description provided for @deleteStep.
  ///
  /// In pl, this message translates to:
  /// **'USUŃ ETAP'**
  String get deleteStep;

  /// No description provided for @deleteStepConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć ten etap budowy?'**
  String get deleteStepConfirm;

  /// No description provided for @preparingStepPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Przygotowywanie zdjęcia etapu...'**
  String get preparingStepPhoto;

  /// No description provided for @generatingPoster.
  ///
  /// In pl, this message translates to:
  /// **'Generowanie plakatu postępów...'**
  String get generatingPoster;

  /// No description provided for @sharingCollection.
  ///
  /// In pl, this message translates to:
  /// **'Uruchamiam udostępnianie...'**
  String get sharingCollection;

  /// No description provided for @myProgressTitle.
  ///
  /// In pl, this message translates to:
  /// **'Moje postępy: {title}'**
  String myProgressTitle(String title);

  /// No description provided for @buildStepProgressTitle.
  ///
  /// In pl, this message translates to:
  /// **'Postęp prac: {title}'**
  String buildStepProgressTitle(String title);

  /// No description provided for @addStepDescription.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj krótki opis etapu prac.'**
  String get addStepDescription;

  /// No description provided for @errorSaving.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas zapisywania: {error}'**
  String errorSaving(String error);

  /// No description provided for @editStepLabel.
  ///
  /// In pl, this message translates to:
  /// **'EDYTUJ ETAP'**
  String get editStepLabel;

  /// No description provided for @newBuildStep.
  ///
  /// In pl, this message translates to:
  /// **'NOWY ETAP BUDOWY'**
  String get newBuildStep;

  /// No description provided for @stepDate.
  ///
  /// In pl, this message translates to:
  /// **'DATA ETAPU'**
  String get stepDate;

  /// No description provided for @stepDescriptionLabel.
  ///
  /// In pl, this message translates to:
  /// **'OPIS ETAPU PRAC'**
  String get stepDescriptionLabel;

  /// No description provided for @stepDescriptionHint.
  ///
  /// In pl, this message translates to:
  /// **'Co dziś zrobiono przy modelu?'**
  String get stepDescriptionHint;

  /// No description provided for @saveStep.
  ///
  /// In pl, this message translates to:
  /// **'ZAPISZ ETAP'**
  String get saveStep;

  /// No description provided for @addPhoto.
  ///
  /// In pl, this message translates to:
  /// **'DODAJ ZDJĘCIE'**
  String get addPhoto;

  /// No description provided for @noteNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'NAZWA NOTATKI (WYMAGANE)'**
  String get noteNameLabel;

  /// No description provided for @noteNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Mieszanie farb do karoserii'**
  String get noteNameHint;

  /// No description provided for @noteContentLabel.
  ///
  /// In pl, this message translates to:
  /// **'TREŚĆ NOTATKI (WYMAGANE)'**
  String get noteContentLabel;

  /// No description provided for @noteContentHint.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz swoje uwagi...'**
  String get noteContentHint;

  /// No description provided for @noteLinkLabel.
  ///
  /// In pl, this message translates to:
  /// **'LINK (OPCJONALNIE)'**
  String get noteLinkLabel;

  /// No description provided for @noteLinkHint.
  ///
  /// In pl, this message translates to:
  /// **'np. https://youtube.com/...'**
  String get noteLinkHint;

  /// No description provided for @notePhotosLabel.
  ///
  /// In pl, this message translates to:
  /// **'ZDJĘCIA (OPCJONALNIE)'**
  String get notePhotosLabel;

  /// No description provided for @nameRequired.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa jest obowiązkowa'**
  String get nameRequired;

  /// No description provided for @contentRequired.
  ///
  /// In pl, this message translates to:
  /// **'Treść jest obowiązkowa'**
  String get contentRequired;

  /// No description provided for @stashTitle.
  ///
  /// In pl, this message translates to:
  /// **'GARDEROBA'**
  String get stashTitle;

  /// No description provided for @pdfList.
  ///
  /// In pl, this message translates to:
  /// **'LISTA PDF'**
  String get pdfList;

  /// No description provided for @generatingPdfCatalog.
  ///
  /// In pl, this message translates to:
  /// **'GENEROWANIE KATALOGU PDF...'**
  String get generatingPdfCatalog;

  /// No description provided for @manyPhotosWarning.
  ///
  /// In pl, this message translates to:
  /// **'To może chwilę potrwać przy wielu zdjęciach'**
  String get manyPhotosWarning;

  /// No description provided for @sortByDate.
  ///
  /// In pl, this message translates to:
  /// **'Sortuj według daty'**
  String get sortByDate;

  /// No description provided for @sortByStatus.
  ///
  /// In pl, this message translates to:
  /// **'Sortuj według statusu'**
  String get sortByStatus;

  /// No description provided for @searchInStash.
  ///
  /// In pl, this message translates to:
  /// **'SZUKAJ W GARDEROBIE...'**
  String get searchInStash;

  /// No description provided for @noModelsFound.
  ///
  /// In pl, this message translates to:
  /// **'NIE ZNALEZIONO MODELI'**
  String get noModelsFound;

  /// No description provided for @modelsInQueue.
  ///
  /// In pl, this message translates to:
  /// **'{count} MODELE W KOLEJCE'**
  String modelsInQueue(int count);

  /// No description provided for @stashEmpty.
  ///
  /// In pl, this message translates to:
  /// **'TWOJA GARDEROBA JEST PUSTA'**
  String get stashEmpty;

  /// No description provided for @stashEmptyHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj modele, które czekają na swoją kolej!'**
  String get stashEmptyHint;

  /// No description provided for @startModel.
  ///
  /// In pl, this message translates to:
  /// **'ZACZĄĆ MODEL'**
  String get startModel;

  /// No description provided for @moveToWorkshopHint.
  ///
  /// In pl, this message translates to:
  /// **'Przenieś na warsztat z dzisiejszą datą'**
  String get moveToWorkshopHint;

  /// No description provided for @movingToWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'Przenoszenie modelu na warsztat...'**
  String get movingToWorkshop;

  /// No description provided for @movedToWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'Model przeniesiony na warsztat!'**
  String get movedToWorkshop;

  /// No description provided for @sold.
  ///
  /// In pl, this message translates to:
  /// **'SPRZEDANE'**
  String get sold;

  /// No description provided for @removeFromCollectionHint.
  ///
  /// In pl, this message translates to:
  /// **'Usuń trwale z kolekcji'**
  String get removeFromCollectionHint;

  /// No description provided for @confirmSale.
  ///
  /// In pl, this message translates to:
  /// **'POTWIERDŹ SPRZEDAŻ'**
  String get confirmSale;

  /// No description provided for @soldConfirmationMessage.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno sprzedałeś projekt \"{title}\"? Zostanie on usunięty z bazy na zawsze wraz ze wszystkimi zdjęciami.'**
  String soldConfirmationMessage(String title);

  /// No description provided for @deletingModel.
  ///
  /// In pl, this message translates to:
  /// **'Usuwanie modelu...'**
  String get deletingModel;

  /// No description provided for @modelDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Model został usunięty.'**
  String get modelDeleted;

  /// No description provided for @soldDeleteAction.
  ///
  /// In pl, this message translates to:
  /// **'SPRZEDANE - USUŃ'**
  String get soldDeleteAction;

  /// No description provided for @criticalError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd krytyczny: {error}'**
  String criticalError(String error);

  /// No description provided for @pdfExportError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd eksportu PDF: {error}'**
  String pdfExportError(String error);

  /// No description provided for @selectProgress.
  ///
  /// In pl, this message translates to:
  /// **'WYBIERZ POSTĘPY'**
  String get selectProgress;

  /// No description provided for @noBuildSteps.
  ///
  /// In pl, this message translates to:
  /// **'BRAK ETAPÓW BUDOWY'**
  String get noBuildSteps;

  /// No description provided for @errorPrefix.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String errorPrefix(String error);

  /// No description provided for @exportError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd eksportu: {error}'**
  String exportError(Object error);

  /// No description provided for @close.
  ///
  /// In pl, this message translates to:
  /// **'ZAMKNIJ'**
  String get close;

  /// No description provided for @changePhoto.
  ///
  /// In pl, this message translates to:
  /// **'ZMIEŃ ZDJĘCIE'**
  String get changePhoto;

  /// No description provided for @editProject.
  ///
  /// In pl, this message translates to:
  /// **'EDYTUJ PROJEKT'**
  String get editProject;

  /// No description provided for @buildStepsCount.
  ///
  /// In pl, this message translates to:
  /// **'{count} etapów'**
  String buildStepsCount(int count);

  /// No description provided for @backingUp.
  ///
  /// In pl, this message translates to:
  /// **'TWORZENIE KOPII ZAPASOWEJ...'**
  String get backingUp;

  /// No description provided for @restoring.
  ///
  /// In pl, this message translates to:
  /// **'PRZYWRACANIE DANYCH...'**
  String get restoring;

  /// No description provided for @addProjectDialogTitle.
  ///
  /// In pl, this message translates to:
  /// **'CO CHCESZ ZROBIĆ?'**
  String get addProjectDialogTitle;

  /// No description provided for @addNewProjectOption.
  ///
  /// In pl, this message translates to:
  /// **'DODAJ NOWY MODEL'**
  String get addNewProjectOption;

  /// No description provided for @chooseFromStashOption.
  ///
  /// In pl, this message translates to:
  /// **'WYBIERZ Z GARDEROBY'**
  String get chooseFromStashOption;

  /// No description provided for @selectFromStashTitle.
  ///
  /// In pl, this message translates to:
  /// **'WYBIERZ MODEL'**
  String get selectFromStashTitle;

  /// No description provided for @noModelsInStash.
  ///
  /// In pl, this message translates to:
  /// **'GARDEROBA JEST PUSTA'**
  String get noModelsInStash;

  /// No description provided for @movingFromStashToWorkshop.
  ///
  /// In pl, this message translates to:
  /// **'Przenoszenie do warsztatu...'**
  String get movingFromStashToWorkshop;

  /// No description provided for @aboutApp.
  ///
  /// In pl, this message translates to:
  /// **'O aplikacji'**
  String get aboutApp;

  /// No description provided for @aboutAppTitle.
  ///
  /// In pl, this message translates to:
  /// **'O SCALEBOOK'**
  String get aboutAppTitle;

  /// No description provided for @aboutAppDescription.
  ///
  /// In pl, this message translates to:
  /// **'ScaleBook to techniczny dziennik budowy stworzony przez pasjonata dla pasjonatów. Aplikacja pomaga śledzić postępy prac nad modelami, przechowywać dokumentację fotograficzną oraz dzielić się gotowymi projektami z innymi.'**
  String get aboutAppDescription;

  /// No description provided for @donationInfo.
  ///
  /// In pl, this message translates to:
  /// **'Projekt jest rozwijany pro bono i utrzymywany dzięki dobrowolnym datkom użytkowników. Twoje wsparcie pozwala na pokrycie kosztów serwerów i dalszy rozwój nowych funkcji.'**
  String get donationInfo;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return SEn();
    case 'pl':
      return SPl();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
