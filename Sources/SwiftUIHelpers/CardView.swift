import SwiftUI

public struct CardStyleConfiguration {
    struct Header: View {
        var body: AnyView
        
        init(_ content: some View) {
            self.body = AnyView(content)
        }
    }
    
    struct Content: View {
        var body: AnyView
        
        init(_ content: some View) {
            self.body = AnyView(content)
        }
    }
    
    let header: Header
    let content: Content
}

public protocol CardStyle {
    associatedtype Body: View
    typealias Configuration = CardStyleConfiguration
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}

struct CardStyleKey: EnvironmentKey {
    static var defaultValue: any CardStyle = OutlinedCardStyle()
}

extension EnvironmentValues {
    var cardStyle: any CardStyle {
        get { self[CardStyleKey.self] }
        set { self[CardStyleKey.self] = newValue }
    }
}

public extension View {
    func cardStyle(_ style: some CardStyle) -> some View {
        self.environment(\.cardStyle, style)
    }
}

public struct OutlinedCardStyle: CardStyle {
    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            configuration.header
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.init(top: 13, leading: 16, bottom: 13, trailing: 16))
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.white)
        )
    }
}

public extension CardStyle where Self == OutlinedCardStyle {
    static var outlined: Self { .init() }
}

public struct CardView<Header: View, Content: View>: View {
    @Environment(\.cardStyle) var style
    
    let header: () -> Header
    let content: () -> Content
    
    public init(
        @ViewBuilder header: @escaping () -> Header,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = header
        self.content = content
    }
    
    public var body: some View {
        let config = CardStyleConfiguration(
            header: .init(self.header()),
            content: .init(self.content())
        )
        
        AnyView(self.style.makeBody(configuration: config))
    }
}

public extension CardView where Header == EmptyView {
    init(
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.header = { EmptyView() }
        self.content = content
    }
}
