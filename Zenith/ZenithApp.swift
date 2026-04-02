import SwiftUI
import SwiftData

@main
struct ZenithApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Budget.self,
            Subscription.self,
            SavingsGoal.self,
            PlannedTransaction.self,
            MoneySource.self,
            Settlement.self,
            Category.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Enforce a dark mode preference since the design is optimized for it
                .preferredColorScheme(.dark)
        }
        .modelContainer(sharedModelContainer)
    }
}
