# 🌌 Zenith: Premium Wealth Management

[![Swift](https://img.shields.io/badge/Swift-6.0+-orange.svg?style=flat-square&logo=swift)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2018.6+-black.svg?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![SwiftData](https://img.shields.io/badge/Database-SwiftData-blue.svg?style=flat-square)](https://developer.apple.com/xcode/swiftdata/)
[![License](https://img.shields.io/badge/License-MIT-green.svg?style=flat-square)](LICENSE)

**Zenith** is a high-fidelity, local-first wealth management application designed for those who demand both precision and beauty in their financial tracking. Built with SwiftUI and powered by the latest SwiftData framework, Zenith offers a seamless, secure, and aesthetically stunning experience.

---

## ✨ Key Features

### 💎 Unified Wealth Dashboard
Get a high-level view of your "Spending Power." Zenith aggregates all your included money sources to give you a real-time understanding of your available liquidity, distinct from your total net worth.

### 🏦 Dynamic Money Sources
Track your wealth across multiple dimensions. From traditional bank accounts and physical cash to crypto and investments, you can:
*   **Toggle Inclusion**: Decide which assets contribute to your daily spending power.
*   **Multi-Account Tracking**: Real-time balance adjustments across all sources.
*   **Custom Icons**: Personalize each source with SF Symbols.

### 📈 Intelligent Transaction Engine
Logging expenses should be as fluid as spending.
*   **Dynamic Categories**: Create and customize categories with full SF Symbol support.
*   **Income vs. Expense**: Clearly demarcated flows with visual indicators.
*   **Automatic Seed**: Starts with a sensible default set of categories to get you running instantly.

### 🎯 Financial Health Suite
*   **Savings Goals**: Track your progress towards major life milestones with visual progress rings.
*   **Settlements & Debt Control**: Keep track of "Who owes me" and "Who do I owe" in one unified space.
*   **Subscription Monitor**: Never get surprised by a recurring payment again. View upcoming costs in a dedicated list.

### 🛡️ Privacy & Security First
Your financial data is yours alone.
*   **Biometric Protection**: Integrated Face ID/Touch ID locking ensures your data remains private even if your device is unlocked.
*   **Local-First Architecture**: Your data lives on your device, powered by SwiftData's robust persistence layer.

---

## 🎨 Design Philosophy: "The Living App"

Zenith isn't just a spreadsheet; it's a living environment.

*   **Atmospheric "Living Background"**: A dynamic, blurred gradient system that breathes as you navigate.
*   **Modern Glassmorphism**: Utilizes `ultraThinMaterial` and custom glass effects for a premium, layered feel.
*   **Custom Curved Navigation**: A bespoke tab bar design that breaks the standard iOS mold for a more organic experience.
*   **Pure Dark Mode**: Optimized for OLED displays with a deep navy (#070d1f) and vibrant purple (#cc97ff) palette.

---

## 🛠️ Technical Stack

*   **UI Framework**: SwiftUI (NavigationStack, Sheets, Custom Shapes)
*   **Data Persistence**: SwiftData (@Query, @Model, ModelContainer)
*   **Security**: LocalAuthentication (Face ID/Touch ID)
*   **Architecture**: MVVM with SwiftData's context-driven approach.

---

## 🚀 Getting Started

### Prerequisites
*   Xcode 16.0+
*   iOS 18.6+ (Simulator or Physical Device)

### Installation
1.  Clone the repository:
    ```bash
    git clone https://github.com/yourusername/Zenith.git
    ```
2.  Open `Zenith.xcodeproj` in Xcode.
3.  Select your target (iPhone/iPad) and press **Cmd + R** to run.

---

## 📖 Comprehensive User Guide

### 1. Onboarding & Initial Setup
When you first launch Zenith, you'll be guided through a premium multi-step onboarding process:
- **Feature Highlights**: Learn about Wealth Tracking and Financial Goals.
- **Security Check**: Enable **Face ID** or **Touch ID** on the final slide to protect your records immediately.
- **Data Seeding**: Zenith automatically seeds the database with a robust set of financial categories so you can start logging transactions right away.

### 2. Mastering the Wealth Dashboard
The Dashboard is your financial command center.
- **Total Net Worth**: The aggregate value of all your connected Money Sources.
- **Active Spending Power**: This is a unique Zenith metric. It only includes the balances of Money Sources that you have explicitly marked as "Include in Budget." 
- **Quick Add**: Use the floating diamond button (`+`) in the center of the navigation bar to quickly record new income or expenses.

### 3. Managing Money Sources
Navigate to the **Wealth** or **Tools** section to manage your accounts:
- **Adding Sources**: Tap the `+` icon to add a new account or asset.
- **Icon Customization**: Choose from a curated list of SF Symbols to represent each source.
- **Spending Power Toggle**: Edit any source to turn "Include in Monthly Budget" on or off. This allows you to track long-term assets separately from your daily spending cash.

### 4. Intelligent Transactions & Categories
Zenith makes expense tracking effortless:
- **Logging**: Select a category, enter an amount, and choose which Money Source the funds are coming from/going to.
- **Dynamic Categories**: Go to **Tools > Categories** to add your own custom categories with unique icons.
- **Activity Filtering**: View recent activity on the dashboard or dive into the **Activity** tab for a full historical record.

### 5. Achieving Savings Goals
Visual progress is the key to consistency:
- **Creating Goals**: Set a target amount and a deadline.
- **Visual Feedback**: The dashboard displays visual rings that fill up as your allocated savings grow.
- **Milestones**: Track progress percentages in real-time.

### 6. Professional Financial Tools
- **Subscriptions**: Log recurring payments to see a unified list of your monthly commitments.
- **Settlements (Debts)**: Track "Who owes me" and "Who do I owe." Zenith handles the balancing so you always know your standing with others.

---

## 📸 Screenshots
*(Coming Soon - Add your screenshots here!)*

> [!TIP]
> Use the **Tools** tab to access the Subscription and Settlement managers for advanced financial control.

---

## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Crafted with ❤️ for a better financial future.*
