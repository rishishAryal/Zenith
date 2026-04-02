import SwiftUI
import SwiftData
@MainActor
struct ToolsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage("requiresFaceID") private var requiresFaceID = false
    @AppStorage("currency") private var selectedCurrency = "USD"
    
    let currencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR", "NPR"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LivingBackground()
                
                VStack(spacing: 0) {
                    // Top Navigation Header
                    HStack {
                        Text("Tools")
                            .font(Font.headline(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.onSurface)
                        
                        Spacer()
                        
                        Text("Zenith")
                            .font(Font.headline(size: 24, weight: .black))
                            .foregroundStyle(AppTheme.primaryGradient)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    ScrollView {
                        VStack(spacing: 30) {
                            
                        // Tools Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("TOOLS")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: MoneySourcesView()) {
                                    SettingsRow(icon: "creditcard", title: "Money Sources", iconColor: AppTheme.primary)
                                }
                                
                                Divider().background(AppTheme.outline.opacity(0.1)).padding(.horizontal, 20)
                                
                                NavigationLink(destination: SettlementsView()) {
                                    SettingsRow(icon: "arrow.left.arrow.right", title: "Settlements", iconColor: AppTheme.tertiary)
                                }
                            }
                            .glassCard()
                        }
                        .padding(.horizontal)
                            
                        // Wealth Management section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("WEALTH MANAGEMENT")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                NavigationLink(destination: SubscriptionsView()) {
                                    SettingsRow(icon: "calendar.badge.clock", title: "Subscriptions", iconColor: AppTheme.primary)
                                }
                                
                                Divider().background(AppTheme.outline.opacity(0.1)).padding(.horizontal, 20)
                                
                                NavigationLink(destination: SavingsGoalsView(isNavigated: true)) {
                                    SettingsRow(icon: "target", title: "Savings Goals", iconColor: AppTheme.secondary)
                                }
                            }
                            .glassCard()
                        }
                        .padding(.horizontal)
                        
                        // Security & Preferences
                        VStack(alignment: .leading, spacing: 16) {
                            Text("PREFERENCES")
                                .font(Font.bodyText(size: 10, weight: .bold))
                                .foregroundColor(AppTheme.onSurfaceVariant)
                                .tracking(2)
                                .padding(.horizontal)
                                
                            NavigationLink(destination: CategorySettingsView()) {
                                SettingsRow(icon: "tag", title: "Manage Categories", iconColor: AppTheme.tertiary)
                            }
                            .glassCard()
                            
                            // FaceID
                            HStack {
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.primary.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                        .overlay(Image(systemName: "faceid").foregroundColor(AppTheme.primary))
                                    
                                    Text("FaceID")
                                        .font(Font.headline(size: 18, weight: .bold))
                                }
                                Spacer()
                                Toggle("", isOn: $requiresFaceID)
                                    .labelsHidden()
                                    .tint(AppTheme.primary)
                            }
                            .padding(24)
                            .glassCard()
                            
                            // Currency
                            HStack {
                                HStack(spacing: 12) {
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .fill(AppTheme.tertiary.opacity(0.1))
                                        .frame(width: 36, height: 36)
                                        .overlay(Image(systemName: "globe").foregroundColor(AppTheme.tertiary))
                                    
                                    Text("Currency")
                                        .font(Font.headline(size: 18, weight: .bold))
                                }
                                Spacer()
                                
                                Picker("Currency", selection: $selectedCurrency) {
                                    ForEach(currencies, id: \.self) { c in
                                        Text(c).tag(c)
                                    }
                                }
                                .tint(AppTheme.onSurface)
                                .font(.headline)
                            }
                            .padding(24)
                            .glassCard()
                        }
                        .padding(.horizontal)
                        
                        // Bottom Padding for custom tab bar
                        Spacer().frame(height: 120)
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}
}

struct SettingsRow: View {
    let icon: String
    let title: String
    var color: Color = AppTheme.onSurface
    var iconColor: Color = AppTheme.onSurfaceVariant
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(iconColor.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundColor(iconColor)
            }
            
            Text(title)
                .font(Font.headline(size: 18, weight: .bold))
                .foregroundColor(color)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(Font.headline(size: 14, weight: .bold))
                .foregroundColor(AppTheme.onSurfaceVariant.opacity(0.3))
        }
        .padding(16)
    }
}
