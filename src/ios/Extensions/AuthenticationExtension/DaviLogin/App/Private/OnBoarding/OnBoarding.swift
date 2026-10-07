//
//  OnBoarding.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 2/08/24.
//

import SwiftUI

struct OnBoarding: View {
    @EnvironmentObject var pagesViewModel: PagesViewModel
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background del Onboarding
                Image("image-onBoarding-bg")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .topLeading)
                // Imagen del cliente
                VStack {
                    Spacer()
                    Image("image-onBoarding-client")
                        .resizable()
                        .scaledToFit()
                        .frame(height: geo.size.height * 0.5)
                        .padding(.bottom, geo.size.height * 0.11)
                }
                // Imagen de la curva
                VStack {
                    Spacer()
                    Image("image-onBoarding-curve")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.bottom)
                        .scaledToFit()
                }
                // Icono y texto guia
                VStack(alignment: .leading, spacing: 16) {
                    Image("icon-logo-davivienda-white")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 40)
                    Text(label.onBoarding.title)
                        .font(.custom("Roboto-Medium", size: 22))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Text(label.onBoarding.subtitle)
                        .font(.custom("Roboto-Medium", size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color.white)
                    Spacer()
                }
                .frame(maxWidth: geo.size.width, alignment: .leading)
                .padding([.leading, .top], 24)
                
                // Botones
                VStack {
                    Spacer()
                    
                    ButtonGeneric(label: label.button.client){pagesViewModel.navigate(to: .LOGIN)}
                    
                    ButtonGeneric(label: label.button.notClient, type: .outline){pagesViewModel.navigate(to: .LOGIN)}
                }
                .padding(.bottom, 24)
            }
        }
    }
}

#Preview {
    OnBoarding().environmentObject(PagesViewModel())
}
