import FirebaseCore
import SwiftUI

// Firebase initialisation
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication
      .LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct GreensideApp: App {
  // Registering Firebase App Delegate
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
  init() {

    // This is all to change the back navigation button
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .base200
    appearance.shadowColor = .clear
    let config = UIImage.SymbolConfiguration(
      pointSize: 22,
      weight: .bold,
      scale: .large
    )
    let backImage = UIImage(
      systemName: "arrow.left",
      withConfiguration: config
    )!
    .withTintColor(
      UIColor(Color.content),
      renderingMode: .alwaysOriginal
    )

    appearance.setBackIndicatorImage(
      backImage,
      transitionMaskImage: backImage
    )
    let backButtonAppearance = UIBarButtonItemAppearance()
    backButtonAppearance.normal.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    backButtonAppearance.highlighted.titleTextAttributes = [
      .foregroundColor: UIColor.clear
    ]
    appearance.backButtonAppearance = backButtonAppearance

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
    UINavigationBar.appearance().tintColor = UIColor(Color.content)
  }

  @StateObject private var authViewModel = AuthViewModel(repo: .shared)

  var body: some Scene {
    WindowGroup {
      RootView()
        .environmentObject(authViewModel)
        .task {
          await authViewModel.bootstrap()
        }
    }
  }
}
