//
//  DesignSystem.swift
//  FoodTrackerPro
//
//  Created by AI Assistant on 2025-07-28.
//

import SwiftUI

// MARK: - Color Extensions
extension Color {
    // Primary Colors
    static let primaryGreen = Color(red: 0.2, green: 0.7, blue: 0.3)      // #33B34A
    static let primaryWhite = Color.white                                   // #FFFFFF
    
    // Secondary Colors
    static let lightGreen = Color(red: 0.9, green: 0.98, blue: 0.92)      // #E8FAE8
    static let darkGreen = Color(red: 0.15, green: 0.5, blue: 0.2)        // #267A33
    static let accentGreen = Color(red: 0.0, green: 0.8, blue: 0.4)       // #00CC66
    
    // Neutral Colors
    static let backgroundGray = Color(red: 0.98, green: 0.98, blue: 0.98) // #FAFAFA
    static let textGray = Color(red: 0.2, green: 0.2, blue: 0.2)          // #333333
    static let lightGray = Color(red: 0.95, green: 0.95, blue: 0.95)      // #F2F2F2
    
    // Status Colors
    static let successGreen = Color(red: 0.2, green: 0.7, blue: 0.3)      // #33B34A
    static let warningOrange = Color(red: 1.0, green: 0.6, blue: 0.0)     // #FF9900
    static let errorRed = Color(red: 0.9, green: 0.2, blue: 0.2)          // #E53333
}

// MARK: - Font Extensions
extension Font {
    // Headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // Body Text
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    
    // Supporting Text
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Button Styles
struct GreenButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyBold)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.primaryGreen)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.bodyBold)
            .foregroundColor(.primaryGreen)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primaryGreen, lineWidth: 2)
                    .background(Color.primaryWhite)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct WhiteCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.primaryWhite)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func whiteCard() -> some View {
        modifier(WhiteCardStyle())
    }
}

// MARK: - Progress Ring
struct GreenProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat = 8
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.lightGreen, lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.primaryGreen,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: progress)
        }
    }
}

// MARK: - Navigation Bar Style
struct GreenNavigationBar: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        content
            .navigationTitle(title.localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.primaryWhite, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .tint(Color.primaryGreen)
    }
}

extension View {
    func greenNavigationBar(title: String) -> some View {
        modifier(GreenNavigationBar(title: title))
    }
}