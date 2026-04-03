import SwiftUI

struct CategoryDetailView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let category: Category
    
    var categoryTransactions: [Transaction] {
        appViewModel.transactions.filter { $0.categoryId == category.id && $0.type == .outgoing }
    }
    
    var totalSpent: Double {
        categoryTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.onSurface)
                            .padding(12)
                            .background(AppTheme.surfaceContainer)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(category.name)
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // Summary Card
                        VStack(spacing: 8) {
                            Text("TOTAL SPENT")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(3)
                            
                            Text(totalSpent, format: .currency(code: selectedCurrency))
                                .font(Font.headline(size: 40, weight: .heavy))
                                .foregroundColor(AppTheme.primary)
                        }
                        .padding(32)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        .padding(.horizontal)
                        
                        // Transaction List
                        if categoryTransactions.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "cart.badge.minus")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
                                Text("No expenses logged.")
                                    .font(Font.bodyText(size: 16))
                                    .foregroundColor(AppTheme.onSurfaceVariant)
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(categoryTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .environmentObject(appViewModel)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 150)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .refreshable {
            await appViewModel.refresh(categories: [.transactions])
        }
    }
}
