//
//  ShimmerModifier.swift
//  Sofa
//
//  Created by dukes on 5/19/26.
//

import SwiftUI

struct ShimmerModifier: ViewModifier {

    // MARK: - Public Properties

    let animation: Animation
    let gradient: Gradient
    let bandWidth: CGFloat
    let mode: Mode

    // MARK: - Private Properties

    @State private var isInitialState = true

    private var startPoint: UnitPoint {
         isInitialState ? UnitPoint(x: -bandWidth, y: 0) : UnitPoint(x: 1 + bandWidth, y: 0)
     }

     private var endPoint: UnitPoint {
         isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: 1 + bandWidth, y: 0)
     }

    // MARK: - Body

    func body(content: Content) -> some View {
        ApplyingGradient(to: content)
            .animation(animation, value: isInitialState)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    isInitialState = false
                }
            }
    }

    // MARK: - Views

    @ViewBuilder
    private func ApplyingGradient(to content: Content) -> some View {
        let gradient = LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        switch mode {
        case .mask: content.mask(gradient)
        case .overlay(let blendMode): content.overlay(gradient.blendMode(blendMode))
        case .background: content.background(gradient)
        }
    }
}

extension ShimmerModifier {

    // MARK: - Mode

    enum Mode {
        case mask, background
        case overlay(BlendMode = .sourceAtop)
    }
}
