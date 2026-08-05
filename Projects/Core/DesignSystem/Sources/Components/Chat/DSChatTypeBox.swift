import SwiftUI

public struct DSChatTypeBox: View {
    public struct Specification: Sendable {
        public let minimumHeight: CGFloat
        public let maximumHeight: CGFloat
        public let shape: DSComponentShape
        public let backgroundAsset: DesignSystemColors
        public let strokeAsset: DesignSystemColors
        public let strokeWidth: CGFloat
        public let textFont: FontStyle
        public let textColor: DesignSystemColors
        public let placeholderColor: DesignSystemColors
        public let textLineHeight: CGFloat
        public let textLeadingPadding: CGFloat
        public let textTrailingPadding: CGFloat
        public let textVerticalPadding: CGFloat
        public let sendIcon: DSIconAsset
        public let sendButtonSize: CGFloat
        public let sendIconSize: CGFloat
        public let sendButtonBackgroundAsset: DesignSystemColors
        public let sendIconColorAsset: DesignSystemColors
        public let shadowColorAsset: DesignSystemColors
        public let shadowOpacity: CGFloat
        public let shadowRadius: CGFloat
        public let shadowOffsetY: CGFloat
    }

    public static func specification(isFilled: Bool) -> Specification {
        Specification(
            minimumHeight: 64,
            maximumHeight: 104,
            shape: .roundedRectangle(cornerRadius: 24),
            backgroundAsset: DesignSystemAsset.Colors.white,
            strokeAsset: DesignSystemAsset.Colors.gray50,
            strokeWidth: 1,
            textFont: .body2Regular,
            textColor: DesignSystemAsset.Colors.black,
            placeholderColor: DesignSystemAsset.Colors.gray500,
            textLineHeight: 24,
            textLeadingPadding: 22,
            textTrailingPadding: 20,
            textVerticalPadding: 16,
            sendIcon: .arrowUpward,
            sendButtonSize: 32,
            sendIconSize: 24,
            sendButtonBackgroundAsset: isFilled
                ? DesignSystemAsset.Colors.primary600
                : DesignSystemAsset.Colors.gray50,
            sendIconColorAsset: isFilled
                ? DesignSystemAsset.Colors.white
                : DesignSystemAsset.Colors.gray400,
            shadowColorAsset: DesignSystemAsset.Colors.black,
            shadowOpacity: 0.06,
            shadowRadius: 20,
            shadowOffsetY: 4
        )
    }

    struct LayoutMetrics {
        enum ContentAlignment: Equatable {
            case center
            case bottom
        }

        let textEditorHeight: CGFloat
        let contentHeight: CGFloat
        let topPadding: CGFloat
        let boxHeight: CGFloat
        let contentAlignment: ContentAlignment
        let exceedsMaximumTextHeight: Bool
    }

    static func layoutMetrics(
        specification: Specification,
        textContentHeight: CGFloat
    ) -> LayoutMetrics {
        let maximumTextHeight = specification.maximumHeight - (specification.textVerticalPadding * 2)
        let measuredTextHeight = max(specification.textLineHeight, textContentHeight)
        let visibleTextHeight = min(measuredTextHeight, maximumTextHeight)
        let exceedsMaximumTextHeight = measuredTextHeight > maximumTextHeight
        let overflowViewportHeight = specification.maximumHeight - specification.textVerticalPadding
        let textEditorHeight = exceedsMaximumTextHeight
            ? overflowViewportHeight
            : visibleTextHeight
        let contentHeight = exceedsMaximumTextHeight
            ? overflowViewportHeight
            : max(visibleTextHeight, specification.sendButtonSize)
        let topPadding = exceedsMaximumTextHeight ? 0 : specification.textVerticalPadding
        let boxHeight = exceedsMaximumTextHeight
            ? specification.maximumHeight
            : max(
                specification.minimumHeight,
                contentHeight + topPadding + specification.textVerticalPadding
            )

        return LayoutMetrics(
            textEditorHeight: textEditorHeight,
            contentHeight: contentHeight,
            topPadding: topPadding,
            boxHeight: boxHeight,
            contentAlignment: measuredTextHeight <= specification.textLineHeight ? .center : .bottom,
            exceedsMaximumTextHeight: exceedsMaximumTextHeight
        )
    }

    @Binding private var text: String
    private let placeholder: String
    private let onSend: () -> Void
    @State private var isTextEditorFocused = false
    @State private var textContentHeight: CGFloat = 0

    public init(
        text: Binding<String>,
        placeholder: String = "",
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSend = onSend
    }

    public var body: some View {
        let isFilled = !text.isEmpty
        let specification = Self.specification(isFilled: isFilled)
        let metrics = Self.layoutMetrics(
            specification: specification,
            textContentHeight: textContentHeight
        )

        ZStack(alignment: .bottom) {
            HStack(
                alignment: metrics.contentAlignment == .center ? .center : .bottom,
                spacing: 0
            ) {
                ZStack(alignment: .leading) {
                    if text.isEmpty && !isTextEditorFocused {
                        Text(placeholder)
                            .dsFont(specification.textFont)
                            .foregroundStyle(specification.placeholderColor.swiftUIColor)
                            .allowsHitTesting(false)
                    }

                    DSChatTextEditor(
                        text: $text,
                        isFocused: $isTextEditorFocused,
                        contentHeight: $textContentHeight,
                        font: UIFont(
                            font: specification.textFont.fontConvertible,
                            size: specification.textFont.size
                        ) ?? .systemFont(ofSize: specification.textFont.size),
                        textColor: UIColor(specification.textColor.swiftUIColor),
                        lineHeight: specification.textLineHeight
                    )
                    .frame(
                        maxWidth: .infinity,
                        minHeight: metrics.textEditorHeight,
                        maxHeight: metrics.textEditorHeight
                    )
                    .dsDebugTypographyGeometry("Typography.\(String(describing: specification.textFont))")
                }

                Button(action: onSend) {
                    DSIcon(
                        specification.sendIcon,
                        width: specification.sendIconSize,
                        height: specification.sendIconSize
                    )
                    .foregroundStyle(specification.sendIconColorAsset.swiftUIColor)
                    .frame(
                        width: specification.sendButtonSize,
                        height: specification.sendButtonSize
                    )
                    .background(specification.sendButtonBackgroundAsset.swiftUIColor)
                    .clipShape(Circle())
                    .dsDebugDetailGeometry("DSChatTypeBox.SendButton")
                }
                .buttonStyle(
                    DSIconButtonStyle(
                        iconAsset: specification.sendIcon,
                        iconSize: CGSize(width: specification.sendIconSize, height: specification.sendIconSize),
                        pressedOverlay: .standard
                    )
                )
                .disabled(!isFilled)
            }
            .frame(height: metrics.contentHeight, alignment: .bottom)
            .padding(.leading, specification.textLeadingPadding)
            .padding(.trailing, specification.textTrailingPadding)
            .padding(.top, metrics.topPadding)
            .padding(.bottom, specification.textVerticalPadding)
        }
        .frame(maxWidth: .infinity)
        .frame(height: metrics.boxHeight)
        .background(specification.backgroundAsset.swiftUIColor)
        .overlay(alignment: .top) {
            if metrics.exceedsMaximumTextHeight {
                specification.backgroundAsset.swiftUIColor
                    .opacity(0.6)
                    .frame(height: specification.textVerticalPadding)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(specification.shape.swiftUIShape)
        .overlay {
            specification.shape.strokeBorder(
                specification.strokeAsset.swiftUIColor,
                lineWidth: specification.strokeWidth
            )
        }
        .shadow(
            color: specification.shadowColorAsset.swiftUIColor.opacity(specification.shadowOpacity),
            radius: specification.shadowRadius,
            y: specification.shadowOffsetY
        )
        .dsDebugGeometry("DSChatTypeBox")
    }
}

private struct DSChatTextEditor: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool
    @Binding var contentHeight: CGFloat
    let font: UIFont
    let textColor: UIColor
    let lineHeight: CGFloat

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isFocused: $isFocused)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = DSChatTextView()
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = false
        textView.alwaysBounceVertical = true
        textView.onContentHeightChange = { measuredHeight in
            guard abs(contentHeight - measuredHeight) > 0.5 else { return }
            contentHeight = measuredHeight
        }
        configure(textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context: Context) {
        if textView.text != text {
            textView.text = text
        }
        configure(textView)
        textView.setNeedsLayout()
    }

    private func configure(_ textView: UITextView) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight
        textView.font = font
        textView.textColor = textColor
        textView.typingAttributes = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String
        @Binding private var isFocused: Bool

        init(text: Binding<String>, isFocused: Binding<Bool>) {
            self._text = text
            self._isFocused = isFocused
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            textView.setNeedsLayout()

            DispatchQueue.main.async {
                let textLength = (textView.text as NSString).length
                textView.scrollRangeToVisible(
                    NSRange(location: textLength, length: 0)
                )
            }
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            isFocused = true
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            isFocused = false
        }
    }
}

private final class DSChatTextView: UITextView {
    var onContentHeightChange: ((CGFloat) -> Void)?
    private var lastReportedContentHeight: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0 else { return }

        let contentHeight = sizeThatFits(
            CGSize(width: bounds.width, height: .greatestFiniteMagnitude)
        ).height

        guard abs(lastReportedContentHeight - contentHeight) > 0.5 else { return }
        lastReportedContentHeight = contentHeight
        onContentHeightChange?(contentHeight)
    }
}
