import SwiftUI

enum PageStore: String {
    case ON_BOARGING
    case LOGIN
    case HOME
}

final class PagesViewModel: ObservableObject {
    @Published var pageMain: PageStore = .ON_BOARGING
    @Published var pageLogin: PageStore = .LOGIN
    @Published var navigationStack: [PageStore] = []
        
    let views: [PageStore: AnyView] = [
        .ON_BOARGING: AnyView(OnBoarding()),
        .LOGIN: AnyView(LoginActivity{_ in}),
    ]
    
    func navigate(to page: PageStore) {
        navigationStack.append(pageLogin)
        pageMain = page
    }
    
    func goBack() {
        if let lastPage = navigationStack.popLast() {
            pageMain = lastPage
        }
    }
}
