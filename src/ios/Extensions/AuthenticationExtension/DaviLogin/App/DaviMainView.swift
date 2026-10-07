import SwiftUI

public struct DaviMainView: View {
    @StateObject var pagesViewModel: PagesViewModel = PagesViewModel()
    
    public init() {}
    
    public var body: some View {
        Group {
            if let currentView = pagesViewModel.views[pagesViewModel.pageLogin] {
                currentView
            } else {
                Text("Vista no encontrada")
            }
        }
        .environmentObject(pagesViewModel)
        .onChange(of: pagesViewModel.pageLogin) { newValue in
            print("page changed to \(newValue)")
        }
        .onChange(of: pagesViewModel.navigationStack) { value in
            print(value)
        }
    }
}

public class DaviLoginManager {
    public init() {}
    public func prueba() -> String {
        return "DaviLogin funcionando"
    }
}


#Preview {
    DaviMainView()
}
