public struct DSWheelPickerItem: Identifiable, Hashable, Sendable {
    public let value: Int
    public let title: String

    // swiftlint:disable:next identifier_name
    public var id: Int {
        value
    }

    public init(
        value: Int,
        title: String
    ) {
        self.value = value
        self.title = title
    }
}
