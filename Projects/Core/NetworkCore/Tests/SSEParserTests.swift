import Testing
@testable import NetworkCore

struct SSEParserTests {
    @Test("raw byte line splitter가 빈 줄을 SSE 이벤트 경계로 보존한다")
    func preservesBlankLineBoundaries() throws {
        var lineBuffer = SSELineBuffer()
        var lines: [String] = []

        for byte in Array("event: start\ndata: first\n\nevent: done\ndata: second\n\n".utf8) {
            if let line = try lineBuffer.consume(byte) {
                lines.append(line)
            }
        }

        #expect(
            lines == [
                "event: start",
                "data: first",
                "",
                "event: done",
                "data: second",
                ""
            ]
        )
    }

    @Test("raw byte line splitter가 CRLF를 하나의 줄바꿈으로 처리한다")
    func treatsCRLFAsOneLineEnding() throws {
        var lineBuffer = SSELineBuffer()
        var lines: [String] = []

        for byte in Array("data: payload\r\n\r\n".utf8) {
            if let line = try lineBuffer.consume(byte) {
                lines.append(line)
            }
        }

        #expect(lines == ["data: payload", ""])
    }

    @Test("빈 줄에서 표준 SSE 필드를 이벤트로 완성한다")
    func dispatchesStandardFieldsOnBlankLine() throws {
        var parser = SSEParser()

        #expect(parser.consume("event: message") == nil)
        #expect(parser.consume("id: event-1") == nil)
        #expect(parser.consume("retry: 1500") == nil)
        #expect(parser.consume("data: 첫 번째") == nil)
        #expect(parser.consume("data: 두 번째") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(
            event == SSEEvent(
                data: "첫 번째\n두 번째",
                event: "message",
                id: "event-1",
                retry: 1_500
            )
        )
    }

    @Test("주석과 알 수 없는 필드를 무시한다")
    func ignoresCommentsAndUnknownFields() throws {
        var parser = SSEParser()

        #expect(parser.consume(": keep-alive") == nil)
        #expect(parser.consume("unknown: value") == nil)
        #expect(parser.consume("data: payload") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: "payload"))
    }

    @Test("첫 콜론만 필드 구분자로 사용하고 공백 하나만 제거한다")
    func parsesOnlyFirstColonAndRemovesOneSpace() throws {
        var parser = SSEParser()

        #expect(parser.consume("data:  value:with:colons") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: " value:with:colons"))
    }

    @Test("값 없는 data 필드도 빈 데이터 이벤트를 만든다")
    func dispatchesEmptyDataField() throws {
        var parser = SSEParser()

        #expect(parser.consume("data") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: ""))
    }

    @Test("event 필드만 있는 블록은 이벤트를 만들지 않는다")
    func ignoresEventOnlyBlock() {
        var parser = SSEParser()

        #expect(parser.consume("event: ping") == nil)
        #expect(parser.consume("") == nil)
    }

    @Test("data가 없는 id 제어 블록도 전달한다")
    func dispatchesIDControlBlockWithoutData() throws {
        var idParser = SSEParser()

        #expect(idParser.consume("id: 10") == nil)
        let parsedIDEvent = idParser.consume("")
        let idEvent = try #require(parsedIDEvent)

        #expect(idEvent == SSEEvent(data: nil, id: "10"))

        var resetParser = SSEParser()

        #expect(resetParser.consume("id") == nil)
        let parsedResetEvent = resetParser.consume("")
        let resetEvent = try #require(parsedResetEvent)

        #expect(resetEvent == SSEEvent(data: nil, id: ""))
    }

    @Test("data가 없는 retry 제어 블록도 전달한다")
    func dispatchesRetryControlBlockWithoutData() throws {
        var parser = SSEParser()

        #expect(parser.consume("retry: 1500") == nil)
        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: nil, retry: 1_500))
    }

    @Test("ASCII 숫자가 아닌 retry와 NUL이 포함된 id를 무시한다")
    func ignoresInvalidRetryAndID() throws {
        var parser = SSEParser()

        #expect(parser.consume("retry: 1.5") == nil)
        #expect(parser.consume("id: invalid\0id") == nil)
        #expect(parser.consume("data: payload") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: "payload"))
    }

    @Test("첫 라인의 UTF-8 BOM을 제거한다")
    func stripsLeadingByteOrderMark() throws {
        var parser = SSEParser()

        #expect(parser.consume("\u{FEFF}data: payload") == nil)

        let parsedEvent = parser.consume("")
        let event = try #require(parsedEvent)

        #expect(event == SSEEvent(data: "payload"))
    }

    @Test("빈 줄 없이 종료된 데이터는 이벤트로 완성하지 않는다")
    func doesNotDispatchWithoutBlankLine() {
        var parser = SSEParser()

        #expect(parser.consume("data: unfinished") == nil)
    }
}
