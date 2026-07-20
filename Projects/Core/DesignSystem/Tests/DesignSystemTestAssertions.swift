import Testing
@testable import DesignSystem

func expectColorEqual(
    _ actual: DesignSystemColors?,
    _ expected: DesignSystemColors,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    #expect(actual?.name == expected.name, sourceLocation: sourceLocation)
}
