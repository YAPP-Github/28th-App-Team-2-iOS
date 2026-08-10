import DesignSystem
import SwiftUI
import WebKit

struct TermsDetailView: View {
    let term: OnboardingTerm

    @Environment(\.dismiss) private var dismiss
    @State private var loadState: TermsWebView.LoadState = .loading

    private var validatedURL: URL? {
        guard let url = URL(string: term.detailURLString),
              url.scheme?.lowercased() == "https",
              url.host != nil else {
            return nil
        }
        return url
    }

    var body: some View {
        VStack(spacing: 0) {
            DSHeaderSub(
                title: "약관 동의",
                leftItem: DSHeaderActionItem(
                    identifier: "close-term-detail",
                    icon: .chevronLeftPlain,
                    action: { dismiss() }
                )
            )

            if let validatedURL {
                ZStack {
                    TermsWebView(url: validatedURL, loadState: $loadState)

                    switch loadState {
                    case .loading:
                        ProgressView("약관을 불러오는 중…")
                    case .loaded:
                        EmptyView()
                    case .failed:
                        termsLoadFailureView
                    }
                }
            } else {
                termsLoadFailureView
            }
        }
    }

    private var termsLoadFailureView: some View {
        ContentUnavailableView(
            "약관을 불러올 수 없어요",
            systemImage: "exclamationmark.triangle",
            description: Text("잠시 후 다시 시도해 주세요.")
        )
    }
}

private struct TermsWebView: UIViewRepresentable {
    enum LoadState {
        case loading
        case loaded
        case failed
    }

    let url: URL
    @Binding var loadState: LoadState

    func makeCoordinator() -> Coordinator {
        Coordinator(loadState: $loadState)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        guard webView.url != url else { return }
        loadState = .loading
        webView.load(URLRequest(url: url))
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        @Binding private var loadState: LoadState

        init(loadState: Binding<LoadState>) {
            _loadState = loadState
        }

        func webView(_: WKWebView, didFinish _: WKNavigation!) {
            loadState = .loaded
        }

        func webView(_: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            loadState = .failed
        }

        func webView(
            _: WKWebView,
            didFailProvisionalNavigation _: WKNavigation!,
            withError _: Error
        ) {
            loadState = .failed
        }

        func webView(
            _: WKWebView,
            decidePolicyFor navigationAction: WKNavigationAction,
            decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void
        ) {
            guard navigationAction.request.url?.scheme?.lowercased() == "https" else {
                loadState = .failed
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        }
    }
}
