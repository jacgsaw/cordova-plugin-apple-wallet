//
//  OnBoarding-Step1.swift
//  Davivienda
//
//  Created by Alejandro Lopez on 13/08/24.
//

import SwiftUI

struct OnBoardingSteps: View {
    @EnvironmentObject var pagesViewModel: PagesViewModel
    
    @State private var currentPage: Int = 0
    
    @State private var pageTitle : String = const.EMPTY_STRING
    @State private var pageSubtitle : String = const.EMPTY_STRING
    @State private var pageImage: String = "image-onBoarding-1"
    
    var body: some View {
        GeometryReader { geo in
            // Background del Onboarding
            ZStack {
                // Imagen de fondo
                Image("image-onBoarding-bg")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.vertical)
                    .frame(width: geo.size.width, height: geo.size.height ,alignment: .top)
                
                // Imagen de la curva
                VStack {
                    Spacer()
                    Image("image-onBoarding-curve")
                        .resizable()
                        .edgesIgnoringSafeArea(.bottom)
                        .scaledToFit()
                        .frame(width: geo.size.width ,alignment: .bottom)
                }
            }
            ZStack {
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 16) {
                            TitleGeneric( text: pageTitle, color: Color.white)
                            TextGeneric(text: pageSubtitle, color: Color.white)
                        }
                        Spacer()
                    }
                    
                    Image(pageImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: .infinity)
                    
                    PageIndicator(currentPage: currentPage)
                        .padding(.bottom, 8)
                    
                    VStack(spacing: 8) {
                        ButtonGeneric(
                            label:  currentPage != 4 ? label.button.next : label.button.sign,
                            action: currentPage != 4 ? nextPage : navigateLogin
                        )
                    
                        if (currentPage != 4 ) {
                            ButtonGeneric(label: label.button.skip, type: .outline, action: navigateLogin)
                        } else {
                            Rectangle().frame(width: 216, height: 40).foregroundColor(Color.clear)
                        }
                    }
                }
                .padding(24)
                .onChange(of: currentPage) { _ in updatePageContent()}
                .onAppear { updatePageContent() }
            }
        }
    }

    private func nextPage() {
        currentPage = (currentPage + 1) % 5
    }

    private func navigateLogin() {
        pagesViewModel.navigate(to: .LOGIN)
    }
    
    private func updatePageContent() {
        switch currentPage {
        case 0:
            pageTitle = label.onBoarding.step1.title
            pageSubtitle = label.onBoarding.step1.subtitle
            pageImage = "image-onBoarding-1"
        case 1:
            pageTitle = label.onBoarding.step2.title
            pageSubtitle = label.onBoarding.step2.subtitle
            pageImage = "image-onBoarding-2"
        case 2:
            pageTitle = label.onBoarding.step3.title
            pageSubtitle = label.onBoarding.step3.subtitle
            pageImage = "image-onBoarding-3"
        case 3:
            pageTitle = label.onBoarding.step4.title
            pageSubtitle = label.onBoarding.step5.subtitle
            pageImage = "image-onBoarding-4"
        default:
            pageTitle = label.onBoarding.step5.title
            pageSubtitle = label.onBoarding.step5.subtitle
            pageImage = "image-onBoarding-5"
        }
    }
}

#Preview {
    OnBoardingSteps()
}
