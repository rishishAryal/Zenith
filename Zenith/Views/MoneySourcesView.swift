import SwiftUI
import SwiftData

struct MoneySourcesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \MoneySource.name) private var sources: [MoneySource]
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    @State private var showingAddSource = false
    @State private var editingSource: MoneySource?
    
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
                    
                    Text("Money Sources")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button(action: { showingAddSource = true }) {
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        if sources.isEmpty {
                            VStack(spacing: 20) {
                                Image(systemName: "building.columns")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
                                Text("No sources found. Add your bank accounts or cash to start tracking.")
                                    .font(Font.bodyText(size: 16))
                                    .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.top, 100)
                            .padding(.horizontal, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(sources) { source in
                                    Button(action: { editingSource = source }) {
                                        SourceRow(source: source, currency: selectedCurrency)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSource) {
            AddSourceView()
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
        .sheet(item: $editingSource) { source in
            EditSourceView(source: source)
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct SourceRow: View {
    let source: MoneySource
    let currency: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(AppTheme.primary.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Image(systemName: source.icon)
                    .foregroundColor(AppTheme.primary)
                    .font(.title3)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(source.name)
                    .font(Font.headline(size: 16, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                
                if !source.includeInBudget {
                    Text("EXCLUDED FROM BUDGET")
                        .font(Font.bodyText(size: 8, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .tracking(1)
                }
            }
            
            Spacer()
            
            Text(source.balance, format: .currency(code: currency))
                .font(Font.headline(size: 18, weight: .black))
                .foregroundColor(source.includeInBudget ? AppTheme.secondary : AppTheme.onSurfaceVariant)
        }
        .padding(16)
        .glassCard()
    }
}

struct AddSourceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var balance: Double = 0
    @State private var icon = "creditcard"
    @State private var includeInBudget = true
    
    let icons = ["creditcard", "banknote", "wallet.pass", "building.columns", "dollarsign.circle", "bitcoinsign.circle"]
    
    var body: some View {
        ZStack {
            LivingBackground()
            VStack(spacing: 32) {
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("New Source")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button("Register") { save() }
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                }
                .padding(.top, 10)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SOURCE NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                        TextField("e.g. Chase Bank, Cash...", text: $name)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("INITIAL BALANCE")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                        TextField("0", value: $balance, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CHOOSE ICON")
                            .font(Font.bodyText(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.onSurfaceVariant)
                        HStack(spacing: 12) {
                            ForEach(icons, id: \.self) { i in
                                Image(systemName: i)
                                    .font(.title2)
                                    .foregroundColor(icon == i ? AppTheme.primary : AppTheme.onSurfaceVariant)
                                    .frame(width: 44, height: 44)
                                    .background(icon == i ? AppTheme.primary.opacity(0.1) : AppTheme.surfaceContainer)
                                    .clipShape(Circle())
                                    .onTapGesture { icon = i }
                            }
                        }
                    }
                    
                    Toggle(isOn: $includeInBudget) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Include in Monthly Budget")
                                .font(Font.headline(size: 16, weight: .bold))
                            Text("Total balances of included sources define your spending power.")
                                .font(Font.bodyText(size: 12))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                        }
                    }
                    .tint(AppTheme.primary)
                    .padding(.top, 12)
                }
                
                Spacer()
                
            }
            .padding(24)
        }
    }
    
    private func save() {
        let source = MoneySource(name: name, balance: balance, icon: icon, includeInBudget: includeInBudget)
        modelContext.insert(source)
        dismiss()
    }
}

struct EditSourceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let source: MoneySource
    
    @State private var name: String
    @State private var balance: Double
    @State private var includeInBudget: Bool
    
    init(source: MoneySource) {
        self.source = source
        _name = State(initialValue: source.name)
        _balance = State(initialValue: source.balance)
        _includeInBudget = State(initialValue: source.includeInBudget)
    }
    
    var body: some View {
        ZStack {
            LivingBackground()
            VStack(spacing: 32) {
                HStack {
                    Button("Close") { dismiss() }
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text("Edit Source")
                        .font(Font.headline(size: 20, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button("Update") { save() }
                        .font(.headline)
                        .foregroundColor(AppTheme.primary)
                        .disabled(name.isEmpty)
                        .opacity(name.isEmpty ? 0.5 : 1)
                }
                .padding(.top, 10)
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SOURCE NAME")
                            .font(Font.bodyText(size: 10, weight: .bold))
                        TextField("Name", text: $name)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ADJUST BALANCE")
                            .font(Font.bodyText(size: 10, weight: .bold))
                        TextField("0", value: $balance, format: .number)
                            .keyboardType(.decimalPad)
                            .padding()
                            .background(AppTheme.surfaceContainer)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    
                    Toggle("Include in Monthly Budget", isOn: $includeInBudget)
                        .tint(AppTheme.primary)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(role: .destructive, action: delete) {
                        Text("Remove Source")
                            .font(Font.headline(size: 16))
                            .foregroundColor(AppTheme.error)
                    }
                    .padding(.top, 12)
                }
            }
            .padding(24)
        }
    }
    
    private func save() {
        source.name = name
        source.balance = balance
        source.includeInBudget = includeInBudget
        dismiss()
    }
    
    private func delete() {
        modelContext.delete(source)
        dismiss()
    }
}
