public struct DSHeaderActionItem {
    public let identifier: String
    public let icon: DSIconAsset
    let action: () -> Void

    public init(
        identifier: String,
        icon: DSIconAsset,
        action: @escaping () -> Void
    ) {
        self.identifier = identifier
        self.icon = icon
        self.action = action
    }
}
