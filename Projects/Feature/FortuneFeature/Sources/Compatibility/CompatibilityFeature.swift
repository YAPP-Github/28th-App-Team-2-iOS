import ComposableArchitecture
import Foundation
import Model

// 등록, 선택, 결과 상태는 하나의 화면 단위 상태 머신으로 구성한다.
// swiftlint:disable type_body_length

@Reducer
public struct CompatibilityFeature {
    private enum CancelID {
        case initialData
        case partners
        case partnerSaju
    }

    public struct InitialData: Equatable, Sendable {
        public let mySaju: SajuChartDetail
        public let partners: [FortunePartner]

        public init(mySaju: SajuChartDetail, partners: [FortunePartner]) {
            self.mySaju = mySaju
            self.partners = partners
        }
    }

    @ObservableState
    public struct State: Equatable, Sendable {
        public enum ViewState: Equatable, Sendable {
            case loading
            case loaded
            case failed(String)
        }

        public var viewState: ViewState = .loading
        public var partners: [FortunePartner] = []
        public var selectedPartnerID: UUID?
        public var mySaju: SajuChartDetail?
        public var selectedPartnerSaju: SajuChartDetail?
        public var isPartnerPickerPresented = false
        public var isRegistrationPresented = false
        public var isSubmitting = false
        public var errorMessage: String?
        public var result: CompatibilityResult?

        public var name = ""
        public var gender: Gender?
        public var calendarType: BirthDateCalendar = .solar
        public var birthDate = Date(timeIntervalSince1970: 946_684_800)
        public var birthTime: BirthTimePeriod?
        public var isBirthTimeUnknown = false
        public var relationship: Relationship?

        public init() {}

        public var selectedPartner: FortunePartner? {
            partners.first { $0.id == selectedPartnerID }
        }

        public var nameValidationMessage: String? {
            guard !name.isEmpty else { return nil }
            guard name.count <= 10 else { return "최대 10글자까지 입력 가능해요." }
            guard name.allSatisfy({ $0.isLetter || $0.isNumber }) else {
                return "한글, 영문, 숫자만 입력할 수 있어요."
            }
            return nil
        }

        public var canRegister: Bool {
            !name.isEmpty
                && nameValidationMessage == nil
                && gender != nil
                && (birthTime != nil || isBirthTimeUnknown)
                && relationship != nil
                && !isSubmitting
        }
    }

    public enum Action: Equatable, Sendable {
        case task
        case initialResponse(Result<InitialData, FortuneClientError>)
        case partnersResponse(Result<[FortunePartner], FortuneClientError>)
        case partnerSajuResponse(UUID, Result<SajuChartDetail, FortuneClientError>)
        case retryTapped
        case partnerPickerPresented(Bool)
        case partnerSelected(UUID)
        case registrationPresented(Bool)
        case nameChanged(String)
        case genderChanged(Gender?)
        case calendarTypeChanged(BirthDateCalendar)
        case birthDateChanged(Date)
        case birthTimeChanged(BirthTimePeriod?)
        case birthTimeUnknownChanged(Bool)
        case relationshipChanged(Relationship?)
        case registerTapped
        case registrationResponse(Result<UUID, FortuneClientError>)
        case compatibilityTapped
        case compatibilityResponse(Result<CompatibilityResult, FortuneClientError>)
        case resultBackTapped
        case shareTapped
        case todakTapped
        case myInfoEditTapped
        case delegate(Delegate)

        public enum Delegate: Equatable, Sendable {
            case todakRequested
            case myInfoEditRequested
        }
    }

    @Dependency(\.fortuneClient) private var fortuneClient

    public init() {}

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .retryTapped:
                state.viewState = .loading
                return fetchInitialData()

            case let .initialResponse(.success(data)):
                state.mySaju = data.mySaju
                state.partners = data.partners
                if state.selectedPartnerID == nil || state.selectedPartner == nil {
                    state.selectedPartnerID = data.partners.first?.id
                }
                state.viewState = .loaded
                state.errorMessage = nil
                state.selectedPartnerSaju = nil
                guard let partnerID = state.selectedPartnerID else { return .none }
                return fetchPartnerSaju(partnerID)

            case let .initialResponse(.failure(error)):
                state.viewState = .failed(error.userMessage)
                return .none

            case let .partnersResponse(.success(partners)):
                state.partners = partners
                if state.selectedPartnerID == nil || state.selectedPartner == nil {
                    state.selectedPartnerID = partners.first?.id
                }
                state.viewState = .loaded
                state.errorMessage = nil
                state.selectedPartnerSaju = nil
                guard let partnerID = state.selectedPartnerID else { return .none }
                return fetchPartnerSaju(partnerID)

            case let .partnersResponse(.failure(error)):
                state.viewState = .failed(error.userMessage)
                return .none

            case let .partnerPickerPresented(isPresented):
                state.isPartnerPickerPresented = isPresented
                return .none

            case let .partnerSelected(partnerID):
                state.selectedPartnerID = partnerID
                state.selectedPartnerSaju = nil
                state.isPartnerPickerPresented = false
                return fetchPartnerSaju(partnerID)

            case let .partnerSajuResponse(partnerID, .success(chart)):
                guard state.selectedPartnerID == partnerID else { return .none }
                state.selectedPartnerSaju = chart
                state.errorMessage = nil
                return .none

            case let .partnerSajuResponse(partnerID, .failure(error)):
                guard state.selectedPartnerID == partnerID else { return .none }
                state.selectedPartnerSaju = nil
                state.errorMessage = error.userMessage
                return .none

            case let .registrationPresented(isPresented):
                state.isRegistrationPresented = isPresented
                if isPresented {
                    resetForm(state: &state)
                }
                return .none

            case let .nameChanged(name):
                state.name = String(name.prefix(11))
                return .none

            case let .genderChanged(gender):
                state.gender = gender
                return .none

            case let .calendarTypeChanged(type):
                state.calendarType = type
                return .none

            case let .birthDateChanged(date):
                state.birthDate = date
                return .none

            case let .birthTimeChanged(time):
                state.birthTime = time
                if time != nil { state.isBirthTimeUnknown = false }
                return .none

            case let .birthTimeUnknownChanged(isUnknown):
                state.isBirthTimeUnknown = isUnknown
                if isUnknown { state.birthTime = nil }
                return .none

            case let .relationshipChanged(relationship):
                state.relationship = relationship
                return .none

            case .registerTapped:
                guard
                    state.canRegister,
                    let gender = state.gender,
                    let relationship = state.relationship
                else { return .none }

                state.isSubmitting = true
                state.errorMessage = nil
                let input = PartnerRegistrationInput(
                    name: state.name,
                    gender: gender,
                    calendarType: state.calendarType,
                    birthDate: state.birthDate,
                    birthTime: state.birthTime,
                    isBirthTimeUnknown: state.isBirthTimeUnknown,
                    relationship: relationship
                )
                return .run { send in
                    do {
                        await send(.registrationResponse(.success(try await fortuneClient.registerPartner(input))))
                    } catch let error as FortuneClientError {
                        await send(.registrationResponse(.failure(error)))
                    } catch {
                        await send(.registrationResponse(.failure(.transport)))
                    }
                }

            case let .registrationResponse(.success(partnerID)):
                state.isSubmitting = false
                state.isRegistrationPresented = false
                state.selectedPartnerID = partnerID
                return fetchPartners()

            case let .registrationResponse(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userMessage
                return .none

            case .compatibilityTapped:
                guard
                    let partner = state.selectedPartner,
                    !state.isSubmitting
                else { return .none }
                state.isSubmitting = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let result = try await fortuneClient.createCompatibility(
                            partner.id,
                            partner.name
                        )
                        await send(.compatibilityResponse(.success(result)))
                    } catch let error as FortuneClientError {
                        await send(.compatibilityResponse(.failure(error)))
                    } catch {
                        await send(.compatibilityResponse(.failure(.transport)))
                    }
                }

            case let .compatibilityResponse(.success(result)):
                state.isSubmitting = false
                state.result = result
                return .none

            case let .compatibilityResponse(.failure(error)):
                state.isSubmitting = false
                state.errorMessage = error.userMessage
                return .none

            case .resultBackTapped:
                state.result = nil
                return .none

            case .todakTapped:
                return .send(.delegate(.todakRequested))

            case .myInfoEditTapped:
                return .send(.delegate(.myInfoEditRequested))

            case .shareTapped, .delegate:
                return .none
            }
        }
    }

    private func fetchInitialData() -> Effect<Action> {
        .run { send in
            do {
                async let mySaju = fortuneClient.fetchMySaju()
                async let partners = fortuneClient.fetchPartners()
                let resolvedMySaju = try await mySaju
                let resolvedPartners = try await partners
                await send(
                    .initialResponse(
                        .success(
                            InitialData(
                                mySaju: resolvedMySaju,
                                partners: resolvedPartners
                            )
                        )
                    )
                )
            } catch is CancellationError {
                return
            } catch let error as FortuneClientError {
                await send(.initialResponse(.failure(error)))
            } catch {
                await send(.initialResponse(.failure(.transport)))
            }
        }
        .cancellable(id: CancelID.initialData, cancelInFlight: true)
    }

    private func fetchPartners() -> Effect<Action> {
        .run { send in
            do {
                await send(.partnersResponse(.success(try await fortuneClient.fetchPartners())))
            } catch is CancellationError {
                return
            } catch let error as FortuneClientError {
                await send(.partnersResponse(.failure(error)))
            } catch {
                await send(.partnersResponse(.failure(.transport)))
            }
        }
        .cancellable(id: CancelID.partners, cancelInFlight: true)
    }

    private func fetchPartnerSaju(_ partnerID: UUID) -> Effect<Action> {
        .run { send in
            do {
                await send(
                    .partnerSajuResponse(
                        partnerID,
                        .success(try await fortuneClient.fetchPartnerSaju(partnerID))
                    )
                )
            } catch is CancellationError {
                return
            } catch let error as FortuneClientError {
                await send(.partnerSajuResponse(partnerID, .failure(error)))
            } catch {
                await send(.partnerSajuResponse(partnerID, .failure(.transport)))
            }
        }
        .cancellable(id: CancelID.partnerSaju, cancelInFlight: true)
    }

    private func resetForm(state: inout State) {
        state.name = ""
        state.gender = nil
        state.calendarType = .solar
        state.birthDate = Date(timeIntervalSince1970: 946_684_800)
        state.birthTime = nil
        state.isBirthTimeUnknown = false
        state.relationship = nil
        state.errorMessage = nil
    }
}

// swiftlint:enable type_body_length
