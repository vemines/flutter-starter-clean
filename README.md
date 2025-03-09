# flutter_starter_clean

<!-- TODO: -->

Add user rm datasource to auth rm datasource

<!--  -->

firebase emulators:start --import=./firebase --export-on-exit=./firebase

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

**bloc/provider-feature/layer-firebase.rar**: Work in process

## How to use variants

1. Make sure you have **DELETE ALL files/folders** in compressfile
2. Copy to **lib**: Folder (**app, configs, core, features**), File (**injection_container.dart**)
3. Copy to **root**: Folder(**test**)
4. In **test** folder: Rename "flutter_starter_clean" to "your_project_package_name"
5. Copy nessary package in **pubspec.yaml** to your "pubspec.yaml" file. Check [Packages Used](#packages-used).

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

| Package                            | Description                                                                                                                                         |
| ---------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| `go_router`                        | Declarative routing for Flutter.                                                                                                                    |
| `flutter_bloc`                     | State management library built on top of `Stream`s and `Sink`s.                                                                                     |
| `shared_preferences`               | Persistent key-value storage for simple data (e.g., user preferences).                                                                              |
| `flutter_secure_storage`           | Secure storage for sensitive data (e.g., API tokens, user secrets).                                                                                 |
| `get_it`                           | Service locator for dependency injection.                                                                                                           |
| `dio`                              | Powerful HTTP client for making network requests.                                                                                                   |
| `google_fonts`                     | Provide Google Fonts using in this app.                                                                                                             |
| `equatable`                        | Simplifies value equality comparisons for classes.                                                                                                  |
| `dartz`                            | Functional programming library providing features like `Either` for error handling.                                                                 |
| `logger`                           | Logging library for debugging and monitoring application behavior.                                                                                  |
| `cached_network_image`             | Library for efficiently caching and displaying images from the network.                                                                             |
| `internet_connection_checker_plus` | Checks for internet connectivity.                                                                                                                   |
| `path_provider`                    | Provides access to commonly used file system locations (documents directory, etc.). _(Note: `path_provider` versions < 2.1.5 did not support web.)_ |
| `mocktail` (dev dependency)        | Mocking library for unit and widget testing.                                                                                                        |
| `bloc_test` (dev dependency)       | Utilities for testing BLoCs.                                                                                                                        |
| `flutter_lorem` (dev dependency)   | Library for generating lorem ipsum placeholder text for UI development.                                                                             |
| `device_preview` (dev dependency)  | Library for help mock device size for develop ui                                                                                                    |

## Setup

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/vemines/flutter_starter_clean
    cd flutter_starter_clean
    ```

2.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

3.  **Run json-server**

    ```bash
    cd json-server
    npm run gen
    npm run dev     or npm start

    ```

4.  **Run the application (choose your flavor):**

        - **Development:**
          flutter run lib/main_development.dart

        - **Staging:**
          flutter run lib/main_staging.dart

        - **Production:**
          `flutter run lib/main_production.dart

    Different`main*\*` files are used for different build configurations [flavors](lib/configs/flavor_config.dart).

## Firebase

1. **Run Firestore and Auth emulator (Make sure you install it)**

   ```bash
   firebase emulators:start --import=./firebase --export-on-exit=./firebase
   ```

2. **Generate data**

```bash
cd firestore-gen
node gen.js
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

**Please remove this in web/index.html if you develop on web**

```html
<style>
  .firebase-emulator-warning {
    display: none !important;
  }
</style>
```
