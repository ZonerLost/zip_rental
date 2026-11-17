import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('en'),
    Locale('fr'),
  ];

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get home_welcomeBack;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Explore Rentals'**
  String get home_exploreRentals;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'What are you looking for?'**
  String get home_whatLooking;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get home_map;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get home_all;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get home_popular;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Recently Added'**
  String get home_recentlyAdded;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get home_search;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get home_bookings;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Add Item (bottom navigation only)'**
  String get home_addItemBottomNavigationOnly;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get home_myListings;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get home_chats;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get home_noConversationsYet;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Dashboard (bottom navigation)'**
  String get home_dashboardBottomNavigation;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Favourites / Favorites'**
  String get home_favouritesFavorites;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get home_notifications;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get home_day;

  /// Section 1: Navigation and Home — Search / Explore Rentals
  ///
  /// In en, this message translates to:
  /// **'0.0 ratings'**
  String get home_00Ratings;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Add new item'**
  String get addItem_addNewItem;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Step 1/5'**
  String get addItem_step15;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Upload Product Images'**
  String get addItem_uploadProductImages;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Multiple images allowed (max 5)'**
  String get addItem_multipleImagesAllowedMax5;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get addItem_upload;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get addItem_title;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'e.g. Nike Jordan 6'**
  String get addItem_eGNikeJordan6;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Minimum 5 characters (0/5)'**
  String get addItem_minimum5Characters05;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get addItem_category;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get addItem_electronics;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Kitchen'**
  String get addItem_kitchen;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get addItem_condition;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get addItem_new;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Like New'**
  String get addItem_likeNew;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get addItem_good;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get addItem_price;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Per'**
  String get addItem_per;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Per Day'**
  String get addItem_perDay;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Per Week'**
  String get addItem_perWeek;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get addItem_productDescription;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Minimum 20 characters'**
  String get addItem_minimum20Characters;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Rental Duration'**
  String get addItem_rentalDuration;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'1–58 days'**
  String get addItem_158Days;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'1–30 days'**
  String get addItem_130Days;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'1–90 days'**
  String get addItem_190Days;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Describe your item…'**
  String get addItem_describeItem;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Validation'**
  String get addItem_validation;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Title must be at least 5 characters.'**
  String get addItem_titleMustBeAtLeast;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Delivery only'**
  String get addItem_deliveryOnly;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Pickup only'**
  String get addItem_pickupOnly;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Enable Both'**
  String get addItem_enableBoth;

  /// Section 2: Add New Item — Step 1
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get addItem_continue;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get delivery_deliveryFee;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Step 2/5'**
  String get delivery_step25;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Charged when no distance tier matches.'**
  String get delivery_chargedWhenNoDistanceTier;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Distance Pricing Tiers'**
  String get delivery_distancePricingTiers;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Set a price per distance range (e.g. up to 10 km → \$10).'**
  String get delivery_setPricePerDistanceRange;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'e.g. 10'**
  String get delivery_eG10;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'e.g. 10.00'**
  String get delivery_eG1000;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Add tier'**
  String get delivery_addTier;

  /// Section 3: Delivery Fees — Step 2
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get delivery_continue;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Delivery Availability'**
  String get availability_deliveryAvailability;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Pickup Availability'**
  String get availability_pickupAvailability;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Step 3/5'**
  String get availability_step35;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Step 4/5'**
  String get availability_step45;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Request to book (manual approval)'**
  String get availability_requestBookManualApproval;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Instant booking (auto-confirmed)'**
  String get availability_instantBookingAutoConfirmed;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Recurring schedule'**
  String get availability_recurringSchedule;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Specific dates only'**
  String get availability_specificDatesOnly;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get availability_monday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get availability_tuesday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get availability_wednesday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get availability_thursday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get availability_friday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get availability_saturday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get availability_sunday;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'All Day'**
  String get availability_allDay;

  /// Section 4: Availability, Pickup and Booking
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get availability_continue;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Boost Ad'**
  String get boost_boostAd;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Boost your ad for \$9.99'**
  String get boost_boostAd999;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Boost Ad — \$9.99 / 7 days'**
  String get boost_boostAd9997;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Boost add'**
  String get boost_boostAdd;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Add Item (publish button)'**
  String get boost_addItemPublishButton;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Get more views and better results by promoting your listing for 7 days.'**
  String get boost_getMoreViewsBetterResults;

  /// Section 5: Boost Listing
  ///
  /// In en, this message translates to:
  /// **'Skip this step'**
  String get boost_skipThisStep;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get publish_summary;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Product Information'**
  String get publish_productInformation;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get publish_edit;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get publish_productName;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get publish_category;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get publish_condition;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Rental Type'**
  String get publish_rentalType;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get publish_price;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get publish_deliveryFees;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get publish_description;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Pickup Address'**
  String get publish_pickupAddress;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Request to book (instant approval)'**
  String get publish_requestBookInstantApproval;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Adding…'**
  String get publish_adding;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Boost add'**
  String get publish_boostAdd;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Add Item (final button)'**
  String get publish_addItemFinalButton;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get publish_success;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Item created successfully.'**
  String get publish_itemCreatedSuccessfully;

  /// Section 6: Listing Summary and Publication
  ///
  /// In en, this message translates to:
  /// **'Item added successfully.'**
  String get publish_itemAddedSuccessfully;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'My Listings'**
  String get myListings_myListings;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get myListings_category;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get myListings_condition;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get myListings_price;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get myListings_address;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get myListings_status;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get myListings_active;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Pause listing'**
  String get myListings_pauseListing;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get myListings_itemDetails;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get myListings_uploadPhotos;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get myListings_deletePhoto;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get myListings_availability;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get myListings_delete;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get myListings_edit;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Total Rentals'**
  String get myListings_totalRentals;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get myListings_rating;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get myListings_homeAddress;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'Together, we saved 0 rental trips with this item and made sustainable choices!'**
  String get myListings_togetherWeSaved0Rental;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get myListings_day;

  /// Section 7: My Listings
  ///
  /// In en, this message translates to:
  /// **'/week'**
  String get myListings_week;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Listing Details'**
  String get listingDetails_listingDetails;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get listingDetails_category;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get listingDetails_condition;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get listingDetails_booking;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Instant (auto-confirmed)'**
  String get listingDetails_instantAutoConfirmed;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Rental Terms'**
  String get listingDetails_rentalTerms;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get listingDetails_status;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Available for booking'**
  String get listingDetails_availableBooking;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Rental Duration'**
  String get listingDetails_rentalDuration;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Weekly Rate'**
  String get listingDetails_weeklyRate;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Delivery & Pickup'**
  String get listingDetails_deliveryPickup;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get listingDetails_location;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Rental Type'**
  String get listingDetails_rentalType;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Flat Delivery Fee'**
  String get listingDetails_flatDeliveryFee;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get listingDetails_totalAmount;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get listingDetails_bookNow;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get listingDetails_month;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'01 Month'**
  String get listingDetails_01Month;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'1/1'**
  String get listingDetails_11;

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Message {person}'**
  String listingDetails_messagePerson(String person);

  /// Section 8: Listing Details
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get listingDetails_send;

  /// Section 9: Favourites
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites_favourites;

  /// Section 9: Favourites
  ///
  /// In en, this message translates to:
  /// **'No favourites yet'**
  String get favourites_noFavouritesYet;

  /// Section 9: Favourites
  ///
  /// In en, this message translates to:
  /// **'Tap the heart on any item to save it here'**
  String get favourites_tapHeartAnyItemSave;

  /// Section 9: Favourites
  ///
  /// In en, this message translates to:
  /// **'1 items'**
  String get favourites_1Items;

  /// Section 9: Favourites
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get favourites_day;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Chats'**
  String get chat_chats;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chat_noConversationsYet;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Search here…'**
  String get chat_searchHere;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Recent Chats'**
  String get chat_recentChats;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'All Chats'**
  String get chat_allChats;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Archive Chats'**
  String get chat_archiveChats;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Type your message here…'**
  String get chat_typeMessageHere;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Discussing this item'**
  String get chat_discussingThisItem;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Archive Chat'**
  String get chat_archiveChat;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Unarchive Chat'**
  String get chat_unarchiveChat;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get chat_blockUser;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get chat_reportUser;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Archive User'**
  String get chat_archiveUser;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to archive this chat?'**
  String get chat_sureWantArchiveThisChat;

  /// Section 10: Chats and Messaging
  ///
  /// In en, this message translates to:
  /// **'Yes, Archive'**
  String get chat_yesArchive;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings_bookings;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Items I rent out'**
  String get bookings_itemsIRentOut;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Items I’m renting'**
  String get bookings_itemsIMRenting;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get bookings_upcoming;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookings_pending;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get bookings_active;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get bookings_past;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'0 Bookings found'**
  String get bookings_0BookingsFound;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'1 Bookings found'**
  String get bookings_1BookingsFound;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'No bookings found for this status.'**
  String get bookings_noBookingsFoundThisStatus;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get bookings_ownerName;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get bookings_customerName;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get bookings_amount;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get bookings_startDate;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get bookings_endDate;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get bookings_booking;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get bookings_cancelBooking;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookings_completed;

  /// Section 11: Bookings
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookings_cancelled;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get report_reportProblem;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get report_reason;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Item Damaged'**
  String get report_itemDamaged;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Item Not Returned'**
  String get report_itemNotReturned;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Item Not As Described'**
  String get report_itemNotAsDescribed;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Late Return'**
  String get report_lateReturn;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'No Show'**
  String get report_noShow;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Payment Issue'**
  String get report_paymentIssue;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get report_other;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get report_description;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Evidence (optional)'**
  String get report_evidenceOptional;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get report_addPhotos;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get report_submitReport;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'Dispute Failed'**
  String get report_disputeFailed;

  /// Section 12: Report a Problem and Claims
  ///
  /// In en, this message translates to:
  /// **'You have already raised a dispute for this booking'**
  String get report_haveAlreadyRaisedDisputeThis;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard (bottom navigation)'**
  String get dashboard_dashboardBottomNavigation;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Items I rented out'**
  String get dashboard_itemsIRentedOut;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Rented from Others'**
  String get dashboard_rentedFromOthers;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Items Listed'**
  String get dashboard_itemsListed;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Ratings'**
  String get dashboard_ratings;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Earning from rented items'**
  String get dashboard_earningFromRentedItems;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dashboard_thisMonth;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'CO₂ saved by renting out items instead of buying'**
  String get dashboard_coSavedByRentingOut;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'by car'**
  String get dashboard_byCar;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Recent Bookings'**
  String get dashboard_recentBookings;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get dashboard_customerName;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get dashboard_cancelled;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get dashboard_settings;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'BADGES'**
  String get dashboard_badges;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get dashboard_lifetime;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Total CO₂ saved'**
  String get dashboard_totalCoSaved;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Equivalent in car kilometers avoided'**
  String get dashboard_equivalentCarKilometersAvoided;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Number of rentals contributing'**
  String get dashboard_numberRentalsContributing;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Current badge tier'**
  String get dashboard_currentBadgeTier;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Eco Starter'**
  String get dashboard_ecoStarter;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Green Achiever'**
  String get dashboard_greenAchiever;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Planet Hero'**
  String get dashboard_planetHero;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Impact Legend'**
  String get dashboard_impactLegend;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Reach 0 kg CO₂ saved'**
  String get dashboard_reach0KgCoSaved;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Reach 50 kg CO₂ saved'**
  String get dashboard_reach50KgCoSaved;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Reach 200 kg CO₂ saved'**
  String get dashboard_reach200KgCoSaved;

  /// Section 13: My Activity — Dashboard
  ///
  /// In en, this message translates to:
  /// **'Reach 500 kg CO₂ saved'**
  String get dashboard_reach500KgCoSaved;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get settings_accountSettings;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Payout Information'**
  String get settings_payoutInformation;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get settings_myAddresses;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get settings_addNewAddress;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settings_changePassword;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get settings_currentPassword;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get settings_createNewPassword;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settings_confirmNewPassword;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get settings_update;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get settings_default;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'You haven’t blocked anyone.'**
  String get settings_havenTBlockedAnyone;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Notifications Blocked'**
  String get settings_notificationsBlocked;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked at the system level. Enable them from your device settings.'**
  String get settings_notificationsBlockedAtSystemLevel;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_settings;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'My Address'**
  String get settings_myAddress;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get settings_enableNotifications;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get settings_blockedUsers;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settings_helpSupport;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settings_termsConditions;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Action needed'**
  String get settings_actionNeeded;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Stripe needs a bit more information before payouts can be enabled.'**
  String get settings_stripeNeedsBitMoreInformation;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Proof of liveness'**
  String get settings_proofLiveness;

  /// Section 14: Account Settings and Addresses
  ///
  /// In en, this message translates to:
  /// **'Continue setup'**
  String get settings_continueSetup;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Select range'**
  String get dates_selectRange;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get dates_endDate;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get dates_save;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get dates_october;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get dates_november;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Sunday / Sun'**
  String get dates_sundaySun;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Monday / Mon'**
  String get dates_mondayMon;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Tuesday / Tue'**
  String get dates_tuesdayTue;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Wednesday / Wed'**
  String get dates_wednesdayWed;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Thursday / Thu'**
  String get dates_thursdayThu;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Friday / Fri'**
  String get dates_fridayFri;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Saturday / Sat'**
  String get dates_saturdaySat;

  /// Section 15: Date Selection and Booking
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get dates_bookNow;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Checkout (page title)'**
  String get checkout_checkoutPageTitle;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'ADDED ITEMS'**
  String get checkout_addedItems;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'1 Times rented'**
  String get checkout_1TimesRented;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'/day'**
  String get checkout_day;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get checkout_delivery;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get checkout_pickup;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Select address'**
  String get checkout_selectAddress;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get checkout_homeAddress;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get checkout_change;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'I have read and agree to the Terms of Use, including the applicable rental, cancellation, security deposit, claims, and prohibited items policies.'**
  String get checkout_iHaveReadAgreeTerms;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Discount code'**
  String get checkout_discountCode;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get checkout_apply;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get checkout_loading;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Items Price'**
  String get checkout_itemsPrice;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Discount (0%)'**
  String get checkout_discount0;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Delivery Fees'**
  String get checkout_deliveryFees;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get checkout_subtotal;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Atussa Fee'**
  String get checkout_atussaFee;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'TPS (GST)'**
  String get checkout_tpsGst;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'TVQ (QST)'**
  String get checkout_tvqQst;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get checkout_totalAmount;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get checkout_continuePayment;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Select Booking Dates'**
  String get checkout_selectBookingDates;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Available From'**
  String get checkout_availableFrom;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Available To'**
  String get checkout_available;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Terms Required'**
  String get checkout_termsRequired;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Please agree to the Terms of Use.'**
  String get checkout_pleaseAgreeTermsUse;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Select Payment'**
  String get checkout_selectPayment;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get checkout_back;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Please select a saved card, or add a new one.'**
  String get checkout_pleaseSelectSavedCardAdd;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'You haven’t saved a payment method yet.'**
  String get checkout_havenTSavedPaymentMethod;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Add new card'**
  String get checkout_addNewCard;

  /// Section 16: Checkout / Booking Summary
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get checkout_continue;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Add new payment method'**
  String get payment_addNewPaymentMethod;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Card Label'**
  String get payment_cardLabel;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get payment_cardType;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get payment_visa;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Mastercard'**
  String get payment_mastercard;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Last 4 Digits'**
  String get payment_last4Digits;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Expiry Month'**
  String get payment_expiryMonth;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Expiry Year'**
  String get payment_expiryYear;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Set as default payment method'**
  String get payment_setAsDefaultPaymentMethod;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Enter exactly 4 digits for the last-4.'**
  String get payment_enterExactly4DigitsLast;

  /// Section 17: Add a Payment Method
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get payment_add;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get confirmation_success;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Booking request created successfully.'**
  String get confirmation_bookingRequestCreatedSuccessfully;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Request Sent!'**
  String get confirmation_requestSent;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Your request for renting this item has been sent to the owner of the product, you’ll receive a notification once approved.'**
  String get confirmation_requestRentingThisItemHas;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get confirmation_dateTime;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Rented Duration'**
  String get confirmation_rentedDuration;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'8 days'**
  String get confirmation_8Days;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Order Type'**
  String get confirmation_orderType;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get confirmation_delivery;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get confirmation_totalAmount;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Payment Method Selected'**
  String get confirmation_paymentMethodSelected;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Renting instead of buying helps reduce waste — thanks for choosing to rent!'**
  String get confirmation_rentingInsteadBuyingHelpsReduce;

  /// Section 18: Booking Request Confirmation
  ///
  /// In en, this message translates to:
  /// **'Go to Home Page'**
  String get confirmation_goHomePage;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get status_cancelBooking;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get status_pending;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get status_upcoming;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get status_active;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get status_completed;

  /// Section 19: Cancellation and Booking Statuses
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get status_cancelled;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Near Me'**
  String get filters_nearMe;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Select Filters'**
  String get filters_selectFilters;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Please select the filters as per your preferences.'**
  String get filters_pleaseSelectFiltersAsPer;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Search products'**
  String get filters_searchProducts;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'e.g. Footwear…'**
  String get filters_eGFootwear;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get filters_location;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'e.g. Brooklyn, New York'**
  String get filters_eGBrooklynNewYork;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get filters_distance;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'500 m'**
  String get filters_500M;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'2.5 km'**
  String get filters_25Km;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'5 km'**
  String get filters_5Km;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'10 km +'**
  String get filters_10Km;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filters_reset;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filters_apply;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get filters_back;

  /// Section 20: Search Filters
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filters_all;

  /// Section 21: Notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_notifications;

  /// Section 21: Notifications
  ///
  /// In en, this message translates to:
  /// **'Booking Cancelled'**
  String get notifications_bookingCancelled;

  /// Section 21: Notifications
  ///
  /// In en, this message translates to:
  /// **'New Booking Request'**
  String get notifications_newBookingRequest;

  /// Section 21: Notifications
  ///
  /// In en, this message translates to:
  /// **'{name} cancelled the booking for {item}'**
  String notifications_nameCancelledBookingItem(String name, String item);

  /// Section 21: Notifications
  ///
  /// In en, this message translates to:
  /// **'{name} has requested to rent your {item}'**
  String notifications_nameHasRequestedRentItem(String name, String item);

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Item Details'**
  String get editListing_itemDetails;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Upload Photos'**
  String get editListing_uploadPhotos;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get editListing_deletePhoto;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get editListing_availability;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get editListing_rating;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Total Rentals'**
  String get editListing_totalRentals;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Pause listing'**
  String get editListing_pauseListing;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editListing_edit;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editListing_delete;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get editListing_active;

  /// Section 22: Edit and Manage a Listing
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get editListing_homeAddress;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get account_changePassword;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get account_currentPassword;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Create new password'**
  String get account_createNewPassword;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get account_confirmNewPassword;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get account_update;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'My Addresses'**
  String get account_myAddresses;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Home Address'**
  String get account_homeAddress;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get account_default;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get account_addNewAddress;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get account_language;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get account_english;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get account_franAis;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get account_espaOl;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get account_portuguese;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Blocked Users'**
  String get account_blockedUsers;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'You haven’t blocked anyone.'**
  String get account_havenTBlockedAnyone;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Notifications Blocked'**
  String get account_notificationsBlocked;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Notifications are blocked at the system level. Enable them from your device settings.'**
  String get account_notificationsBlockedAtSystemLevel;

  /// Section 23: Account Management
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get account_settings;

  /// Section 24: Help & Support — Navigation Only
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get help_helpSupport;

  /// Section 24: Help & Support — Navigation Only
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get help_about;

  /// Section 24: Help & Support — Navigation Only
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy (link label only)'**
  String get help_privacyPolicyLinkLabelOnly;

  /// Section 24: Help & Support — Navigation Only
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions (link label only)'**
  String get help_termsConditionsLinkLabelOnly;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get term_addItem_bottomNavigation;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get term_addItem_finalPublishAction;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get term_checkout_bookingStepTitle;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Continue to payment'**
  String get term_continuePayment_summaryActionButton;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get term_dashboard_bottomNavigation;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get term_welcomeBack_welcomeMessage;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get term_pickup_itemPickup;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Rental Type'**
  String get term_rentalType_itemHandoverOptions;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Card Type'**
  String get term_cardType_paymentCardNetwork;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Items I rented out'**
  String get term_itemsIRentedOut_ownerActivity;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Rented from Others'**
  String get term_rentedFromOthers_renterActivity;

  /// Section 25: Approved UI Terminology
  ///
  /// In en, this message translates to:
  /// **'Payout Information'**
  String get term_payoutInformation_payoutArea;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
