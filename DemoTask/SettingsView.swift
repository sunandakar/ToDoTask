//
//  SettingsView.swift
//  DemoTask
//
//  Created by Sunanda Kar on 25/02/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("accentColor") private var accentColor: String = "blue" // Default color
    @Environment(\.presentationMode) private var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    let colors: [(name: String, color: Color)] = [
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink)
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                                Toggle("Dark Mode", isOn: $isDarkMode)
                            }
                
                Section(header: Text("Customize Accent Color")) {
                    ForEach(colors, id: \.name) { color in
                        HStack {
                            Text(color.name)
                            Spacer()
                            if accentColor == color.name.lowercased() {
                                Image(systemName: "checkmark")
                            }
                        }
                        .padding()
                        .background(color.color.opacity(0.2))
                        .cornerRadius(8)
                        .onTapGesture {
                            accentColor = color.name.lowercased()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss() // Close the settings screen
                    }
                    .bold()
                }
            }
        }
        }
    }

#Preview {
    SettingsView()
}
