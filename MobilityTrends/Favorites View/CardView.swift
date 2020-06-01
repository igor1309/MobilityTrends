//
//  CardView.swift
//  TestingAreaCharts
//
//  Created by Igor Malyarov on 24.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

struct CardView<Content: View>: View {
    let background: Color
    let blurRadius: CGFloat
    let cornerRadius: CGFloat
    let animation: Animation
    let content: () -> Content
    
    init(cornerRadius: CGFloat = 10,
         background: Color = Color.quaternarySystemFill,
         blurRadius: CGFloat = 0,
         animation: Animation = .default,
         @ViewBuilder content: @escaping () -> Content) {
        
        self.cornerRadius = cornerRadius
        self.background = background
        self.blurRadius = blurRadius
        self.animation = animation
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(10)
            .background(background.blur(radius: blurRadius))
            .cornerRadius(cornerRadius)
            .transition(.move(edge: .top))
            .animation(animation)
    }
}


struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<5) { _ in
                        CardView(cornerRadius: 32, background: Color.blue, blurRadius: 40) {
                            
                            Text("Card")
                                .frame(width: 100, height: 100)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                .border(Color.pink.opacity(0.2))
                .frame(height: 200)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<5) { _ in
                        CardView {
                            Color.purple.opacity(0.1)
                        }
                        .aspectRatio(3/4, contentMode: .fit)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                .border(Color.pink.opacity(0.2))
                .frame(height: 200)
            }
            
            CardView {
                Color.blue.opacity(0.3)
            }
            .frame(width: 200, height:  300)
        }
    }
}
