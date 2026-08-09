import ComposableArchitecture
import DesignSystem
import SwiftUI

#if DEBUG
extension OnboardingView {
    var debugPreviewMenuButton: some View {
        Button {
            isDebugPreviewSheetPresented = true
        } label: {
            Image(systemName: "ladybug.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Color.ds.gray500)
                .frame(width: 36, height: 36)
                .background(Color.ds.gray100, in: Circle())
        }
        .accessibilityLabel("개발용 흐름 미리 보기")
    }

    var debugPreviewSheet: some View {
        NavigationStack {
            List {
                Section("흐름 미리 보기") {
                    debugPreviewAction("신규 회원 온보딩 보기", destination: .newMember)
                    debugPreviewAction("기존 회원 홈 보기", destination: .existingMember)
                    debugPreviewAction("회원가입 처리 화면 보기", destination: .signupLoading)
                }
            }
            .navigationTitle("개발용 흐름")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        isDebugPreviewSheetPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func debugPreviewAction(_ title: String, destination: DebugPreview) -> some View {
        Button(title) {
            isDebugPreviewSheetPresented = false
            store.send(.debugPreviewButtonTapped(destination))
        }
    }
}
#endif
