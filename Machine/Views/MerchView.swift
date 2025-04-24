//
//  MerchView.swift
//  Machine
//
//  Created by Erik Kaniecki on 4/21/25.
//

import SwiftUI

struct MerchView: View {
    var body: some View {
        VStack {
            Image("MerchImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 400, height: 170)
        }
    }
}

#Preview {
    MerchView()
}
