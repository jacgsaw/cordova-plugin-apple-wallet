//
//  CardPromotionsHome.swift
//  HelloWorldXcode
//
//  Created by Alejandro Lopez on 3/08/24.
//

import SwiftUI

struct CardPromotionsType {
    let text1: String
    let text2: String
    let text3: String?
    let text4: String
    let style: String
    let action: () -> Void
}

let cardPromotions: [CardPromotionsType] = [
    CardPromotionsType(
        text1: "Ahora puede financiar su vehículo fácilmente",
        text2: "Conozca las nuevas tasas para crédito de vehículo 2023",
        text3: "*Aplican términos y condiciones",
        text4: "Aplique ya",
        style: "3",
        action: {}
    ),
    CardPromotionsType(
        text1: "Estimado cliente 😎",
        text2: "Tiene un Crédito Móvil aprobado por $2.700",
        text3: "Oferta válida hasta el 13(04/2024",
        text4: "Saber más",
        style: "2",
        action: {}
    ),
    CardPromotionsType(
        text1: "Financie su Vivienda",
        text2: "Solicite su préstamo de Vivienda en minutos.",
        text3: nil,
        text4: "Ver más",
        style: "1",
        action: {}
    )
]

struct CardPromotionsHome: View {
    let item: CardPromotionsType
        
    var body: some View {
        Button(action: {
            item.action()
        }) {
            ZStack {
                HStack {
                    Spacer()
                    Image("image-promotions-bg-path-1")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 194, height: 160)
                }

                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image("image-promotions-bg-path-2")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 167, height: 145)
                    }
                }
                
                VStack(spacing: 0) {
                    HStack() {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(item.text1)
                                .font(.custom("Roboto-Bold", size: 16))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)

                            Text(item.text2)
                                .font(.custom("Roboto-Medium", size: 12))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)

                            if let text = item.text3 {
                                Text(text)
                                    .font(.custom("Roboto-Regular", size: 10))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 8)
                            }
                        }
                        .frame(maxWidth: 168, alignment: .leading)

                        Spacer()

                        VStack {
                            Spacer()

                            Image(
                                item.style == "1" ? "image-promotions-1" :
                                item.style == "2" ? "image-promotions-2" :
                                item.style == "3" ? "image-promotions-2" :
                                item.style == "4" ? "image-promotions-2" :
                                item.style == "5" ? "image-promotions-1" :
                                "image-promotions-2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 96)
                        }
                    }
                    .padding(.leading, 16)
                    .frame(width: 288, height: 128)
                    
                    HStack {
                        VStack {
                            Spacer()
                            Text(item.text4)
                                .font(.custom("Roboto-Medium", size: 12))
                                .foregroundColor(.black800)
                            Spacer()
                        }.padding(.leading, 16)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black800)
                            .padding(.trailing, 8)
                    }
                    .background(.white)
                    .frame(width: 288, height: 32)
                }
            }
            .background(
                item.style == "1" ? Color.red000 :
                item.style == "2" ? Color.black900 :
                item.style == "3" ? Color.blue000 :
                item.style == "4" ? Color.green000 :
                item.style == "5" ? Color.orange1000 :
                .gray000
            )
            .frame(width: 288, height: 160)
            .cornerRadius(8)
        }
    }
}

#Preview {
    CardPromotionsHome(item: CardPromotionsType(text1: "Amzamzamzmamzmzamazmzamazmazmaz", text2: "Amzamzamzmamzmzamazmzamazmazmaz", text3: "**Amzamzamzmamzmzamazamz", text4: "Amzamzam zmamzm", style: "3", action: {}))
}
