//
//  WeatherButton.swift
//  SwiftUI-Weather
//
//  Created by kangajan kuganathan on 2024-10-24.
//

import Foundation
import SwiftUI

struct WeatherButton: View {
    var imageName: String
    var textColor: Color
    var backgroundColor: Color
    var isNight: Bool
    var body: some View {
        Image(systemName: imageName)
            .frame(width: 50, height: 50)
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.multicolor)
            .background(isNight ? Color.gray.gradient : Color.orange.gradient)
            .cornerRadius(10)
    }
}
