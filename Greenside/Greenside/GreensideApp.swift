import SwiftUI

@main
struct GreensideApp: App {
  init() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = .base200
    appearance.shadowColor = .clear

    // Custom back button image with hierarchical rendering style
    let backImage = UIImage(
      systemName: "arrow.left.square.fill",
      withConfiguration: UIImage.SymbolConfiguration(
        hierarchicalColor: .accentGreen
      )
    )?.withRenderingMode(.alwaysTemplate)

    appearance.setBackIndicatorImage(
      backImage,
      transitionMaskImage: backImage
    )

    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
  }
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
