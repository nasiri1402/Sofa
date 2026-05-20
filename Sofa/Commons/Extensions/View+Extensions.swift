//
//  View+Extensions.swift
//  Sofa
//
//  Created by dukes on 11/3/25.
//

import SwiftUI

extension View {
    func navigationBarLeadingButton(icon: ImageResource, action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: action) {
                    Image(icon)
                        .resizable()
                        .frame(width: 24.fitW, height: 24.fitW)
                        .animation(.easeInOut, value: icon)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func navigationBarTrailingButton(icon: ImageResource, action: @escaping () -> Void) -> some View {
        toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: action) {
                    Image(icon)
                        .resizable()
                        .frame(width: 24.fitW, height: 24.fitW)
                        .animation(.easeInOut, value: icon)
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
            }
        }
    }

    func textFieldAlert(item: Binding<TextFieldAlertItem?>) -> some View {
        alert(
            item.wrappedValue?.title ?? "",
            isPresented: Binding(
                get: { item.wrappedValue != nil },
                set: {
                    guard !$0 else { return }
                    item.wrappedValue = nil
                }
            )
        ) {
            TextField(
                item.wrappedValue?.placeholder ?? "",
                text: Binding(
                    get: { item.wrappedValue?.inputText ?? "" },
                    set: { item.wrappedValue?.inputText = $0 }
                )
            )
            Button(String(localized: "cancel"), role: .cancel) {
                item.wrappedValue = nil
            }
            Button(item.wrappedValue?.submitTitle ?? "") {
                item.wrappedValue?.onSubmit(item.wrappedValue?.inputText ?? "")
                item.wrappedValue = nil
            }
        } message: {
            Text(item.wrappedValue?.message ?? "")
        }
    }

    func plainListRowStyle() -> some View {
        self
            .listRowInsets(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: .zero))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
    }
}

// MARK: - Modifiers

extension View {
    /// Добавляет тактильную отдачу к представлению в зависимости от указанного типа.
    /// - Parameters:
    ///  - feedbackType: Тип тактильной отдачи. По умолчанию `impact.light`.
    ///  - isEnabled: Активна ли тактильная отдача. По умолчанию `true`.
    func hapticFeedback(
        _ feedbackType: HapticFeedbackType = .impact(.light),
        isEnabled: Bool = true
    ) -> some View {
        modifier(HapticFeedbackModifier(feedbackType: feedbackType, isEnabled: isEnabled))
    }

    /// Отслеживает высоту клавиатуры и передает её в замыкание.
    /// - Parameter onChange: Замыкание, вызываемое при изменении высоты клавиатуры.
    func onChangeKeyboardHeight(_ onChange: @escaping (CGFloat) -> Void) -> some View {
        modifier(KeyboardHeightModifier(onChange: onChange))
    }

    /// Добавляет анимированный эффект "переливающейся полосы").
    /// - Parameters:
    ///   - isActive: Флаг, для включения эффекта. По умолчанию равен `true`.
    ///   - animation: Анимация. По умолчанию `linear`, продолжительностью `1`, задержкой `0.1` и бесконечным повторением без обратного воспроизведения.
    ///   - gradient: Градиент для эффекта переливания. По умолчанию градиент состоит из `clear`, `white` и `clear`.
    ///   - bandWidth: Ширина "полосы". По умолчанию `1`.
    ///   - mode: Режим применения эффекта. По умолчанию `mask`.
    @ViewBuilder
    func shimmering(
        isActive: Bool = true,
        animation: Animation = .linear(duration: 1).delay(0.1).repeatForever(autoreverses: false),
        gradient: Gradient = Gradient(colors: [.clear, .white, .clear]),
        bandWidth: CGFloat = 1.fitW,
        mode: ShimmerModifier.Mode = .mask
    ) -> some View {
        if isActive {
            modifier(ShimmerModifier(animation: animation, gradient: gradient, bandWidth: bandWidth, mode: mode))
        } else {
            self
        }
    }

    func wakeLock() -> some View {
        modifier(WakeLockModifier())
    }
}
