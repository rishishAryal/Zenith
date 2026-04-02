import SwiftUI
import SwiftData

struct CategorySettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.name) private var categories: [Category]
    @State private var showingAddSheet = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            LivingBackground()
            
            VStack(spacing: 0) {
                // Header (Circular Back Button style consistent with app)
                HStack {
                    Button(action: { dismiss() }) {
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 44, height: 44)
                            .overlay(
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(AppTheme.onSurface)
                            )
                    }
                    
                    Spacer()
                    
                    Text("Categories")
                        .font(Font.headline(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.onSurface)
                    
                    Spacer()
                    
                    Button(action: { showingAddSheet = true }) {
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
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(categories) { category in
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .fill(Color(hex: category.colorHex).opacity(0.1))
                                            .frame(width: 44, height: 44)
                                        
                                        Image(systemName: category.iconName)
                                            .foregroundColor(Color(hex: category.colorHex))
                                            .font(.title3)
                                    }
                                    
                                    Spacer()
                                    
                                    if category.name != "General" {
                                        Button(action: {
                                            modelContext.delete(category)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 14))
                                                .foregroundColor(AppTheme.error.opacity(0.4))
                                                .padding(8)
                                        }
                                    }
                                }
                                
                                Text(category.name)
                                    .font(Font.headline(size: 16, weight: .bold))
                                    .foregroundColor(AppTheme.onSurface)
                                    .lineLimit(1)
                            }
                            .padding(16)
                            .glassCard()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddCategoryView()
                .presentationDetents([.fraction(0.8)])
                .presentationBackground(.ultraThinMaterial)
        }
    }
}

struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedIcon = "tag.fill"
    
    // Curated list of SF Symbols for finance/lifestyle
    private let icons = [
        "tag.fill", "cart.fill", "bag.fill", "fork.knife", "cup.and.saucer.fill",
        "airplane", "car.fill", "bus.fill", "bolt.fill", "drop.fill",
        "heart.fill", "pills.fill", "cross.case.fill", "gift.fill", "star.fill",
        "house.fill", "tv.fill", "music.note", "gamecontroller.fill", "book.fill",
        "creditcard.fill", "banknote.fill", "dollarsign.circle.fill", "chart.pie.fill",
        "briefcase.fill", "hammer.fill", "wrench.and.screwdriver.fill", "pawprint.fill",
        "leaf.fill", "sun.max.fill"
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            HStack {
                Text("New Category")
                    .font(Font.headline(size: 24, weight: .bold))
                    .foregroundColor(AppTheme.onSurface)
                Spacer()
                Button("Close") { dismiss() }
                    .foregroundColor(AppTheme.onSurfaceVariant)
            }
            
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("NAME")
                        .font(Font.bodyText(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .tracking(2)
                    TextField("E.g. Fitness, Hobbies...", text: $name)
                        .padding()
                        .background(AppTheme.surfaceContainer)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("SELECT ICON")
                        .font(Font.bodyText(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.onSurfaceVariant)
                        .tracking(2)
                    
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 20) {
                            ForEach(icons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.title2)
                                    .foregroundColor(selectedIcon == icon ? AppTheme.primary : AppTheme.onSurfaceVariant)
                                    .frame(width: 50, height: 50)
                                    .background(selectedIcon == icon ? AppTheme.primary.opacity(0.2) : AppTheme.surfaceContainer)
                                    .clipShape(Circle())
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .frame(maxHeight: 300)
                }
            }
            
            Spacer()
            
            Button(action: save) {
                Text("Create Category")
                    .font(Font.headline(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background {
                        if name.isEmpty {
                            AppTheme.surfaceContainer
                        } else {
                            AppTheme.primaryGradient
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(name.isEmpty)
        }
        .padding(24)
    }
    
    private func save() {
        let newCategory = Category(name: name, iconName: selectedIcon)
        modelContext.insert(newCategory)
        dismiss()
    }
}
