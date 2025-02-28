import SwiftUI

class ThemeManager: ObservableObject {
    @AppStorage("isDarkMode") var isDarkMode: Bool = false {
        willSet { objectWillChange.send() }
    }
}
