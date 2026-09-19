//
//  ContentView.swift
//  missileUSB
//
//  Created by David Fekke on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    let usbController = AirCannon()

    var body: some View {
        VStack(spacing: 28) {
            LauncherHeader()

            DirectionPad(
                moveUp: { setMovement(.up, isPressed: $0) },
                moveDown: { setMovement(.down, isPressed: $0) },
                moveLeft: { setMovement(.left, isPressed: $0) },
                moveRight: { setMovement(.right, isPressed: $0) },
                stop: stop
            )

            FireButton(action: fire)
        }
        .frame(minWidth: 320, minHeight: 360)
        .padding(32)
    }

    private func setMovement(_ direction: CannonDirection, isPressed: Bool) {
        if isPressed {
            usbController.startMoving(direction)
        } else {
            usbController.stopMoving()
        }
    }

    private func stop() {
        Task {
            usbController.stopMoving()
        }
    }

    private func fire() {
        Task {
            await usbController.fireAndWait {}
        }
    }
}

struct LauncherHeader: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "scope")
                .font(.system(size: 42, weight: .semibold))
                .foregroundStyle(.secondary)

            Text("Missile USB")
                .font(.title.bold())

            Text("Launcher Control")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct DirectionPad: View {
    let moveUp: (Bool) -> Void
    let moveDown: (Bool) -> Void
    let moveLeft: (Bool) -> Void
    let moveRight: (Bool) -> Void
    let stop: () -> Void

    var body: some View {
        Grid(horizontalSpacing: 10, verticalSpacing: 10) {
            GridRow {
                Color.clear
                    .frame(width: 82, height: 68)

                ControlButton(title: "Up", systemImage: "arrow.up", onPressChanged: moveUp)

                Color.clear
                    .frame(width: 82, height: 68)
            }

            GridRow {
                ControlButton(title: "Left", systemImage: "arrow.left", onPressChanged: moveLeft)
                StopButton(action: stop)
                ControlButton(title: "Right", systemImage: "arrow.right", onPressChanged: moveRight)
            }

            GridRow {
                Color.clear
                    .frame(width: 82, height: 68)

                ControlButton(title: "Down", systemImage: "arrow.down", onPressChanged: moveDown)

                Color.clear
                    .frame(width: 82, height: 68)
            }
        }
    }
}

struct ControlButton: View {
    let title: LocalizedStringKey
    let systemImage: String
    let onPressChanged: (Bool) -> Void

    @State private var isPressed = false

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(width: 82, height: 68)
        .contentShape(RoundedRectangle(cornerRadius: 8))
        .launcherButton(isPressed: isPressed)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            perform: {},
            onPressingChanged: updatePressState
        )
        .accessibilityAddTraits(.isButton)
    }

    private func updatePressState(_ isPressed: Bool) {
        guard self.isPressed != isPressed else { return }
        self.isPressed = isPressed
        onPressChanged(isPressed)
    }
}

struct StopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: "stop.fill")
                    .font(.title3.weight(.bold))
                Text("Stop")
                    .font(.caption.weight(.semibold))
            }
            .frame(width: 82, height: 68)
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(LauncherButtonStyle(foregroundStyle: .red, backgroundOpacity: 0.14))
    }
}

struct FireButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label("Fire", systemImage: "flame.fill")
                .font(.title3.weight(.bold))
                .frame(maxWidth: 246)
                .padding(.vertical, 14)
                .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(LauncherButtonStyle(foregroundStyle: .white, backgroundStyle: .red, backgroundOpacity: 1))
        .keyboardShortcut(.defaultAction)
    }
}

struct LauncherButtonStyle: ButtonStyle {
    var foregroundStyle: Color = .primary
    var backgroundStyle: Color = .secondary
    var backgroundOpacity = 0.1

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .launcherButton(
                isPressed: configuration.isPressed,
                foregroundColor: foregroundStyle,
                backgroundColor: backgroundStyle,
                backgroundOpacity: backgroundOpacity
            )
    }
}

private extension View {
    func launcherButton(
        isPressed: Bool,
        foregroundColor: Color = .primary,
        backgroundColor: Color = .secondary,
        backgroundOpacity: Double = 0.1
    ) -> some View {
        foregroundStyle(foregroundColor)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor.opacity(isPressed ? backgroundOpacity * 1.5 : backgroundOpacity))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(backgroundColor.opacity(isPressed ? 0.35 : 0.18))
            }
            .scaleEffect(isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.12), value: isPressed)
    }
}

#Preview {
    ContentView()
}
