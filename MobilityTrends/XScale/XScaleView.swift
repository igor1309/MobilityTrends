//
//  XScaleView.swift
//  MobilityTrends
//
//  Created by Igor Malyarov on 11.05.2020.
//  Copyright © 2020 Igor Malyarov. All rights reserved.
//

import SwiftUI

//  https://bestkora.com/IosDeveloper/swiftui-dlya-konkursnogo-zadaniya-telegram-10-24-marta-2019-goda/

struct XScaleView: View {
    let estimatedMarksNumber = 6
    //  MARK: potential to use with PreferenceKey
    var labelWidth: CGFloat = 50
    let labelHeight: CGFloat = 28
    
    var labels: [String]
    
    func scale(width: CGFloat) -> [Int] {
        let numberOfLabelsPerSegment = Int(labelWidth * CGFloat(labels.count) / width)
        let indices = labels.indices.filter { $0 % numberOfLabelsPerSegment == 0 }
        return indices
    }
    
    func segmentWidth(for index: Int, scaleWidth: CGFloat) -> CGFloat {
        let numberOfWholeSegmentsOnAxis = Int(scaleWidth / labelWidth)
        let widthIndex = CGFloat(index) / CGFloat(labels.count) * scaleWidth
        if widthIndex <= labelWidth * CGFloat(numberOfWholeSegmentsOnAxis - 1) {
            return labelWidth
        } else {
            let reminder = scaleWidth - labelWidth * CGFloat(numberOfWholeSegmentsOnAxis)
            return reminder
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(self.scale(width: geo.size.width), id: \.self) { index in
                    XMarkView(label: self.labels[index])
                        .frame(width: self.segmentWidth(for: index, scaleWidth: geo.size.width),
                               height: self.labelHeight)
                }
            }
        }
        .opacity(0.8)
        .frame(height: labelHeight)
        .offset(y: -4)
    }
}

fileprivate struct XAxisLine: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.width, y: 0))
        }
    }
}

struct XScaleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            XScaleView(labels: ["2020-01-13", "2020-01-14", "2020-01-15", "2020-01-16", "2020-01-17", "2020-01-18", "2020-01-19", "2020-01-20", "2020-01-21", "2020-01-22", "2020-01-23", "2020-01-24", "2020-01-25", "2020-01-26", "2020-01-27", "2020-01-28", "2020-01-29", "2020-01-30", "2020-01-31", "2020-02-01", "2020-02-02", "2020-02-03", "2020-02-04", "2020-02-05", "2020-02-06", "2020-02-07", "2020-02-08", "2020-02-09", "2020-02-10", "2020-02-11", "2020-02-12", "2020-02-13", "2020-02-14", "2020-02-15", "2020-02-16", "2020-02-17", "2020-02-18", "2020-02-19", "2020-02-20", "2020-02-21", "2020-02-22", "2020-02-23", "2020-02-24", "2020-02-25", "2020-02-26", "2020-02-27", "2020-02-28", "2020-02-29", "2020-03-01", "2020-03-02", "2020-03-03", "2020-03-04", "2020-03-05", "2020-03-06", "2020-03-07", "2020-03-08", "2020-03-09", "2020-03-10", "2020-03-11", "2020-03-12", "2020-03-13", "2020-03-14", "2020-03-15", "2020-03-16", "2020-03-17", "2020-03-18", "2020-03-19", "2020-03-20", "2020-03-21", "2020-03-22", "2020-03-23", "2020-03-24", "2020-03-25", "2020-03-26", "2020-03-27", "2020-03-28", "2020-03-29", "2020-03-30", "2020-03-31", "2020-04-01", "2020-04-02", "2020-04-03", "2020-04-04", "2020-04-05", "2020-04-06", "2020-04-07", "2020-04-08", "2020-04-09", "2020-04-10", "2020-04-11", "2020-04-12", "2020-04-13", "2020-04-14", "2020-04-15", "2020-04-16", "2020-04-17", "2020-04-18", "2020-04-19", "2020-04-20", "2020-04-21", "2020-04-22", "2020-04-23", "2020-04-24", "2020-04-25", "2020-04-26", "2020-04-27", "2020-04-28", "2020-04-29", "2020-04-30", "2020-05-01", "2020-05-02", "2020-05-03", "2020-05-04", "2020-05-05", "2020-05-06", "2020-05-07", "2020-05-08", "2020-05-09"])
                .overlay(XAxisLine().stroke(Color.tertiary, lineWidth: 1))
                .padding()
        }
        .environment(\.colorScheme, .dark)
    }
}
