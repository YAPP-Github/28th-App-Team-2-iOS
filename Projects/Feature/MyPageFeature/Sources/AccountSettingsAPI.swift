import Foundation
import NetworkCore

func postLogout(httpClient: HTTPClient) async throws {
    do {
        let response: CommonResponseDTO<EmptyResponseDTO> = try await httpClient.request(
            Endpoint(method: .post, path: "/api/v1/auth/logout")
        )
        guard response.success else { throw MyPageClientError.invalidResponse }
    } catch {
        throw MyPageClientError(error)
    }
}

func deleteMember(_ request: WithdrawalRequest, httpClient: HTTPClient) async throws {
    do {
        let body = try JSONEncoder().encode(WithdrawMemberRequestDTO(request))
        let response: CommonResponseDTO<EmptyResponseDTO> = try await httpClient.request(
            Endpoint(
                method: .delete,
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

private struct WithdrawMemberRequestDTO: Encodable, Sendable {
    let reason: String
    let detail: String

    init(_ request: WithdrawalRequest) {
        reason = request.reason.rawValue
        detail = request.detail
    }
}
