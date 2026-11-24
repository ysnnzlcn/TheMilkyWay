//
//  Toast.swift
//  CoreUI
//

import CoreAssets
import CoreBase
import SwiftUI

public extension View {

    /// Shows `model` at the bottom; `nil` hides it.
    func toast(model: ToastUIModel?) -> some View {
        overlay(alignment: .bottom) {
            ToastView(model: model)
        }
    }
}

// MARK: UI model

/// What a toast shows. Toasts only inform: they never have a button. Two models with the same text and status are
/// the same toast, so a screen can rebuild the model on every render without restarting its dismiss timer.
public struct ToastUIModel: Equatable {

    public enum Status: CaseIterable, Sendable {
        case confirmation
        case error
        case noConnection

        var isError: Bool { self != .confirmation }

        /// An error stays longer than a confirmation.
        var duration: Duration { isError ? DS.Motion.errorToast : DS.Motion.toast }

        var systemImage: SystemImage {
            switch self {
            case .confirmation: .checkmarkCircleFill
            case .error: .exclamationmarkCircleFill
            case .noConnection: .wifiSlash
            }
        }
    }

    fileprivate let text: String
    fileprivate let status: Status
    /// Called when the toast goes away: after its time, or on a tap or swipe down. The screen clears its model.
    fileprivate let onDismiss: () -> Void

    public init(text: String, status: Status, onDismiss: @escaping () -> Void) {
        self.text = text
        self.status = status
        self.onDismiss = onDismiss
    }

    /// The error toast with the error's copy (`AppError+Strings`). `nil` when there is no error.
    public init?(error: AppError?, onDismiss: @escaping () -> Void) {
        guard let error else { return nil }
        self.init(text: error.copy.toastText, status: error.copy.toastStatus, onDismiss: onDismiss)
    }

    public static func == (lhs: ToastUIModel, rhs: ToastUIModel) -> Bool {
        lhs.text == rhs.text && lhs.status == rhs.status
    }
}

// MARK: View

struct ToastView: View {

    let model: ToastUIModel?

    var body: some View {
        ZStack {
            if let model {
                Label {
                    Text(model.text)
                        .textStyle(.subhead)
                        .multilineTextAlignment(.leading)
                } icon: {
                    Image(systemImage: model.status.systemImage)
                        .foregroundStyle(model.status.isError ? DS.Colors.error : DS.Colors.accent)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(DS.Colors.onInverseSurface)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.vertical, DS.Spacing.md)
                .background(DS.Colors.inverseSurface, in: .rect(cornerRadius: DS.Radius.md))
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.lg)
                .onTapGesture { model.onDismiss() }
                .gesture(DragGesture().onEnded { if $0.translation.height > 0 { model.onDismiss() } })
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear { report(model) }
                // One timer per shown toast: it restarts only when a different toast replaces it.
                .task(id: model) {
                    try? await Task.sleep(for: model.status.duration)
                    if !Task.isCancelled { model.onDismiss() }
                }
            }
        }
        .animation(.easeInOut(duration: DS.Motion.base), value: model)
    }

    /// Announced for VoiceOver (errors first, with high priority) and logged.
    private func report(_ model: ToastUIModel) {
        guard model.status.isError else {
            AccessibilityNotification.Announcement(model.text).post()
            Log.info("Toast: \(model.text)", .messages)
            return
        }
        var announcement = AttributedString(L10n.Coreui.toastErrorAnnouncement(model.text))
        announcement.accessibilitySpeechAnnouncementPriority = .high
        AccessibilityNotification.Announcement(announcement).post()
        Log.warning("Error toast: \(model.text)", .messages)
    }
}

#Preview {
    VStack(spacing: DS.Spacing.sm) {
        ForEach(ToastUIModel.Status.allCases, id: \.self) { status in
            ToastView(model: ToastUIModel(text: "Something went wrong. Please try again.", status: status) {})
                .frame(height: 80)
        }
    }
}
