//
//  Grids+Scales.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 30.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

struct HorizontalScale: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addLines([
                CGPoint(x: rect.minX, y: rect.midY),
                CGPoint(x: rect.maxX, y: rect.midY)
            ])
            
            path.addLines([
                CGPoint(x: rect.minX, y: rect.minY),
                CGPoint(x: rect.minX, y: rect.maxY)
            ])
            
            path.addLines([
                CGPoint(x: rect.midX/2, y: rect.minY),
                CGPoint(x: rect.midX/2, y: rect.maxY)
            ])
            
            path.addLines([
                CGPoint(x: rect.midX, y: rect.minY),
                CGPoint(x: rect.midX, y: rect.maxY)
            ])
            
            path.addLines([
                CGPoint(x: rect.midX/2*3, y: rect.minY),
                CGPoint(x: rect.midX/2*3, y: rect.maxY)
            ])
            
            path.addLines([
                CGPoint(x: rect.maxX, y: rect.minY),
                CGPoint(x: rect.maxX, y: rect.maxY)
            ])
        }
    }
}

struct VerticalGridQuarters: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            
            for i in 0...4 {
                path.addLines([
                    CGPoint(x: rect.maxX/4 * CGFloat(i), y: rect.minY),
                    CGPoint(x: rect.maxX/4 * CGFloat(i), y: rect.maxY)
                ])
            }
        }
    }
}

struct VerticalGridFives: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            for i in 1...5 {
                path.addLines([
                    CGPoint(x: rect.maxX/5 * CGFloat(i), y: rect.minY),
                    CGPoint(x: rect.maxX/5 * CGFloat(i), y: rect.maxY)
                ])
            }
        }
    }
}


struct Grids_Scales_Previews: PreviewProvider {
    static let xMax: CGFloat = 1.3
    
    static var previews: some View {
        Group {
            VerticalGridFives()
                .relativeWidth(1 / xMax)
                .stroke(Color.yellow)
            
            VerticalGridQuarters()
                .stroke(Color.pink)
            
            HorizontalScale()
                .stroke(Color.blue.opacity(0.5), lineWidth: 1)
        }
        .padding()
        .frame(height: 300)
        .previewColorSchemes(.dark)
    }
}
