import SwiftUI

struct MarkerRootView: View {
    @State private var selectedDestination: AppDestination = .today
    @StateObject private var model: MarkerAppModel

    init(dependencies: MarkerAppDependencies = .live) {
        _model = StateObject(wrappedValue: MarkerAppModel(store: dependencies.store))
    }

    var body: some View {
        TabView(selection: $selectedDestination) {
            ForEach(AppDestination.allCases) { destination in
                NavigationStack {
                    destination.makeRootView(model: model)
                        .accessibilityIdentifier(destination.screenAutomationIdentifier)
                }
                .tabItem {
                    Label(destination.title, systemImage: destination.systemImage)
                        .accessibilityIdentifier(destination.tabAutomationIdentifier)
                }
                .tag(destination)
            }
        }
        .alert("发生错误", isPresented: Binding(
            get: { model.lastErrorMessage != nil },
            set: { newValue in
                if !newValue {
                    model.clearError()
                }
            }
        )) {
            Button("确定", role: .cancel) {
                model.clearError()
            }
        } message: {
            Text(model.lastErrorMessage ?? "")
        }
    }
}
