import DesignSystem
import SwiftUI

struct MyPageMenuList: View {
    let action: (MyPageFeature.MenuItem) -> Void

    private let items: [Menu] = [
        Menu(item: .sajuManagement, title: "사주 정보 관리", icon: .addUser),
        Menu(item: .notificationSettings, title: "알림 설정", icon: .bell),
        Menu(item: .appSettings, title: "앱 설정", icon: .settings),
        Menu(item: .inquiry, title: "1:1 문의", icon: .mail),
        Menu(item: .logout, title: "로그아웃", icon: .logout)
    ]

    var body: some View {
        VStack(spacing: 4) {
            ForEach(items) { menu in
                Button { action(menu.item) } label: {
                    HStack(spacing: 8) {
                        DSIcon(menu.icon, width: 20, height: 20)
                        Text(menu.title)
                            .dsBody2Medium
                        Spacer()
                        if menu.item != .logout {
                            DSIcon(.chevronSmallRight, width: 20, height: 20)
                                .foregroundStyle(Color.ds.gray400)
                        }
                    }
                    .foregroundStyle(menu.item == .logout ? Color.ds.gray500 : Color.ds.gray975)
                    .frame(height: 56)
                    .contentShape(Rectangle())
                }
            }

            HStack(spacing: 16) {
                Text("앱 버전").dsBody3Medium.foregroundStyle(Color.ds.gray400)
                Text("v \(Bundle.main.releaseVersionNumber ?? "1.0.0") (최신 버전)")
                    .dsBody3Medium
                    .foregroundStyle(Color.ds.gray500)
            }
            .padding(.top, 28)
        }
        .padding(.horizontal, 20)
    }

    private struct Menu: Identifiable {
        let item: MyPageFeature.MenuItem
        let title: String
        let icon: DSIconAsset

        // swiftlint:disable:next identifier_name
        var id: MyPageFeature.MenuItem { item }
    }
}

private extension Bundle {
    var releaseVersionNumber: String? {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}
