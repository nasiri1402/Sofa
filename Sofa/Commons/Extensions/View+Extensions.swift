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

    func toast(item: ToastItem?) -> some View {
        self
            .overlay(alignment: .top) {
                if let item {
                    Toast(item: item)
                        .padding(.vertical, 12.fitW)
                        .padding(.horizontal, 24.fitW)
                        .transition(.asymmetric(
                            insertion: .move(edge: .top)
                                .combined(with: .scale(scale: 0.94, anchor: .top))
                                .combined(with: .opacity),
                            removal: .move(edge: .top)
                                .combined(with: .scale(scale: 0.96, anchor: .top))
                                .combined(with: .opacity)
                        ))
                        .zIndex(10)
                }
            }
            .animation(.spring(duration: 0.35, bounce: 0.5), value: item?.id)
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
    ///   - duration: Продолжительность анимации эффекта. По умолчанию `1.5`.
    ///   - delay: Задержка анимации эффекта. По умолчанию `0.3`.
    ///   - gradient: Градиент для эффекта переливания. По умолчанию градиент состоит из `clear`, `white` и `clear`.
    ///   - bandWidth: Ширина "полосы". По умолчанию `1`.
    ///   - mode: Режим применения эффекта. По умолчанию `mask`.
    /// - Note: Для эффекта используется анимация `linear` c бесконечным повторением без обратного воспроизведения.
    @ViewBuilder
    func shimmering(
        isActive: Bool = true,
        duration: CGFloat = 1.5,
        delay: CGFloat = 0.3,
        gradient: Gradient = Gradient(colors: [.clear, .white, .clear]),
        bandWidth: CGFloat = 1.fitW,
        mode: ShimmerModifier.Mode = .mask
    ) -> some View {
        if isActive {
            modifier(ShimmerModifier(
                animation: .linear(duration: duration).delay(delay).repeatForever(autoreverses: false),
                gradient: gradient,
                bandWidth: bandWidth,
                mode: mode
            ))
        } else {
            self
        }
    }

    func wakeLock() -> some View {
        modifier(WakeLockModifier())
    }
}
