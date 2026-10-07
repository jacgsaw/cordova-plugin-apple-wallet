import SwiftUI

struct HorizontalScrollView<Content: View>: View {
    @State private var offset: CGFloat = 0.0
    @State private var contentWidth: CGFloat = 0.0
    @State private var scrollViewWidth: CGFloat = 0.0
    
    var items: [Content]
    
    var body: some View {
        GeometryReader { geometry in
            if items.count == 1 {
                HStack {
                    Spacer()
                    items[0]
                    Spacer()
                }
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        // Obtener el ancho del contenido del ScrollView
                        GeometryReader { contentGeometry in
                            Color.clear.onAppear {
                                self.contentWidth = contentGeometry.frame(in: .named("scroll")).width
                            }
                        }
                        .frame(width: 0) // No ocupa espacio, solo obtiene el ancho del contenido
                        
                        HStack(spacing: 8) {
                            ForEach(0..<items.count, id: \.self) { index in
                                items[index]
                            }
                        }
                    }
                    .background(
                        GeometryReader { proxy -> Color in
                            DispatchQueue.main.async {
                                self.scrollViewWidth = proxy.frame(in: .named("scroll")).width
                            }
                            return Color.clear
                        }
                    )
                    .padding(.leading, self.offset <= 0 ? 16 : 0)
                    .padding(.trailing, self.offset >= self.contentWidth - self.scrollViewWidth ? 16 : 0)
                }
                .coordinateSpace(name: "scroll")
                .background(GeometryReader {
                    Color.clear.preference(key: ScrollOffsetKey.self, value: -$0.frame(in: .named("scroll")).origin.x)
                })
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    self.offset = value
                }
            }
        }
    }
}

struct ScrollOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
