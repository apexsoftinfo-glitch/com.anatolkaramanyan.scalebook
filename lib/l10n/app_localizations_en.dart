// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SCALEBOOK';

  @override
  String get welcomeTagline => 'Your technical build log and portfolio';

  @override
  String get startAsGuest => 'START AS GUEST';

  @override
  String get login => 'LOGIN';

  @override
  String get register => 'CREATE ACCOUNT';

  @override
  String get homeTitle => 'YOUR WORKBENCH';

  @override
  String activeProjectsCount(int count, int limit) {
    return '$count / $limit active projects';
  }

  @override
  String get limitReached => 'LIMIT REACHED';

  @override
  String guestLimitMessage(int limit) {
    return 'As a Guest you can have up to $limit projects. Create an account to get unlimited workbench space!';
  }

  @override
  String get deleteProjectTitle => 'DELETE PROJECT';

  @override
  String deleteProjectConfirm(String title) {
    return 'Are you sure you want to delete project \"$title\"? Remember that you won\'t be able to restore the project or its build history.';
  }

  @override
  String get deletePermanently => 'DELETE PERMANENTLY';

  @override
  String get cancel => 'CANCEL';

  @override
  String get save => 'SAVE';

  @override
  String get edit => 'EDIT';

  @override
  String get delete => 'DELETE';

  @override
  String get settings => 'SETTINGS';

  @override
  String get profile => 'PROFILE';

  @override
  String get modeler => 'Modeler';

  @override
  String get scalebookProfile => 'ScaleBook Profile';

  @override
  String get dataAndBackup => 'DATA & BACKUP';

  @override
  String get exportCollection => 'Export collection (ZIP)';

  @override
  String get exportCollectionSubtitle => 'Backup of all photos and entries';

  @override
  String get importCollection => 'Import collection (ZIP)';

  @override
  String get importCollectionSuccess => 'Collection imported successfully!';

  @override
  String get support => 'SUPPORT';

  @override
  String get rateScaleBook => 'Rate ScaleBook';

  @override
  String get rateScaleBookSubtitle => 'Your feedback helps me develop the app';

  @override
  String get buyMeACoffee => 'Buy me a coffee';

  @override
  String get buyMeACoffeeSubtitle => 'Support ScaleBook development';

  @override
  String get application => 'APPLICATION';

  @override
  String get language => 'Language';

  @override
  String get polish => 'Polish';

  @override
  String get english => 'English';

  @override
  String get logout => 'Logout';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account and all data? This operation cannot be undone.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get legal => 'LEGAL';

  @override
  String get techAuth => 'TECHNICAL AUTHORIZATION';

  @override
  String get email => 'E-MAIL';

  @override
  String get password => 'PASSWORD';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get resetPassword => 'Reset password';

  @override
  String get resetPasswordTitle => 'Recover password';

  @override
  String get resetPasswordDescription =>
      'Enter your email address to receive a password reset link.';

  @override
  String get sendResetLink => 'Send link';

  @override
  String get resetLinkSent =>
      'A password reset link has been sent to your email.';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordTitle => 'Change password';

  @override
  String get changePasswordDescription =>
      'Enter a new password for your account.';

  @override
  String get newPasswordLabel => 'NEW PASSWORD';

  @override
  String get passwordChangedSuccess =>
      'Password has been changed successfully.';

  @override
  String get required => 'Required';

  @override
  String get notes => 'NOTES';

  @override
  String get newNote => 'NEW NOTE';

  @override
  String get editNote => 'EDIT NOTE';

  @override
  String get noteName => 'NOTE NAME (REQUIRED)';

  @override
  String get noteContent => 'NOTE CONTENT (REQUIRED)';

  @override
  String get linkOptional => 'LINK (OPTIONAL)';

  @override
  String get photosOptional => 'PHOTOS (OPTIONAL)';

  @override
  String get saveNote => 'SAVE NOTE';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get gallery => 'Gallery';

  @override
  String get camera => 'Camera';

  @override
  String get pulpit => 'Workbench';

  @override
  String get stash => 'Stash';

  @override
  String get showcase => 'Showcase';

  @override
  String get showcaseTitle => 'MY SHOWCASE';

  @override
  String get searchInNotes => 'SEARCH IN NOTES...';

  @override
  String get noNotes => 'NO NOTES';

  @override
  String get noNotesFound => 'NO NOTES FOUND';

  @override
  String get addFirstNote => 'Add your first modeling note!';

  @override
  String get tryChangingSearch => 'Try changing your search query';

  @override
  String get deleteNoteTitle => 'DELETE NOTE';

  @override
  String deleteNoteConfirm(String title) {
    return 'Are you sure you want to delete note \"$title\"?';
  }

  @override
  String get noteDetail => 'NOTE DETAILS';

  @override
  String get shareNoteAsPng => 'Share as image';

  @override
  String myModelingNote(String title) {
    return 'My modeling note: $title';
  }

  @override
  String error(String message) {
    return 'Error: $message';
  }

  @override
  String get deleteAccountTitle => 'DELETE ACCOUNT?';

  @override
  String get deletePermanentlyAction => 'DELETE PERMANENTLY';

  @override
  String errorDeletingAccount(String message) {
    return 'Error deleting account: $message';
  }

  @override
  String get editProfile => 'EDIT PROFILE';

  @override
  String get firstName => 'FIRST NAME';

  @override
  String get statusInProgress => 'IN PROGRESS';

  @override
  String get statusPaused => 'PAUSED';

  @override
  String get statusFinished => 'FINISHED';

  @override
  String get statusStash => 'STASH';

  @override
  String get statusSold => 'SOLD';

  @override
  String get share => 'SHARE';

  @override
  String get newModel => 'NEW MODEL';

  @override
  String get boxPhotoRequired => 'BOX PHOTO (REQUIRED)';

  @override
  String get addToStash => 'ADD TO STASH';

  @override
  String get stashSectionDescription =>
      'Model will go to the \"Stash\" section';

  @override
  String get modelNameLabel => 'MODEL NAME';

  @override
  String get scaleLabel => 'SCALE';

  @override
  String get purchaseDate => 'PURCHASE DATE';

  @override
  String get startDate => 'START DATE';

  @override
  String get addToWorkshop => 'ADD TO WORKSHOP';

  @override
  String get modelNameRequired => 'Name is required';

  @override
  String get scaleRequired => 'Scale is required';

  @override
  String get addPhotoError => 'Add a box photo before saving.';

  @override
  String savingError(String message) {
    return 'Error while saving: $message';
  }

  @override
  String get scaleMatesLinkText => 'Don\'t have a box photo? Find it on ';

  @override
  String get demoModeWarning => '⚠️ DEMO MODE (NO API KEYS) ⚠️';

  @override
  String get errorUserAlreadyExists =>
      'Account already exists. Try logging in instead.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password. Try again.';

  @override
  String get errorNetworkProblem =>
      'Connection problem. Check your internet connection.';

  @override
  String get errorWeakPassword => 'Password is too weak or incorrect.';

  @override
  String get errorUnexpectedAuth =>
      'Unexpected authorization error. Try again later.';

  @override
  String get deleteStep => 'DELETE STEP';

  @override
  String get deleteStepConfirm =>
      'Are you sure you want to delete this build step?';

  @override
  String get preparingStepPhoto => 'Preparing step photo...';

  @override
  String get generatingPoster => 'Generating progress poster...';

  @override
  String get sharingCollection => 'Launching share...';

  @override
  String myProgressTitle(String title) {
    return 'My progress: $title';
  }

  @override
  String buildStepProgressTitle(String title) {
    return 'Build progress: $title';
  }

  @override
  String get addStepDescription => 'Add a short description of the build step.';

  @override
  String errorSaving(String error) {
    return 'Error saving: $error';
  }

  @override
  String get editStepLabel => 'EDIT STEP';

  @override
  String get newBuildStep => 'NEW BUILD STEP';

  @override
  String get stepDate => 'STEP DATE';

  @override
  String get stepDescriptionLabel => 'BUILD STEP DESCRIPTION';

  @override
  String get stepDescriptionHint => 'What was done on the model today?';

  @override
  String get saveStep => 'SAVE STEP';

  @override
  String get addPhoto => 'ADD PHOTO';

  @override
  String get noteNameLabel => 'NOTE NAME (REQUIRED)';

  @override
  String get noteNameHint => 'e.g. Mixing paint for car body';

  @override
  String get noteContentLabel => 'NOTE CONTENT (REQUIRED)';

  @override
  String get noteContentHint => 'Enter your notes...';

  @override
  String get noteLinkLabel => 'LINK (OPTIONAL)';

  @override
  String get noteLinkHint => 'e.g. https://youtube.com/...';

  @override
  String get notePhotosLabel => 'PHOTOS (OPTIONAL)';

  @override
  String get nameRequired => 'Name is required';

  @override
  String get contentRequired => 'Content is required';

  @override
  String get stashTitle => 'STASH';

  @override
  String get pdfList => 'PDF LIST';

  @override
  String get generatingPdfCatalog => 'GENERATING PDF CATALOG...';

  @override
  String get manyPhotosWarning => 'This may take a while with many photos';

  @override
  String get sortByDate => 'Sort by date';

  @override
  String get sortByStatus => 'Sort by status';

  @override
  String get searchInStash => 'SEARCH IN STASH...';

  @override
  String get noModelsFound => 'NO MODELS FOUND';

  @override
  String modelsInQueue(int count) {
    return '$count MODELS IN QUEUE';
  }

  @override
  String get stashEmpty => 'YOUR STASH IS EMPTY';

  @override
  String get stashEmptyHint => 'Add models that are waiting for their turn!';

  @override
  String get startModel => 'START MODEL';

  @override
  String get moveToWorkshopHint => 'Move to workshop with today\'s date';

  @override
  String get movingToWorkshop => 'Moving model to workshop...';

  @override
  String get movedToWorkshop => 'Model moved to workshop!';

  @override
  String get sold => 'SOLD';

  @override
  String get removeFromCollectionHint => 'Permanently remove from collection';

  @override
  String get confirmSale => 'CONFIRM SALE';

  @override
  String soldConfirmationMessage(String title) {
    return 'Are you sure you sold project \"$title\"? It will be permanently removed from the database along with all photos.';
  }

  @override
  String get deletingModel => 'Deleting model...';

  @override
  String get modelDeleted => 'Model has been removed.';

  @override
  String get soldDeleteAction => 'SOLD - DELETE';

  @override
  String criticalError(String error) {
    return 'Critical error: $error';
  }

  @override
  String pdfExportError(String error) {
    return 'PDF export error: $error';
  }

  @override
  String get selectProgress => 'SELECT PROGRESS';

  @override
  String get noBuildSteps => 'NO BUILD STEPS';

  @override
  String errorPrefix(String error) {
    return 'Error: $error';
  }

  @override
  String exportError(String error) {
    return 'Export error: $error';
  }

  @override
  String get close => 'CLOSE';
}
