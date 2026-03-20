import CloudKit
import Foundation

enum CloudKitContainerResolver {
    static func defaultContainer(
        matching expectedIdentifier: String,
        category: LogCategory
    ) -> CKContainer? {
        let container = CKContainer.default()

        guard let identifier = container.containerIdentifier, !identifier.isEmpty else {
            Logger.warning("CloudKit container unavailable; skipping access to \(expectedIdentifier)", category: category)
            return nil
        }

        guard identifier == expectedIdentifier else {
            Logger.warning(
                "CloudKit container mismatch; expected \(expectedIdentifier), got \(identifier). Skipping access.",
                category: category
            )
            return nil
        }

        return container
    }
}
