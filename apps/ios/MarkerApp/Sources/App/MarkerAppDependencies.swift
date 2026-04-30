import MarkerData
import MarkerDomain

@MainActor
struct MarkerAppDependencies {
    let supportedBoundaries: [MarkerDomainBoundary]
    let store: MarkerSQLiteStore

    static let live: MarkerAppDependencies = {
        let store = (try? MarkerSQLiteStore.live()) ?? (try? MarkerSQLiteStore.inMemory())

        return MarkerAppDependencies(
            supportedBoundaries: MarkerDataModule.supportedBoundaries,
            store: store ?? {
                fatalError("Unable to create MarkerSQLiteStore")
            }()
        )
    }()
}
