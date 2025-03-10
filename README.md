# flutter_starter_clean

A Starter Project for develop Flutter.

## Demo video

 <video width="640" height="360" controls>
    <source src="demo.mp4" type="video/mp4">
  </video>
  
## About

This project is a Flutter starter template implementing **Clean Architecture** with **BLoC**, **Provider** for state management. It demonstrates scalable structure for building Flutter applications with **up-to-date** 3rd package. Datasource intergrate with mock backend with **json_server**, **emulator firebase**.

## Variant

**[bloc-feature-api.rar](lib/bloc-feature-api.rar)**: State management: bloc, folder structor: Features base, Data source: Api (json server)

**[bloc-layer-api.rar](lib/bloc-layer-api.rar)**: State management: bloc, folder structor: Layer base, Data source: Api (json server)

**[provider-feature-api.rar](lib/_variants/provider-feature-api.rar)**: State management: provider, folder structor: Features base, Data source: Api (json server)

**[provider-layer-api.rar](lib/_variants/provider-layer-api.rar)**: State management: provider, folder structor: Layer base, Data source: Api (json server)

**[bloc-feature-firebase.rar](lib/bloc-feature-firebase.rar)**: State management: bloc, folder structor: Features base, Data source: Firebase Firestore

**[bloc-layer-firebase.rar](lib/bloc-layer-firebase.rar)**: State management: bloc, folder structor: Layer base, Data source: Firebase Firestore

**[provider-feature-firebase.rar](lib/_variants/provider-feature-firebase.rar)**: State management: provider, folder structor: Features base, Firebase Firestore

**[provider-layer-firebase.rar](lib/_variants/provider-layer-firebase.rar)**: State management: provider, folder structor: Layer base, Firebase Firestore

## How to use variants

1. Copy to root: **lib**, **test**, and **pubspec.yaml**
2. In **test** folder: Rename all "flutter_starter_clean" to "your_project_package_name"

## Process

- [x] Complete json server + test file
- [x] Implements app: theme, colors, flavor, locale, logs
- [x] Implements prototype ui: simple Display UI, routes
- [x] Complete prototype test
- [x] Complete prototype feature
- [x] Fixing test
- [x] Complete all feature
- [x] Complete ui
- [x] Complete all test

## Packages Used

Required have: get_it, dio, equatable, dartz, logger, path_provider

Can find relate package: cached_network_image, shared_preferences, go_router, internet_connection_checker_plus, flutter_secure_storage, google_fonts

State manager: flutter_bloc, provider

| Package                            | Description                                                           |
| ---------------------------------- | --------------------------------------------------------------------- |
| `go_router`                        | Provides declarative routing.                                         |
| `flutter_bloc`                     | Manages application state.                                            |
| `shared_preferences`               | Stores simple data persistently (key-value).                          |
| `flutter_secure_storage`           | Stores sensitive data securely.                                       |
| `get_it`                           | Implements dependency injection (service locator).                    |
| `dio`                              | Makes network requests (powerful HTTP client).                        |
| `google_fonts`                     | Provides access to Google Fonts.                                      |
| `equatable`                        | Simplifies value equality comparisons.                                |
| `dartz`                            | Provides functional programming features (e.g., `Either`).            |
| `provider`                         | Manages application state.                                            |
| `logger`                           | Logs application behavior for debugging.                              |
| `algoliasearch`                    | Handles searching for Firestore documents.                            |
| `firebase_core`                    | Initializes Firebase.                                                 |
| `firebase_auth`                    | Handles Firebase authentication.                                      |
| `cloud_firestore`                  | Handles Firebase Firestore.                                           |
| `cached_network_image`             | Caches and displays images from the network efficiently.              |
| `internet_connection_checker_plus` | Checks for internet connectivity.                                     |
| `path_provider`                    | Provides access to file system locations (documents directory, etc.). |
| `mocktail` (dev dependency)        | Mocks objects for unit and widget testing.                            |
| `bloc_test` (dev dependency)       | Provides utilities for testing BLoCs.                                 |
| `flutter_lorem` (dev dependency)   | Generates lorem ipsum placeholder text.                               |
| `device_preview` (dev dependency)  | Simulates device sizes for UI development.                            |

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/vemines/flutter_starter_clean
    cd flutter_starter_clean
    ```

2.  **Choose Variants**

3.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

4.  **Run json-server**

    ```bash
    cd json-server
    npm run gen
    npm run dev     or npm start

    ```

5.  **Run the application (choose your flavor):**

        - **Development:**
          flutter run lib/main_development.dart

        - **Staging:**
          flutter run lib/main_staging.dart

        - **Production:**
          `flutter run lib/main_production.dart

    Different`main*\*` files are used for different build configurations [flavors](lib/configs/flavor_config.dart).

## Firebase

1. **Delete firebase.json if it exist and run `flutterfire configure` for create file lib\firebase_options.dart**

2. **Add emulator config to firebase.json**

   ```json
    "emulators": {
       "firestore": {
         "port": 8080
       },
       "ui": {
         "enabled": true
       },
       "singleProjectMode": true,
       "auth": {
         "port": 9099
       }
     }
   ```

3. **Run Firestore and Auth emulator (Make sure you install firebase)**

   ```bash
   firebase emulators:start --import=./firebase --export-on-exit=./firebase
   ```

4. **Generate firestore data**

   ```bash
   cd firestore-utils
   node gen.js
   ```

5. **Upload index to Algolia for search, make sure complete `.env` file from `.env sameple`**

   ```bash
   node algolia.js
   ```

## App Structure

The project follows a Clean Architecture structure, separating concerns into layers:

- **`app`:** Contains core application-level components.

  - `cubits`: Global `Cubit`s for theme, locale, and logging.
  - `colors.dart`: Defines application colors.
  - `flavor.dart`: Handles environment-specific configurations (development, staging, production).
  - `locale.dart`: Manages localization and internationalization (translations).
  - `logs.dart`: Provides a logging service for debugging and error tracking.
  - `routes.dart`: Defines application routes using `go_router`.
  - `theme.dart`: Defines application themes (light, dark, custom).

- **`configs`:** Configuration files.

  - `app_config.dart`: General app constants.
  - `flavor_config.dart`: Configuration for different build environments.
  - `locale_config.dart`: Supported locales.

- **`core`:** Reusable components and utilities.

  - `constants`: Constants used throughout the application (API endpoints, error messages, etc.).
  - `errors`: Custom exception and failure classes.
  - `extensions`: Extension methods for added functionality (e.g., `ColorExt` for opacity, `DoubleWidgetExt` for SizedBox shortcuts).
  - `network`: Network-related classes (e.g., `NetworkInfo` for connectivity checks).
  - `pages`: General-purpose pages (e.g., `NotFoundPage`).
  - `usecase`: Base `UseCase` class and common parameter classes (e.g., `NoParams`, `PaginationParams`).
  - `utils`: Utility functions (e.g., `num_utils.dart`, `string_utils.dart`).
  - `widgets`: Reusable widgets (e.g., `CachedImage`).

- **`features`:** Contains the application's features, each organized into its own directory (e.g., `auth`, `post`, `user`, `comment`).

  - `data`:
    - `datasources`: Handles data retrieval and storage (local and remote).
    - `models`: Data models that extend the domain entities and include methods for serialization/deserialization (e.g., `fromJson`, `toJson`, `fromEntity`, `copyWith`).
    - `repositories`: Implementation of the repository interfaces, handling data access logic.
  - `domain`:
    - `entities`: Business objects representing core concepts (e.g., `Auth`, `User`, `Post`, `Comment`).
    - `repositories`: Abstract interfaces defining how data should be accessed.
    - `usecases`: Specific business logic operations (e.g., `LoginUseCase`, `GetAllPostsUseCase`).
  - `presentation`:
    - `bloc`: BLoCs that manage the state of the feature's UI.
    - `pages`: UI screens for the feature.
    - `widgets`: UI widgets specific to the feature.

- **`injection_container.dart`:** Sets up dependency injection using `get_it`.

- **`main_*.dart`:** Entry points for different build configurations (development, staging, production).

### Flavors

The project uses flavors to manage different build configurations. This allows you to have different settings (e.g., API endpoints, request Timeout) for development, staging, and production environments. The `FlavorService` and `FlavorConfig` classes handle this.

```dart
// Usage:
FlavorService.instance.config.nameConfig
```

## Localization

The project supports internationalization. Language files are stored in `assets/lang/` (or the renamed `app_assets/lang` if you are building for the web) as JSON files (e.g., `en.json`, `vi.json`). The `AppLocalizations` class handles loading and translating strings.

```dart
// Usage:
Text(context.tr(I18nKeys.greeting, {'name': 'Flutter Dev'}))
```

## Logging

The `LogService` class provides logging functionality, writing logs to both the console and a file (except on the web, where it only logs to the console).

```dart
// Usage:
final logService = await LogService.instance();
logService.d("Debug message");
logService.i("Info message");
logService.w("Warning message");
logService.e("Error message", error: exception, stackTrace: stackTrace);
```

## Testing

The `test` folder contains unit and integration tests for the data and domain layers of each feature. It uses `mocktail` for mocking dependencies and `bloc_test` for testing BLoCs. The tests cover:

- **Data Sources:** Testing interactions with `shared_preferences`, `flutter_secure_storage`, and `dio`.
- **Repositories:** Testing data retrieval, caching, and error handling.
- **Use Cases:** Testing business logic.
- **BLoCs:** Testing state changes in response to events.

To run the tests:

```bash
flutter test
```

## Note

**This Code Write with "dart.lineLength": 100 Settings. Sorry if code weird after format files**

**Algoria index old value (300 create post from gen.js). Listen new post is not work, test on emulator**

**Please remove this in web/index.html if you develop on web**

```html
<style>
  .firebase-emulator-warning {
    display: none !important;
  }
</style>
```
