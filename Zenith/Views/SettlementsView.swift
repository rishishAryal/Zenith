import SwiftUI
import Combine

struct SettlementsView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var showingAdd = false
    @State private var filter: SettlementFilter = .active
    
    enum SettlementFilter: String, CaseIterable, Identifiable {
        case active = "Active"
        case completed = "Settled"
        var id: Self { self }
    }
    
    var filteredSettlements: [Settlement] {
        switch filter {
        case .active: return appViewModel.settlements.filter { !$0.isCompleted }
        case .completed: return appViewModel.settlements.filter { $0.isCompleted }
        }
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
                    
                    Text("Settlements")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button(action: { showingAdd = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.primary)
                            .padding(12)
                            .background(AppTheme.primary.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Filter Picker
                Picker("Filter", selection: $filter) {
                    ForEach(SettlementFilter.allCases) { f in
                        Text(f.rawValue).tag(f)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 20)
                .colorMultiply(AppTheme.primary)
                
                if filteredSettlements.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: filter == .active ? "paperplane" : "checkmark.seal")
                            .font(.system(size: 60))
                            .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
                        Text(filter == .active ? "No active settlements" : "No settled payments")
                            .font(Font.bodyText(size: 16))
                            .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5))
                    }
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredSettlements) { settlement in
                                NavigationLink(destination: SettlementDetailView(settlement: settlement).environmentObject(appViewModel)) {
                                    SettlementRow(settlement: settlement, currency: selectedCurrency)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAdd) {
            AddSettlementView()
                .environmentObject(appViewModel)
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
        .refreshable {
            await appViewModel.refresh(categories: [.settlements])
        }
    }
}

struct SettlementRow: View {
    let settlement: Settlement
    let currency: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(settlement.type == .receivable ? AppTheme.secondary.opacity(0.1) : AppTheme.tertiary.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: settlement.type == .receivable ? "arrow.down.left" : "arrow.up.right")
                    .foregroundColor(settlement.type == .receivable ? AppTheme.secondary : AppTheme.tertiary)
                    .font(.title3.bold())
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(settlement.personName)
                    .font(Font.headline(size: 18, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                
                Text(settlement.type == .receivable ? "OWES YOU" : "YOU OWE")
                    .font(Font.bodyText(size: 10, weight: .black))
                    .foregroundColor(AppTheme.onSurfaceVariant)
                    .tracking(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(settlement.remainingAmount, format: .currency(code: currency))
                    .font(Font.headline(size: 18, weight: .black))
                    .foregroundColor(settlement.type == .receivable ? AppTheme.secondary : AppTheme.onSurface)
                
                if settlement.remainingAmount < settlement.amount {
                    Text("Total: \(settlement.amount.formatted(.currency(code: currency)))")
                        .font(Font.bodyText(size: 10))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                }
            }
        }
        .padding(20)
        .glassCard()
    }
}
