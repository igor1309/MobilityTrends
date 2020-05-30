//
//  Shape+Relative.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 30.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

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
