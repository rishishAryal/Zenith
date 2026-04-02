import SwiftUI
import SwiftData

struct CategoryDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let categoryName: String
    
    // We will dynamically filter transactions in the view to easily support SwiftData
    @Query(sort: \Transaction.date, order: .reverse) private var allTransactions: [Transaction]
    
    var categoryTransactions: [Transaction] {
        allTransactions.filter { $0.category == categoryName && $0.safeType == .outgoing }
    }
    
    var totalSpent: Double {
        categoryTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Custom Header
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
                    
                    Text(categoryName)
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    // Invisible placeholder to keep center alignment
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Content
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
                            Text("No expenses logged.")
                                .font(Font.bodyText(size: 16))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .padding(.top, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(categoryTransactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer().frame(height: 150) // Space for tab bar if needed
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
