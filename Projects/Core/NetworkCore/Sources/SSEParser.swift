struct SSEParser: Sendable {
    private var isFirstLine = true
    private var dataLines: [String] = []
    private var event: String?
    private var eventID: String?
    private var retry: Int?

    mutating func consume(_ receivedLine: String) -> SSEEvent? {
        let line = normalizedFirstLine(receivedLine)

        guard !line.isEmpty else {
            return dispatchEvent()
        }

        guard !line.hasPrefix(":") else {
            return nil
        }

        let (field, value) = fieldAndValue(from: line)

        switch field {
        case "data":
            dataLines.append(value)
        case "event":
            event = value
        case "id" where !value.contains("\0"):
            eventID = value
        case "retry" where isValidRetry(value):
            retry = Int(value)
        default:
            break
        }

        return nil
    }

    private mutating func normalizedFirstLine(_ line: String) -> String {
        guard isFirstLine else {
            return line
        }

        isFirstLine = false
        return line.hasPrefix("\u{FEFF}") ? String(line.dropFirst()) : line
    }

    private func fieldAndValue(from line: String) -> (String, String) {
        guard let colonIndex = line.firstIndex(of: ":") else {
            return (line, "")
        }

        let field = String(line[..<colonIndex])
        let valueStart = line.index(after: colonIndex)
        var value = String(line[valueStart...])

        if value.hasPrefix(" ") {
            value.removeFirst()
        }

        return (field, value)
    }

    private func isValidRetry(_ value: String) -> Bool {
        !value.isEmpty && value.utf8.allSatisfy { byte in
            byte >= 48 && byte <= 57
        } && Int(value) != nil
    }

    private mutating func dispatchEvent() -> SSEEvent? {
        defer {
            dataLines.removeAll(keepingCapacity: true)
            event = nil
            eventID = nil
            retry = nil
        }

        guard !dataLines.isEmpty || eventID != nil || retry != nil else {
            return nil
        }

        return SSEEvent(
            data: dataLines.isEmpty ? nil : dataLines.joined(separator: "\n"),
            event: event,
            id: eventID,
            retry: retry
        )
    }
}
