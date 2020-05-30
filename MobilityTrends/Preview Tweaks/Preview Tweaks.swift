//
//  Preview Tweaks.swift
//  TestingAreaCharts
//
//  https://swiftbysundell.com/articles/getting-the-most-out-of-xcode-previews/
//

import SwiftUI

extension ColorScheme {
    var previewName: String {
        String(describing: self).capitalized
    }
}

extension ContentSizeCategory {
    static let smallestAndLargest = [allCases.first!, allCases.last!]
    
    var previewName: String {
        self == Self.smallestAndLargest.first ? "Small" : "Large"
    }
}

extension ForEach where Data.Element: Hashable, ID == Data.Element, Content: View {
    init(values: Data, content: @escaping (Data.Element) -> Content) {
        self.init(values, id: \.self, content: content)
    }
}

struct ComponentPreview<Component: View>: View {
    var component: Component
    
    var body: some View {
        ForEach(values: ColorScheme.allCases) { scheme in
            ForEach(values: ContentSizeCategory.smallestAndLargest) { category in
                self.component
                    .previewLayout(.sizeThatFits)
                    .background(Color(UIColor.systemBackground))
                    .colorScheme(scheme)
                    .environment(\.sizeCategory, category)
                    .previewDisplayName(
                        "\(scheme.previewName) + \(category.previewName)"
                )
            }
        }
    }
}

extension View {
    func previewAsComponent() -> some View {
        ComponentPreview(component: self)
    }
}

//  MARK: - ColorScheme

extension View {
    func previewColorSchemes() -> some View {
        ColorSchemesComponentPreview(component: self)
    }
    
    func previewColorSchemes(_ colorScheme: ColorScheme) -> some View {
        ColorSchemesComponentPreview(colorScheme: colorScheme, component: self)
    }
}

struct ColorSchemesComponentPreview<Component: View>: View {
    var component: Component
    var colorSchemes: [ColorScheme]
    
    init(colorScheme: ColorScheme, component: Component) {
        self.component = component
        self.colorSchemes = [colorScheme]
    }
    
    init(component: Component) {
        self.component = component
        self.colorSchemes = ColorScheme.allCases
    }
    
    var body: some View {
        ForEach(values: colorSchemes) { scheme in
            self.component
                .previewLayout(.sizeThatFits)
                .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
                .colorScheme(scheme)
                .previewDisplayName(scheme.previewName)
        }
    }
}
