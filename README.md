# GabEye

## Workspace Initialization

When you clone this repository for the first time, you need to initialize your workspace by fetching all the necessary Flutter dependencies. Run the following command in the root directory of the project:

```bash
flutter pub get
```

> **Note on Dependencies:** If you are prompted about outdated packages (e.g., via `flutter pub outdated`), do not worry if you don't have the absolute latest versions. Please stick to the specific package versions defined in our `pubspec.yaml`. Blindly updating to the "latest" can sometimes introduce breaking changes or compatibility issues within our stack.

## Git & Branching Strategy

To maintain a clean and stable codebase, please adhere to the following workflow:

1. **Never push directly to the `main` branch.**
2. **Branching:** Create your own branch on GitHub for any new feature, bug fix, or experiment.
3. **Pushing:** You are free to push commits to your own branches.
4. **Pull Requests:** Once your work is ready, always create a Pull Request (PR) targeting the `dev` branch for review and integration.

## Naming Conventions

- **Files and Directories:** Use `snake_case` for all Dart files, folders, and assets (e.g., `get_started_screen.dart`, `color_utils.dart`, `gab_eye_logo.svg`).
- **Classes:** Use `PascalCase` for classes (e.g., `GetStartedScreen`).
- **Variables and Methods:** Use `camelCase` for variables and methods (e.g., `userId`, `fetchData()`).

## Commit Message Convention

We follow a structured commit message format to keep our history readable:

- `feat:` for new features (e.g., `feat: add daltonization shader`)
- `fix:` for bug fixes (e.g., `fix: resolve camera latency issue`)
- `docs:` for documentation updates (e.g., `docs: update README with setup instructions`)
- `style:` for formatting changes that do not affect logic
- `refactor:` for code refactoring
- `test:` for adding or updating tests
- `chore:` for maintenance tasks or dependency updates

*Example:* `feat: implement Farnsworth D-15 assessment drag-and-drop`

## Envisioned Directory Structure

Below is the envisioned architecture and structure for the GabEye project:

```text
gabeye/
├── assets/
│   ├── datasets/            # The local 267-category ISCC-NBS color dictionary for KNN
│   ├── shaders/             # Custom GLSL fragment shaders (.frag) for GPU Daltonization
│   └── icons/               # High-contrast, color-agnostic iconography for WCAG compliance
│
├── lib/
│   ├── core/                # App-wide constants, routing, and configurations
│   │   ├── theme/           # Adaptive UI themes (Protan, Deutan, Tritan, Color-Agnostic)
│   │   ├── utils/           # Math helpers (e.g., RGB to HSV converters, Euclidean distance)
│   │   └── constants/       # Hardcoded strings, API limits, and strict WCAG sizing ratios
│   │
│   ├── data/                # Data layer handling local NoSQL persistence
│   │   ├── models/          # User_Profile, Diagnostic_Data, Adaptive_UI_Settings
│   │   └── local/           # Hive or Isar database initialization and query logic
│   │
│   ├── services/            # Isolated integrations for hardware and third-party packages
│   │   ├── camera/          # Low-latency camera streaming and frame extraction
│   │   ├── ml_kit/          # Offline Google ML Kit wrappers (Object/Text Recognition)
│   │   ├── audio/           # Flutter_tts multi-modal voice feedback system
│   │   └── rendering/       # Flutter Impeller engine hooks for compiling GLSL shaders
│   │
│   ├── features/            # The core functional modules of the application
│   │   ├── onboarding/      # App introduction, permissions, and Terms & Conditions
│   │   ├── assessment/      # The Farnsworth D-15 drag-and-drop diagnostic tool
│   │   ├── vision_static/   # Image uploading and static Daltonization processing
│   │   ├── vision_live/     # Real-time camera feeds, KNN color ID, and Daltonization
│   │   └── educational/     # Articles detailing CVD types, severity, and awareness
│   │
│   └── main.dart            # Application entry point and service initialization
│
├── pubspec.yaml             # Dependency management (flutter_tts, camera, hive, etc.)
└── README.md                # Project documentation and setup instructions
```
