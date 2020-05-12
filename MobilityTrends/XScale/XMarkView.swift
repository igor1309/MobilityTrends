//
//  XMarkView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 11.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//


import SwiftUI

//  https://www.hackingwithswift.com/books/ios-swiftui/adding-strokeborder-support-with-insettableshape
fileprivate struct TickMark: InsettableShape {
    var insetAmount: CGFloat = 0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var tickMark = self
        tickMark.insetAmount += amount
        return tickMark
    }
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0 + insetAmount, y: 0 + insetAmount))
            path.addLine(to: CGPoint(x: 0 + insetAmount, y: 10 + insetAmount))
        }
    }
}

//  https://bestkora.com/IosDeveloper/swiftui-dlya-konkursnogo-zadaniya-telegram-10-24-marta-2019-goda/
struct XMarkView: View {
    var label: String
    
    func reverseStringDate(_ str: String) -> String {
        return String(str.suffix(2)) + "." + String(str.dropLast(3).suffix(2))
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 3) {
                TickMark()
                    .strokeBorder(Color.secondary, lineWidth: 0.5)
                    .opacity(0.8)
                
                Text(verbatim: self.reverseStringDate(self.label))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct XMarkView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 0) {
            XMarkView(label: "20.05")
                .frame(width: 100, height: 24)
            XMarkView(label: "20.05")
                .frame(width: 100, height: 30)
        }
    }
}
