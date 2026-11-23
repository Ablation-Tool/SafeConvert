import SwiftUI

@main
struct SafeConvertApp: App {
    @Environment(\.colorScheme) private var colorScheme

    var body: some Scene {
        WindowGroup {
            ZStack {
                (colorScheme == .dark
                    ? Color(red: 14.0 / 255.0, green: 15.0 / 255.0, blue: 18.0 / 255.0)
                    : Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 248.0 / 255.0))
                    .ignoresSafeArea()

                SafeConvertView()
                    .ignoresSafeArea(.container, edges: [.bottom, .horizontal])
            }
        }
    }
}
