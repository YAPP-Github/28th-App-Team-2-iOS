#if DEBUG
import SwiftUI

struct PushNotificationDebugPanel: View {
    @ObservedObject private var tokenStore: PushNotificationTokenStore
    @State private var isPresented = false
    @State private var didCopyToken = false

    init(tokenStore: PushNotificationTokenStore = .shared) {
        _tokenStore = ObservedObject(wrappedValue: tokenStore)
    }

    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "bell.badge.fill")
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(.indigo, in: Circle())
                .shadow(radius: 4, y: 2)
        }
        .accessibilityLabel("푸시 알림 QA 패널")
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List {
                    Section("APNs 기기 등록") {
                        Text(tokenStore.apnsDebugStatus.title)
                            .foregroundStyle(apnsStatusColor)
                    }

                    Section("FCM 등록 토큰") {
                        LabeledContent("상태", value: tokenStatusText)
                        Button("FCM 토큰 복사") {
                            didCopyToken = tokenStore.copyRegistrationToken()
                        }
                        .disabled(!hasToken)
                    }

                    Section("Todakun 서버 등록") {
                        Text(tokenStore.debugStatus.title)
                            .foregroundStyle(statusColor)
                        Button("토큰 등록 다시 시도") {
                            tokenStore.uploadCurrentToken()
                        }
                        .disabled(!hasToken)
                    }

                    Section("테스트 순서") {
                        Text("복사한 토큰을 Firebase Console의 Send test message에 넣어 실기기 수신을 확인하세요.")
                        Text("‘서버 등록 성공’은 /notifications/device-tokens가 HTTP 2xx로 완료됐다는 뜻입니다.")
                    }
                }
                .navigationTitle("Push QA")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("닫기") { isPresented = false }
                    }
                }
                .alert("FCM 토큰을 복사했어요", isPresented: $didCopyToken) {
                    Button("확인", role: .cancel) {}
                }
            }
            .presentationDetents([.medium])
        }
    }

    private var hasToken: Bool {
        switch tokenStore.debugStatus {
        case .waitingForToken:
            false
        case .waitingForAuthentication, .uploading, .registered, .failed:
            true
        }
    }

    private var tokenStatusText: String {
        hasToken ? "발급됨 (값은 복사만 가능)" : "대기 중"
    }

    private var statusColor: Color {
        switch tokenStore.debugStatus {
        case .registered:
            .green
        case .failed:
            .red
        case .waitingForToken, .waitingForAuthentication, .uploading:
            .secondary
        }
    }

    private var apnsStatusColor: Color {
        switch tokenStore.apnsDebugStatus {
        case .registered:
            .green
        case .failed:
            .red
        case .waiting:
            .secondary
        }
    }
}
#endif
