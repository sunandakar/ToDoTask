//
//  CircularProgressView.swift
//  DemoTask
//
import SwiftUI

struct CircularProgressView: View {
    var progress: Double // 0 to 1 (e.g., 0.75 for 75%)
    var color: Color = .blue // Customize color based on filter type
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    color.opacity(0.3), // Background circle with transparency
                    lineWidth: 10
                )
            
            Circle()
                .trim(from: 0.0, to: progress) // Trim for progress
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 10, lineCap: .round)
                )
                .rotationEffect(.degrees(-90)) // Start from top
                .animation(.easeInOut(duration: 0.5), value: progress) // Smooth animation
            
            // Percentage Label
            Text("\(Int(progress * 100))%")
                .font(.headline)
                .bold()
                .foregroundColor(color)
        }
        .frame(width: 80, height: 80)
    }
}



//#Preview {
//    CircularProgressView(progress: progress)
//}
