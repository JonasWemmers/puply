import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
    Locale('de'),
    Locale('en'),
  ];

  /// Begrüßungstext auf dem Login-Screen
  ///
  /// In de, this message translates to:
  /// **'Willkommen zurück!'**
  String get welcomeBack;

  /// Untertitel auf dem Login-Screen
  ///
  /// In de, this message translates to:
  /// **'Melde dich an, um nach deinem Welpen zu sehen.'**
  String get loginToCheckPup;

  /// Text für Google-Login-Button
  ///
  /// In de, this message translates to:
  /// **'Mit Google fortfahren'**
  String get continueWithGoogle;

  /// Text für Apple-Login-Button
  ///
  /// In de, this message translates to:
  /// **'Mit Apple fortfahren'**
  String get continueWithApple;

  /// Trennzeichen zwischen Social-Login und Email-Login
  ///
  /// In de, this message translates to:
  /// **'oder'**
  String get or;

  /// Placeholder für Email-Eingabefeld
  ///
  /// In de, this message translates to:
  /// **'E-Mail'**
  String get email;

  /// Placeholder für Passwort-Eingabefeld
  ///
  /// In de, this message translates to:
  /// **'Passwort'**
  String get password;

  /// Link zum Zurücksetzen des Passworts
  ///
  /// In de, this message translates to:
  /// **'Passwort vergessen?'**
  String get forgotPassword;

  /// Text für Login-Button
  ///
  /// In de, this message translates to:
  /// **'Anmelden'**
  String get logIn;

  /// Text vor dem Sign-up-Link
  ///
  /// In de, this message translates to:
  /// **'Noch kein Konto?'**
  String get dontHaveAccount;

  /// Link zur Registrierung
  ///
  /// In de, this message translates to:
  /// **'Registrieren'**
  String get signUp;

  /// Überschrift auf dem Registrierungs-Screen
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get joinThePack;

  /// Untertitel auf dem Registrierungs-Screen
  ///
  /// In de, this message translates to:
  /// **'Erstelle ein Konto, um loszulegen'**
  String get createAccountToStartTracking;

  /// Placeholder für E-Mail-Eingabe bei Registrierung
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Adresse'**
  String get emailAddress;

  /// Button zum Fortfahren bei der Registrierung
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get next;

  /// Text vor dem Login-Link auf dem Registrierungs-Screen
  ///
  /// In de, this message translates to:
  /// **'Bereits ein Konto?'**
  String get alreadyHaveAccount;

  /// Titel auf Registrierungs-Schritt 2
  ///
  /// In de, this message translates to:
  /// **'Fast geschafft!'**
  String get almostThere;

  /// Label für Namensfeld
  ///
  /// In de, this message translates to:
  /// **'Dein Name'**
  String get yourName;

  /// Placeholder für Namenseingabe
  ///
  /// In de, this message translates to:
  /// **'Gib deinen vollständigen Namen ein'**
  String get enterYourFullName;

  /// Label für Passwortfeld bei Registrierung
  ///
  /// In de, this message translates to:
  /// **'Passwort erstellen'**
  String get createPassword;

  /// Passwort-Hinweis und Placeholder
  ///
  /// In de, this message translates to:
  /// **'Mindestens 8 Zeichen'**
  String get atLeast8Characters;

  /// Button zum Abschluss der Registrierung
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get createAccount;

  /// Rechtlicher Hinweis unter dem Konto-erstellen-Button
  ///
  /// In de, this message translates to:
  /// **'Mit der Registrierung stimmst du unseren AGB zu.'**
  String get termsAndConditions;

  /// Auth-Fehler: E-Mail bereits registriert
  ///
  /// In de, this message translates to:
  /// **'Diese E-Mail-Adresse wird bereits verwendet.'**
  String get errorEmailAlreadyInUse;

  /// Auth-Fehler: ungültige E-Mail
  ///
  /// In de, this message translates to:
  /// **'Ungültige E-Mail-Adresse.'**
  String get errorInvalidEmail;

  /// Auth-Fehler: schwaches Passwort
  ///
  /// In de, this message translates to:
  /// **'Das Passwort ist zu schwach. Mindestens 8 Zeichen.'**
  String get errorWeakPassword;

  /// Auth-Fehler: Aktion nicht erlaubt
  ///
  /// In de, this message translates to:
  /// **'E-Mail-Registrierung ist nicht aktiviert.'**
  String get errorOperationNotAllowed;

  /// Auth-Fehler: allgemein
  ///
  /// In de, this message translates to:
  /// **'Registrierung fehlgeschlagen.'**
  String get errorRegistrationFailed;

  /// Onboarding-Fortschrittslabel
  ///
  /// In de, this message translates to:
  /// **'SCHRITT {current} VON {total}'**
  String stepXOfY(int current, int total);

  /// Onboarding Schritt 1 Titel
  ///
  /// In de, this message translates to:
  /// **'Wer ist dein bester Freund?'**
  String get whosYourBestFriend;

  /// Onboarding Schritt 1 Untertitel
  ///
  /// In de, this message translates to:
  /// **'Erstelle ein Profil für deinen Welpen.'**
  String get createProfileForPup;

  /// Placeholder für Hundename
  ///
  /// In de, this message translates to:
  /// **'Name des Hundes'**
  String get dogsName;

  /// Label für Geschlechtsauswahl
  ///
  /// In de, this message translates to:
  /// **'Geschlecht'**
  String get gender;

  /// Geschlechtsoption männlich
  ///
  /// In de, this message translates to:
  /// **'Rüde'**
  String get boy;

  /// Geschlechtsoption weiblich
  ///
  /// In de, this message translates to:
  /// **'Hündin'**
  String get girl;

  /// Onboarding-Weiter-Button
  ///
  /// In de, this message translates to:
  /// **'Weiter →'**
  String get nextArrow;

  /// Onboarding Schritt 2 Titel mit Hundename
  ///
  /// In de, this message translates to:
  /// **'Erzähl uns mehr über {name}'**
  String tellUsMoreAboutName(String name);

  /// Onboarding Schritt 2 Untertitel
  ///
  /// In de, this message translates to:
  /// **'Rasse und Alter helfen uns, Gesundheitstipps zu personalisieren.'**
  String get breedAgePersonalizeTips;

  /// Label für Rassenfeld
  ///
  /// In de, this message translates to:
  /// **'Rasse'**
  String get breed;

  /// Placeholder für Rassen-Suche/Dropdown
  ///
  /// In de, this message translates to:
  /// **'Rassen suchen (z. B. Golden Retriever)'**
  String get searchBreedsPlaceholder;

  /// Label für Geburtstagsfeld
  ///
  /// In de, this message translates to:
  /// **'Geburtstag'**
  String get birthday;

  /// Placeholder für Geburtstagseingabe
  ///
  /// In de, this message translates to:
  /// **'dd.mm.yyyy'**
  String get birthdayPlaceholder;

  /// Link für ungefähres Alter
  ///
  /// In de, this message translates to:
  /// **'Ich kenne nur das ungefähre Alter'**
  String get iOnlyKnowApproximateAge;

  /// Onboarding Schritt 2 Weiter-Button
  ///
  /// In de, this message translates to:
  /// **'Weiter'**
  String get continueButton;

  /// Onboarding Schritt 3 Titel mit Hundename
  ///
  /// In de, this message translates to:
  /// **'Wie schwer ist {name}?'**
  String howHeavyIsName(String name);

  /// Label für Körperzustand-Bereich
  ///
  /// In de, this message translates to:
  /// **'KÖRPERZUSTAND'**
  String get bodyCondition;

  /// Körperzustand-Option
  ///
  /// In de, this message translates to:
  /// **'Untergewicht'**
  String get underweight;

  /// Körperzustand-Option
  ///
  /// In de, this message translates to:
  /// **'Ideal'**
  String get ideal;

  /// Körperzustand-Option
  ///
  /// In de, this message translates to:
  /// **'Übergewicht'**
  String get overweight;

  /// Onboarding Schritt 4 Titel
  ///
  /// In de, this message translates to:
  /// **'Besondere Bedürfnisse?'**
  String get anySpecialNeeds;

  /// Onboarding Schritt 4 Untertitel
  ///
  /// In de, this message translates to:
  /// **'So können wir dein Erlebnis anpassen.'**
  String get specialNeedsSubtitle;

  /// Option besondere Bedürfnisse
  ///
  /// In de, this message translates to:
  /// **'Allergien'**
  String get allergies;

  /// Option besondere Bedürfnisse
  ///
  /// In de, this message translates to:
  /// **'Tägliche Medikation'**
  String get dailyMedication;

  /// Option besondere Bedürfnisse
  ///
  /// In de, this message translates to:
  /// **'Seniorenhund'**
  String get seniorDog;

  /// Option besondere Bedürfnisse
  ///
  /// In de, this message translates to:
  /// **'Welpentraining'**
  String get puppyTraining;

  /// Option – keine besonderen Bedürfnisse
  ///
  /// In de, this message translates to:
  /// **'Keine'**
  String get none;

  /// Onboarding Schritt 4 Abschluss-Button
  ///
  /// In de, this message translates to:
  /// **'Fertig & Dashboard erkunden'**
  String get finishAndExploreDashboard;

  /// No description provided for @goodMorning.
  ///
  /// In de, this message translates to:
  /// **'Guten Morgen, {name}!'**
  String goodMorning(String name);

  /// No description provided for @goodAfternoon.
  ///
  /// In de, this message translates to:
  /// **'Guten Tag, {name}!'**
  String goodAfternoon(String name);

  /// No description provided for @goodEvening.
  ///
  /// In de, this message translates to:
  /// **'Guten Abend, {name}!'**
  String goodEvening(String name);

  /// No description provided for @howIsNameDoingToday.
  ///
  /// In de, this message translates to:
  /// **'Wie geht es {name} heute?'**
  String howIsNameDoingToday(String name);

  /// No description provided for @quickLog.
  ///
  /// In de, this message translates to:
  /// **'Quick Log'**
  String get quickLog;

  /// No description provided for @edit.
  ///
  /// In de, this message translates to:
  /// **'Bearbeiten'**
  String get edit;

  /// No description provided for @food.
  ///
  /// In de, this message translates to:
  /// **'Futter'**
  String get food;

  /// No description provided for @water.
  ///
  /// In de, this message translates to:
  /// **'Wasser'**
  String get water;

  /// No description provided for @walk.
  ///
  /// In de, this message translates to:
  /// **'Gassi'**
  String get walk;

  /// No description provided for @potty.
  ///
  /// In de, this message translates to:
  /// **'Geschäft'**
  String get potty;

  /// No description provided for @symptoms.
  ///
  /// In de, this message translates to:
  /// **'Symptome'**
  String get symptoms;

  /// No description provided for @cycle.
  ///
  /// In de, this message translates to:
  /// **'Zyklus'**
  String get cycle;

  /// No description provided for @currentMood.
  ///
  /// In de, this message translates to:
  /// **'Aktuelle Stimmung'**
  String get currentMood;

  /// No description provided for @playful.
  ///
  /// In de, this message translates to:
  /// **'Verspielt'**
  String get playful;

  /// No description provided for @sleepy.
  ///
  /// In de, this message translates to:
  /// **'Müde'**
  String get sleepy;

  /// No description provided for @hungry.
  ///
  /// In de, this message translates to:
  /// **'Hungrig'**
  String get hungry;

  /// No description provided for @happy.
  ///
  /// In de, this message translates to:
  /// **'Fröhlich'**
  String get happy;

  /// No description provided for @sick.
  ///
  /// In de, this message translates to:
  /// **'Krank'**
  String get sick;

  /// No description provided for @healthSnapshot.
  ///
  /// In de, this message translates to:
  /// **'GESUNDHEITSÜBERSICHT'**
  String get healthSnapshot;

  /// No description provided for @nextVetVisit.
  ///
  /// In de, this message translates to:
  /// **'Nächster Tierarztbesuch'**
  String get nextVetVisit;

  /// No description provided for @home.
  ///
  /// In de, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In de, this message translates to:
  /// **'Verlauf'**
  String get history;

  /// No description provided for @analytics.
  ///
  /// In de, this message translates to:
  /// **'Analysen'**
  String get analytics;

  /// No description provided for @profile.
  ///
  /// In de, this message translates to:
  /// **'Profil'**
  String get profile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
