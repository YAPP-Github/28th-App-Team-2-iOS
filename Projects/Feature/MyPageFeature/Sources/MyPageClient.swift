import ComposableArchitecture
import Foundation
import NetworkCore

public struct MyPageClient: Sendable {
    public var loadDashboard: @Sendable () async throws -> MyPageDashboard
    public var updateProfile: @Sendable (MyPageProfileUpdate) async throws -> MyPageDashboard
    public var loadNotificationSettings: @Sendable () async throws -> NotificationSettings
    public var updateNotificationSettings: @Sendable (NotificationSettings) async throws -> NotificationSettings
    public var syncOSPushPermission: @Sendable (Bool) async throws -> NotificationSettings
    public var registerDeviceToken: @Sendable (String) async throws -> Void

    public init(
        loadDashboard: @escaping @Sendable () async throws -> MyPageDashboard,
        updateProfile: @escaping @Sendable (MyPageProfileUpdate) async throws -> MyPageDashboard = { _ in
            throw MyPageClientError.notConfigured
        },
        loadNotificationSettings: @escaping @Sendable () async throws -> NotificationSettings = {
            throw MyPageClientError.notConfigured
        },
        updateNotificationSettings: @escaping @Sendable (NotificationSettings)
            async throws -> NotificationSettings = { _ in
            throw MyPageClientError.notConfigured
        },
        syncOSPushPermission: @escaping @Sendable (Bool) async throws -> NotificationSettings = { _ in
            throw MyPageClientError.notConfigured
        },
        registerDeviceToken: @escaping @Sendable (String) async throws -> Void = { _ in
            throw MyPageClientError.notConfigured
        }
    ) {
        self.loadDashboard = loadDashboard
        self.updateProfile = updateProfile
        self.loadNotificationSettings = loadNotificationSettings
        self.updateNotificationSettings = updateNotificationSettings
        self.syncOSPushPermission = syncOSPushPermission
        self.registerDeviceToken = registerDeviceToken
    }
}

extension MyPageClient: DependencyKey {
    public static let liveValue = MyPageClient.unavailable
    public static let testValue = MyPageClient.unavailable
}

public extension DependencyValues {
    var myPageClient: MyPageClient {
        get { self[MyPageClient.self] }
        set { self[MyPageClient.self] = newValue }
    }
}

public extension MyPageClient {
    static let unavailable = Self(
        loadDashboard: { throw MyPageClientError.notConfigured },
        updateProfile: { _ in throw MyPageClientError.notConfigured }
    )

    static func live(httpClient: HTTPClient) -> Self {
        let chartCache = MyPageSajuChartCache.live

        return Self(
            loadDashboard: {
                let profile = try await fetchProfile(httpClient: httpClient)
                if let chart = await chartCache.load(memberID: profile.memberID) {
                    return MyPageDashboard(profile: profile, chart: chart)
                }

                let chart = try await fetchSajuChart(httpClient: httpClient)
                await chartCache.save(chart, memberID: profile.memberID)
                return MyPageDashboard(profile: profile, chart: chart)
            },
            updateProfile: { update in
                try await patchProfile(update, httpClient: httpClient)
                let profile = try await fetchProfile(httpClient: httpClient)
                let chart = try await fetchSajuChart(httpClient: httpClient)
                await chartCache.save(chart, memberID: profile.memberID)
                return MyPageDashboard(profile: profile, chart: chart)
            },
            loadNotificationSettings: {
                try await fetchNotificationSettings(httpClient: httpClient)
            },
            updateNotificationSettings: { settings in
                try await patchNotificationSettings(settings, httpClient: httpClient)
            },
            syncOSPushPermission: { granted in
                try await patchOSPushPermission(granted, httpClient: httpClient)
            },
            registerDeviceToken: { token in
                try await postDeviceToken(token, httpClient: httpClient)
            }
        )
    }
}

private func patchProfile(_ update: MyPageProfileUpdate, httpClient: HTTPClient) async throws {
    do {
        let body = try JSONEncoder().encode(UpdateMemberRequestDTO(update))
        let response: CommonResponseDTO<EmptyResponseDTO> = try await httpClient.request(
            Endpoint(
                method: .patch,
                path: "/api/v1/members/me",
                headers: ["Content-Type": "application/json"],
                body: body
            )
        )
        guard response.success else { throw MyPageClientError.invalidResponse }
    } catch {
        throw MyPageClientError(error)
    }
}

private func fetchProfile(httpClient: HTTPClient) async throws -> MyPageProfile {
    do {
        let response: CommonResponseDTO<GetMyProfileResponseDTO> = try await httpClient.request(
            .get("/api/v1/members/me")
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

private func fetchSajuChart(httpClient: HTTPClient) async throws -> MyPageSajuChart {
    do {
        let response: CommonResponseDTO<SajuChartDetailResponseDTO> = try await httpClient.request(
            .get("/api/v1/saju/me")
        )
        guard response.success, let data = response.data else {
            throw MyPageClientError.invalidResponse
        }
        return data.toDomain()
    } catch {
        throw MyPageClientError(error)
    }
}

private struct CommonResponseDTO<DataType: Decodable & Sendable>: Decodable, Sendable {
    let success: Bool
    let data: DataType?
}

private struct GetMyProfileResponseDTO: Decodable, Sendable {
    let memberID: String
    let name: String
    let gender: String
    let birthDate: String
    let birthTime: String
    let isTimeUnknown: Bool
    let calendarType: String
    let job: String
    let relationshipStatus: String

    enum CodingKeys: String, CodingKey {
        case memberID = "id"
        case name
        case gender
        case birthDate
        case birthTime
        case isTimeUnknown
        case calendarType
        case job
        case relationshipStatus
    }

    func toDomain() -> MyPageProfile {
        MyPageProfile(
            memberID: memberID,
            name: name,
            gender: gender,
            birthDate: birthDate,
            calendarType: calendarType,
            birthTime: birthTime,
            isTimeUnknown: isTimeUnknown,
            job: job,
            relationshipStatus: relationshipStatus
        )
    }
}

private struct EmptyResponseDTO: Decodable, Sendable {}

private struct UpdateMemberRequestDTO: Encodable, Sendable {
    let gender: String
    let calendarType: String
    let birthDate: String
    let birthTime: String
    let job: String
    let relationshipStatus: String

    init(_ update: MyPageProfileUpdate) {
        gender = update.gender
        calendarType = update.calendarType
        birthDate = update.birthDate
        birthTime = update.birthTime
        job = update.job
        relationshipStatus = update.relationshipStatus
    }
}

private actor MyPageSajuChartCache {
    static let live = MyPageSajuChartCache()

    private let directoryURL: URL?

    init(fileManager: FileManager = .default) {
        guard let applicationSupportURL = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            directoryURL = nil
            return
        }

        let directoryURL = applicationSupportURL.appendingPathComponent("MyPageCache", isDirectory: true)
        do {
            try fileManager.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true,
                attributes: [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication]
            )
            self.directoryURL = directoryURL
        } catch {
            self.directoryURL = nil
        }
    }

    func load(memberID: String) -> MyPageSajuChart? {
        guard let fileURL = fileURL(memberID: memberID),
              let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return try? JSONDecoder().decode(MyPageSajuChart.self, from: data)
    }

    func save(_ chart: MyPageSajuChart, memberID: String) {
        guard let fileURL = fileURL(memberID: memberID),
              let data = try? JSONEncoder().encode(chart) else {
            return
        }

        do {
            try data.write(to: fileURL, options: .atomic)
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: fileURL.path
            )
        } catch {
            return
        }
    }

    private func fileURL(memberID: String) -> URL? {
        directoryURL?.appendingPathComponent("saju-\(memberID).json")
    }
}

private struct SajuChartDetailResponseDTO: Decodable, Sendable {
    let pillars: [PillarResponseDTO]
    let ohaeng: [OhaengResponseDTO]

    func toDomain() -> MyPageSajuChart {
        MyPageSajuChart(
            pillars: pillars
                .map { $0.toDomain() }
                .sorted { $0.type.displayOrder < $1.type.displayOrder },
            ohaengs: ohaeng
                .map { $0.toDomain() }
                .sorted { $0.element.displayOrder < $1.element.displayOrder }
        )
    }
}

private struct PillarResponseDTO: Decodable, Sendable {
    let pillarType: String
    let heavenlyStem: StemResponseDTO
    let earthlyBranch: BranchResponseDTO
    let stemSipseong: SipseongResponseDTO?
    let branchSipseong: SipseongResponseDTO
    let jijanggan: [StemResponseDTO]
    let sibiunseong: SajuLabelResponseDTO
    let sinsal: SajuLabelResponseDTO

    func toDomain() -> MyPagePillar {
        MyPagePillar(
            type: pillarType,
            heavenlyStem: heavenlyStem.hanja,
            heavenlyReading: "\(heavenlyStem.reading), \(heavenlyStem.element.displayName)",
            heavenlyElement: heavenlyStem.element.toDomain(),
            earthlyBranch: earthlyBranch.hanja,
            earthlyReading: "\(earthlyBranch.reading), \(earthlyBranch.element.displayName)",
            earthlyElement: earthlyBranch.element.toDomain(),
            stemSipseong: stemSipseong?.label,
            branchSipseong: branchSipseong.label,
            hiddenStems: jijanggan.map(\.reading),
            twelveLifeStage: sibiunseong.label,
            twelveSpirit: sinsal.label
        )
    }
}

private struct OhaengResponseDTO: Decodable, Sendable {
    let element: ElementResponseDTO
    let count: Int
    let percentage: Double

    func toDomain() -> MyPageOhaeng {
        MyPageOhaeng(
            element: element.toDomain(),
            count: count,
            percentage: percentage
        )
    }
}

private struct SipseongResponseDTO: Decodable, Sendable {
    let label: String
}

private struct SajuLabelResponseDTO: Decodable, Sendable {
    let label: String
}

private struct StemResponseDTO: Decodable, Sendable {
    let hanja: String
    let reading: String
    let element: ElementResponseDTO
}

private struct BranchResponseDTO: Decodable, Sendable {
    let hanja: String
    let reading: String
    let element: ElementResponseDTO
}

private struct ElementResponseDTO: Decodable, Sendable {
    let code: String
    let label: String?

    func toDomain() -> MyPageElement {
        MyPageElement(rawValue: code) ?? .unknown
    }

    var displayName: String { label ?? code }
}

private extension String {
    var displayOrder: Int {
        switch self {
        case "TIME": 0
        case "DAY": 1
        case "MONTH": 2
        case "YEAR": 3
        default: 4
        }
    }
}

private extension MyPageElement {
    var displayOrder: Int {
        switch self {
        case .wood: 0
        case .fire: 1
        case .earth: 2
        case .metal: 3
        case .water: 4
        case .unknown: 5
        }
    }
}
