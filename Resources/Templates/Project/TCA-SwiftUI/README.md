
./Resources/Tools/XcodeGen/.build/debug/XcodeGen -s ./Resources/XcodeGen/Project.yml -p ~/iOS_Development/Example\ Projects/TCA-SampleProjects -r ~/iOS_Development/Example\ Projects/TCA-SampleProjects

### TODO
- Develop Command Line Tool equivalent with below tests.
  - Creating each target alone at ~/Desktop/<projectName>.
  - Creating multiple target project at ~/Desktop/<projectName>.
  - Creating multiple target project at ~/Desktop/space test/<projectName>.
  - Check *.template contents.
  - Check file existences.

- TODO: iOS 13(UIKit) Support
  https://stackoverflow.com/questions/62880536/supporting-different-lifecycle-methods-in-same-multiplatformios-macos-watchos

- two options for schemes, plist, xcconfig (xcodegen, manual)
- create example counter project for template.

# Design Notes
## Project
- Project sources (not packages) shouldn't have any Screen or Client!
- If project sources needs Localization or Resources (Assets) then;
  - Consider creating a new module for that part.
  - Consider placing these Localization and Resources into the Shared module,
    and try to use from there.
- Font support should be implemented via Shared module
  - Example: https://stackoverflow.com/a/62691001/14811879

### init.swift
A swift script that should be run once when project repo is cloned.
- Scan Sources/Packages and updates dependencies in the Resources/XcodeGen/Project.yml.
- Clones and builds Resources/Tools/*.
- Runs XcodeGen.
- Removes default schemes.
- Runs other tools.

### .gitignore
- *.xcodeproj should be ignored because is is created by XcodeGen.
- Sources/Packages/* should be ignored because each package should have own repository.
- Resources/Tools/* should be ignored because tools take up a lot of space, they are downloaded by init.swift.
- Resources/Plist/* should be ignored because they are created by XcodeGen.
- Resources/Entitlements/* should be ignored because they are created by XcodeGen.
- .DS files should be ignored.
- .DS, Sources/.DS, Sources/Packages/.DS, Resources/.DS, Resources/Assets/.DS,
  Resources/XcodeGen/.DS should tracked by git to keep file structure.

### Resources

#### XcodeGen

#### Assets
- Application icon for each target.
- Complication for watchOS.extension target.
- Top Shelf Image for tvOS target.

#### Localization
##### LaunchScreen
- LaunchScreen.storyboard will be used instead of .plist option since
  storyboard has Autolayout, String Localization and much more advantages.
- Localization is not possible in LaunchScreen. Therefore, texts are not recommended.

##### InfoPlist

#### Templates
##### Package
###### Screen
###### Client
- Template can be improved by checking isowords, ComposableCoreMotion, ComposableCoreLocation repositories in https://github.com/pointfreeco/.

##### File

### Sources
#### App
When @main(App) is separated module issues occur in some scenarios;
-  App module platform iOS 13 but Project Target iOS 12.
   - Project compiles and application starts with resources and LaunchScreen appears, afterwards application crashes because App module supports iOS 13+.
   - Compiler doesn't give any warning since Project doesn't have any source but dependencies.
- Building targets second time without cleaning build folder
  - "Application launch for xxx.debug.ios did not return a valid pid nor a launch error." appears on iOS, macOS, tvOS targets.
  - "Embedded binary is not signed with the same certificate as the parent app.
    Verify the embedded binary target's code sign settings match the parent app's." appears on watchOS target.
  - Having `@main` and `ComplicationController` in module causes above errors.
  - Cleaning DerivedSources directory via a Pre-Build Script `rm -rf "$DERIVED_SOURCES_DIR"` changing "CODE_SIGN_IDENTITY" Build Setting for
    targets before each building fixes this error.

#### Packages
- Cross reference(import) should be avoided by following practices;
  - Packages should be structured considering their parent/child relationship in the Packages directory.
  - A Package should never import another package in the same level or above.
  - If PackageScreen needs to import to another PackageScreen to navigate in the same level, that should be
    handled by ParentScreen via parentReducer.

##### Shared
- This package consists of application specific shared code and assets.
  - Foundation & SwiftUI & UIKit Extensions.
  - View Components that are used application wide.
  - Background, button, primary, secondary colors.
  - Application wide icons, fonts, gifs.
- Unlike other packages, Resource targets of Shared package defined as `@_exported import`
  inside `_bundleResources.swift` to expose package resources to the parent packages.

## Package
- The package consists of;
  - Sources(main) target
  - Resources dependencies for each platform(iOS, macOS, tvOS, watchOS).
  - Shared Package Dependency.
  - ComposableArchitecture dependency (Optional).
- Dependencies(HomeScreen, LoginScreen) which are specific to the application should be local(../PackageName).
- Dependencies(ComposableArchitecture, StoreKitClient, SwiftUIHelper) which are not specific to the application should be remote(Github).

### Sources
#### _Package
- `_bundleResources` expose resources bundle which shouldn't be reached by parent module to be used inside module via `@_implementationOnly import`.
- `_device` property can be accessed to find out current platform that application runs.
- `_os` property can be accessed to find out current OS that application runs.

### Resources
- All targets have separate "Resources_<x>OS" directory to cover all scenarios.
  If there was a "Resources" directory shared by all targets then there will be duplicate file names inside
  shared "Resources" and "Resources_<x>OS" directory and compiler will fire error.
  - A common image has different size and quality for large(tvOS, macOS) and small(iOS, watchOS) screen devices.
  - A common image has different size and quality for all targets(iOS, macOS, tvOS, watchOS).
  - A common image has different size and quality only in tvOS.
- `bundle_xOS.swift` consists of a bundle property that is accessed by Sources(main) target to get resources bundle for each platform.
