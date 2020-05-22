//
//  NowView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 22.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI
import SwiftPI

extension Shape {
    func relativeHeight(_ height: CGFloat) -> some Shape {
        RelativeHeight(shape: self, relativeHeight: height)
    }
    
    func relativeWidth(_ width: CGFloat) -> some Shape {
        RelativeWidth(shape: self, relativeWidth: width)
    }
}

struct RelativeWidth<S: Shape>: Shape {
    var shape: S
    var relativeWidth: CGFloat
    func path(in rect: CGRect) -> Path {
        let childRect = rect.divided(atDistance: relativeWidth * rect.size.width, from: .minXEdge).slice
        return shape
            .path(in: childRect)
    }
}

struct RelativeHeight<S: Shape>: Shape {
    var shape: S
    var relativeHeight: CGFloat
    func path(in rect: CGRect) -> Path {
        let childRect = rect.divided(atDistance: relativeHeight * rect.size.height, from: .maxYEdge).slice
        return shape
            .path(in: childRect)
    }
}

struct SlightlyRoundedRectangle: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: max(rect.width, rect.height) * 0.05)
            .path(in: rect)
    }
    
    
}

struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addLines([
                CGPoint(x: 0, y: rect.midY),
                CGPoint(x: rect.maxX, y: rect.midY)
            ])
        }
    }
}

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

struct VerticalGrid: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
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


struct NowView: View {
    let data: [(String, CGFloat)]
    
    let gradient = LinearGradient(gradient: Gradient(colors: [.systemBlue, .systemTeal, .green]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        let max: Int = self.data.map { $0.0.count }.max() ?? 3
        let maxString = String(repeating: "w", count: max) + "100%"
        
        return VStack {
            Text("Current Mobility vs mid Jan 2020")
                .foregroundColor(.systemTeal)
                .font(.headline)
            
            ScrollView(.vertical, showsIndicators: false) {
                ZStack {
                    HStack {
                        Text(maxString)
                            .opacity(0.001)
                            .font(.caption)
                            .padding(.leading, 6)
                        
                        VerticalGrid()
                            .stroke(Color.tertiary, lineWidth: 0.5)
                    }
                    
                    VStack(spacing: 2) {
                        ForEach(data.indices) { index in
                            HStack {
                                ZStack(alignment: .trailing) {
                                    Text(maxString)
                                        .opacity(0.001)
                                    
                                    //                                    Text(self.data[index].0)
                                    Text("\(self.data[index].0), \(Double(self.data[index].1).formattedPercentage)")
                                }
                                .foregroundColor(.secondary)
                                .font(.caption)
                                .padding(.leading, 6)
                                
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .relativeWidth(self.data[index].1)
                                    .fill(self.gradient)
                                    .frame(height: 10)
                            }
                        }
                    }
                }
            }
        }
        .padding(.trailing)
    }
}

struct NowViewTesting: View {
    
    let data: [(String, CGFloat)] = [
        ("Moscow", 0.51),
        ("Rome", 0.75),
        ("Italy", 0.8),
        ("London", 0.6),
        ("Paris", 0.5),
        ("France", 0.15),
        ("Nice", 0.3),
        ("US", 0.4),
        ("China", 0.2),
        ("UK", 0.7),
        ("Brazil", 0.3),
        ("Chile", 0.7),
        ("Berlin", 0.9),
        ("Bonn", 0.95),
        ].sorted(by: { $0.1 > $1.1 })
    
    var body: some View {
        NowView(data: data)
    }
}

struct NowView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            NowViewTesting()
        }
        .environment(\.colorScheme, .dark)
    }
}
