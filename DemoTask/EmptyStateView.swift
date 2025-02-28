//
//  EmptyStateView.swift
//  DemoTask
//
//  Created by Sunanda Kar on 26/02/25.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)

            Text("No tasks yet!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("Stay productive by adding your first task.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            NavigationLink(destination: AddTaskItemView()) {
                Label("Add a Task", systemImage: "plus")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}


#Preview {
    EmptyStateView()
}
