import Foundation
import SwiftUI
import Combine

@MainActor
class AppViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var categories: [Category] = []
    @Published var moneySources: [MoneySource] = []
    @Published var goals: [SavingsGoal] = []
    @Published var settlements: [Settlement] = []
    @Published var subscriptions: [Subscription] = []
    @Published var budgets: [Budget] = []
    @Published var plannedTransactions: [PlannedTransaction] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    static let shared = AppViewModel()
    
    private init() {}
    
    enum DataCategory {
        case transactions, categories, moneySources, goals, settlements, subscriptions, budgets, plannedTransactions
    }
    
    func refreshAll() async {
        await refresh(categories: [.transactions, .categories, .moneySources, .goals, .settlements, .subscriptions, .budgets, .plannedTransactions])
    }
    
    func refresh(categories: [DataCategory]) async {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }
        
        await withTaskGroup(of: Void.self) { group in
            for category in categories {
                switch category {
                case .transactions: group.addTask { await self.fetchTransactions() }
                case .categories: group.addTask { await self.fetchCategories() }
                case .moneySources: group.addTask { await self.fetchMoneySources() }
                case .goals: group.addTask { await self.fetchGoals() }
                case .settlements: group.addTask { await self.fetchSettlements() }
                case .subscriptions: group.addTask { await self.fetchSubscriptions() }
                case .budgets: group.addTask { await self.fetchBudgets() }
                case .plannedTransactions: group.addTask { await self.fetchPlannedTransactions() }
                }
            }
        }
    }
    
    // Independent Fetchers
    private func fetchTransactions() async {
        do { self.transactions = try await ZenithAPI.shared.request("transactions") }
        catch { handleSyncError(error, for: "Transactions") }
    }
    
    private func fetchCategories() async {
        do { self.categories = try await ZenithAPI.shared.request("categories") }
        catch { handleSyncError(error, for: "Categories") }
    }
    
    private func fetchMoneySources() async {
        do { self.moneySources = try await ZenithAPI.shared.request("money-sources") }
        catch { handleSyncError(error, for: "Money Sources") }
    }
    
    private func fetchGoals() async {
        do { self.goals = try await ZenithAPI.shared.request("savings-goals") }
        catch { handleSyncError(error, for: "Goals") }
    }
    
    private func fetchSettlements() async {
        do { self.settlements = try await ZenithAPI.shared.request("settlements") }
        catch { handleSyncError(error, for: "Settlements") }
    }
    
    private func fetchSubscriptions() async {
        do { self.subscriptions = try await ZenithAPI.shared.request("subscriptions") }
        catch { handleSyncError(error, for: "Subscriptions") }
    }
    
    private func fetchBudgets() async {
        do { self.budgets = try await ZenithAPI.shared.request("budgets") }
        catch { handleSyncError(error, for: "Budgets") }
    }
    
    private func fetchPlannedTransactions() async {
        do { self.plannedTransactions = try await ZenithAPI.shared.request("planned-transactions") }
        catch { handleSyncError(error, for: "Planned Transactions") }
    }
    
    private func handleSyncError(_ error: Error, for category: String) {
        print("Sync Error [\(category)]: \(error)")
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Type mismatch in \(category): expected \(type) at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            case .keyNotFound(let key, let context):
                print("Missing key in \(category): '\(key.stringValue)' at \(context.codingPath.map { $0.stringValue }.joined(separator: "."))")
            default:
                print("Decoding error in \(category): \(decodingError)")
            }
        }
    }
    
    // MARK: - API Helpers
    
    /// Perform a generic action (like DELETE) and handle the result
    private func perform(_ endpoint: String, method: String) async -> Bool {
        do {
            let _: EmptyResponse = try await ZenithAPI.shared.request(endpoint, method: method, body: nil)
            return true
        } catch {
            print("Action Error (No Body): \(error)")
            self.errorMessage = "Action failed: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Perform an action with a request body and return the response object
    private func perform<T: Codable, R: Codable>(_ endpoint: String, method: String, body: T) async -> R? {
        do {
            let data = try JSONEncoder().encode(body)
            return try await ZenithAPI.shared.request(endpoint, method: method, body: data)
        } catch {
            print("Action Error (With Body): \(error)")
            self.errorMessage = "Action failed: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - Transactions
    func addTransaction(_ tx: Transaction) async { 
        if let newTx: Transaction = await perform("transactions", method: "POST", body: tx) {
            self.transactions.insert(newTx, at: 0)
            // Balance and budget might need a refresh since they are derived from complex logic
            await refresh(categories: [.moneySources, .budgets])
        }
    }
    
    func deleteTransaction(_ tx: Transaction) async { 
        if await perform("transactions/\(tx.id)", method: "DELETE") {
            self.transactions.removeAll { $0.id == tx.id }
            await refresh(categories: [.moneySources, .budgets])
        }
    }
    
    // MARK: - Categories
    func addCategory(_ cat: Category) async { 
        if let newCat: Category = await perform("categories", method: "POST", body: cat) {
            self.categories.append(newCat)
        }
    }
    
    func deleteCategory(_ cat: Category) async { 
        if await perform("categories/\(cat.id)", method: "DELETE") {
            self.categories.removeAll { $0.id == cat.id }
        }
    }
    
    // MARK: - Money Sources
    func addMoneySource(_ source: MoneySource) async { 
        if let newSource: MoneySource = await perform("money-sources", method: "POST", body: source) {
            self.moneySources.append(newSource)
        }
    }
    
    func updateMoneySource(_ source: MoneySource) async { 
        if let updatedSource: MoneySource = await perform("money-sources/\(source.id)", method: "PUT", body: source) {
            if let index = self.moneySources.firstIndex(where: { $0.id == source.id }) {
                self.moneySources[index] = updatedSource
            }
        }
    }
    
    func deleteMoneySource(_ source: MoneySource) async { 
        if await perform("money-sources/\(source.id)", method: "DELETE") {
            self.moneySources.removeAll { $0.id == source.id }
        }
    }
    
    // MARK: - Savings Goals
    func addGoal(_ goal: SavingsGoal) async { 
        if let newGoal: SavingsGoal = await perform("savings-goals", method: "POST", body: goal) {
            self.goals.append(newGoal)
        }
    }
    
    func updateGoal(_ goal: SavingsGoal) async { 
        if let updatedGoal: SavingsGoal = await perform("savings-goals/\(goal.id)", method: "PUT", body: goal) {
            if let index = self.goals.firstIndex(where: { $0.id == goal.id }) {
                self.goals[index] = updatedGoal
            }
        }
    }
    
    func deleteGoal(_ goal: SavingsGoal) async { 
        if await perform("savings-goals/\(goal.id)", method: "DELETE") {
            self.goals.removeAll { $0.id == goal.id }
        }
    }
    
    func depositToGoal(_ goal: SavingsGoal, amount: Double) async {
        struct DepositRequest: Codable { let amount: Double }
        if let updatedGoal: SavingsGoal = await perform("savings-goals/\(goal.id)/deposit", method: "POST", body: DepositRequest(amount: amount)) {
            if let index = self.goals.firstIndex(where: { $0.id == goal.id }) {
                self.goals[index] = updatedGoal
            }
            // Deposit impacts balance
            await refresh(categories: [.moneySources])
        }
    }
    
    // MARK: - Settlements
    func addSettlement(_ s: Settlement) async { 
        if let newSettlement: Settlement = await perform("settlements", method: "POST", body: s) {
            self.settlements.insert(newSettlement, at: 0)
        }
    }
    
    func deleteSettlement(_ s: Settlement) async { 
        if await perform("settlements/\(s.id)", method: "DELETE") {
            self.settlements.removeAll { $0.id == s.id }
        }
    }
    
    func paySettlement(_ s: Settlement, amount: Double, moneySourceId: UUID) async {
        struct PaySettlementRequest: Codable {
            let amount: Double
            let money_source_id: UUID
        }
        let body = PaySettlementRequest(amount: amount, money_source_id: moneySourceId)
        if let updatedSettlement: Settlement = await perform("settlements/\(s.id)/pay", method: "POST", body: body) {
            if let index = self.settlements.firstIndex(where: { $0.id == s.id }) {
                self.settlements[index] = updatedSettlement
            }
            // Payment impacts money sources and transactions
            await refresh(categories: [.moneySources, .transactions])
        }
    }
    
    // MARK: - Subscriptions
    func addSubscription(_ s: Subscription) async { 
        if let newSubscription: Subscription = await perform("subscriptions", method: "POST", body: s) {
            self.subscriptions.append(newSubscription)
        }
    }
    
    func deleteSubscription(_ s: Subscription) async { 
        if await perform("subscriptions/\(s.id)", method: "DELETE") {
            self.subscriptions.removeAll { $0.id == s.id }
        }
    }
    
    // MARK: - Budgets
    func addBudget(_ b: Budget) async { 
        if let newBudget: Budget = await perform("budgets", method: "POST", body: b) {
            self.budgets.insert(newBudget, at: 0)
        }
    }
    
    // MARK: - Planned Transactions
    func addPlannedTransaction(_ pt: PlannedTransaction) async { 
        if let newPT: PlannedTransaction = await perform("planned-transactions", method: "POST", body: pt) {
            self.plannedTransactions.insert(newPT, at: 0)
        }
    }
    
    func deletePlannedTransaction(_ pt: PlannedTransaction) async { 
        if await perform("planned-transactions/\(pt.id)", method: "DELETE") {
            self.plannedTransactions.removeAll { $0.id == pt.id }
        }
    }
    
    struct EmptyResponse: Codable {}
}
