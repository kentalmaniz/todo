//
//  ContentView.swift
//  todo
//
//  Created by 29 on 2026/4/21.
//

import SwiftUI

// MARK: - Main Content View
struct ContentView: View {
    let userId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: TodoViewModel
    
    init(userId: String) {
        self.userId = userId
        _viewModel = StateObject(wrappedValue: TodoViewModel(userId: userId))
    }
    
    @State private var newTaskTitle = ""
    @State private var selectedTab: TaskFilter = .all
    @State private var editingItem: TodoItem? = nil
    @State private var editText = ""
    @State private var showDeleteConfirm = false
    @State private var itemToDelete: TodoItem? = nil
    @FocusState private var isInputFocused: Bool
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    // MARK: - Theme Colors
    private var bgGradientTop: Color {
        isDarkMode ? Color(red: 0.07, green: 0.07, blue: 0.12) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    private var bgGradientBottom: Color {
        isDarkMode ? Color(red: 0.11, green: 0.11, blue: 0.18) : Color(red: 0.90, green: 0.91, blue: 0.95)
    }
    private var primaryText: Color {
        isDarkMode ? .white : Color(red: 0.12, green: 0.12, blue: 0.15)
    }
    private var secondaryText: Color {
        isDarkMode ? Color.white.opacity(0.6) : Color(red: 0.4, green: 0.4, blue: 0.45)
    }
    private var tertiaryText: Color {
        isDarkMode ? Color.white.opacity(0.3) : Color(red: 0.6, green: 0.6, blue: 0.65)
    }
    private var cardBg: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.white.opacity(0.85)
    }
    private var cardBgDimmed: Color {
        isDarkMode ? Color.white.opacity(0.03) : Color.white.opacity(0.55)
    }
    private var cardStroke: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.06)
    }
    private var inputBg: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.white.opacity(0.9)
    }
    private var inputStroke: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.08)
    }
    private var badgeBg: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.05)
    }
    private var badgeStroke: Color {
        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.08)
    }
    private var trackBg: Color {
        isDarkMode ? Color.white.opacity(0.08) : Color.black.opacity(0.06)
    }
    private var tabActiveBg: Color {
        isDarkMode ? Color.white.opacity(0.12) : Color.white.opacity(0.9)
    }
    private var tabCountBgActive: Color {
        isDarkMode ? Color.white.opacity(0.2) : Color.black.opacity(0.08)
    }
    private var tabCountBgInactive: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
    }
    private var tabInactiveText: Color {
        isDarkMode ? Color.white.opacity(0.45) : Color.black.opacity(0.4)
    }
    private var sheetBg: Color {
        isDarkMode ? Color(red: 0.09, green: 0.09, blue: 0.14) : Color(red: 0.95, green: 0.95, blue: 0.97)
    }
    private var checkboxStroke: Color {
        isDarkMode ? Color.white.opacity(0.25) : Color.black.opacity(0.2)
    }
    private var emptyIconColor: Color {
        isDarkMode ? Color.white.opacity(0.15) : Color.black.opacity(0.1)
    }
    private var emptyTitleColor: Color {
        isDarkMode ? Color.white.opacity(0.3) : Color.black.opacity(0.25)
    }
    private var emptySubColor: Color {
        isDarkMode ? Color.white.opacity(0.18) : Color.black.opacity(0.15)
    }
    private var accentBlue: Color {
        Color(red: 0.4, green: 0.6, blue: 1.0)
    }
    private var completedGreen: Color {
        Color(red: 0.35, green: 0.85, blue: 0.55)
    }
    private var ongoingAmber: Color {
        Color(red: 1.0, green: 0.75, blue: 0.35)
    }
    private var deleteRed: Color {
        Color(red: 1.0, green: 0.4, blue: 0.4)
    }
    private var completedTextColor: Color {
        isDarkMode ? Color.white.opacity(0.35) : Color.black.opacity(0.3)
    }
    private var strikethroughColor: Color {
        isDarkMode ? Color.white.opacity(0.25) : Color.black.opacity(0.2)
    }
    private var sheetFieldBg: Color {
        isDarkMode ? Color.white.opacity(0.06) : Color.black.opacity(0.04)
    }
    private var sheetFieldStroke: Color {
        isDarkMode ? Color.white.opacity(0.1) : Color.black.opacity(0.08)
    }
    private var sheetSectionBg: Color {
        isDarkMode ? Color.white.opacity(0.04) : Color.black.opacity(0.03)
    }
    private var cancelButtonColor: Color {
        isDarkMode ? Color.white.opacity(0.6) : Color.black.opacity(0.5)
    }
    
    enum TaskFilter: String, CaseIterable {
        case all = "All"
        case ongoing = "Ongoing"
        case done = "Done"
    }
    
    var filteredTodos: [TodoItem] {
        switch selectedTab {
        case .all: return viewModel.todos
        case .ongoing: return viewModel.ongoingTodos
        case .done: return viewModel.completedTodos
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [bgGradientTop, bgGradientBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.35), value: isDarkMode)
                
                VStack(spacing: 0) {
                    // MARK: - Header & Progress
                    headerSection
                    
                    // MARK: - Filter Tabs
                    filterTabs
                    
                    // MARK: - Task List
                    taskList
                    
                    // MARK: - Add Task Input
                    addTaskBar
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.35), value: isDarkMode)
        .alert("Delete Task", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { itemToDelete = nil }
            Button("Delete", role: .destructive) {
                if let item = itemToDelete {
                    withAnimation(.spring(response: 0.4)) {
                        viewModel.deleteTodoItem(item)
                    }
                    itemToDelete = nil
                }
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .sheet(item: $editingItem) { item in
            editTaskSheet(item: item)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greetingText)
                        .font(.subheadline)
                        .foregroundColor(secondaryText)
                    Text("My Tasks")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(primaryText)
                }
                Spacer()
                
                // Logout button
                Button {
                    authViewModel.logout()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(badgeBg)
                                .overlay(
                                    Circle()
                                        .stroke(badgeStroke, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Dark/Light mode toggle
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isDarkMode.toggle()
                    }
                } label: {
                    Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                        .font(.system(size: 18))
                        .foregroundColor(isDarkMode ? Color(red: 1.0, green: 0.85, blue: 0.35) : Color(red: 0.45, green: 0.45, blue: 0.7))
                        .frame(width: 38, height: 38)
                        .background(
                            Circle()
                                .fill(badgeBg)
                                .overlay(
                                    Circle()
                                        .stroke(badgeStroke, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Stats badge
                VStack(spacing: 2) {
                    Text("\(viewModel.completedCount)/\(viewModel.totalCount)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(primaryText)
                    Text("done")
                        .font(.caption2)
                        .foregroundColor(secondaryText)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(badgeBg)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(badgeStroke, lineWidth: 1)
                        )
                )
            }
            
            // Progress bar
            progressBar
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }
    
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good Morning ☀️"
        case 12..<17: return "Good Afternoon 🌤"
        case 17..<21: return "Good Evening 🌅"
        default: return "Good Night 🌙"
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Progress")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(secondaryText)
                Spacer()
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track
                    RoundedRectangle(cornerRadius: 6)
                        .fill(trackBg)
                        .frame(height: 10)
                    
                    // Fill
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: progressGradientColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, geometry.size.width * viewModel.progress), height: 10)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                }
            }
            .frame(height: 10)
        }
    }
    
    private var progressColor: Color {
        switch viewModel.progress {
        case 0..<0.33: return Color(red: 1.0, green: 0.45, blue: 0.45)
        case 0.33..<0.66: return Color(red: 1.0, green: 0.75, blue: 0.35)
        case 0.66..<1.0: return Color(red: 0.45, green: 0.85, blue: 0.55)
        default: return Color(red: 0.35, green: 0.9, blue: 0.65)
        }
    }
    
    private var progressGradientColors: [Color] {
        switch viewModel.progress {
        case 0..<0.33: return [Color(red: 1.0, green: 0.35, blue: 0.35), Color(red: 1.0, green: 0.55, blue: 0.45)]
        case 0.33..<0.66: return [Color(red: 1.0, green: 0.65, blue: 0.25), Color(red: 1.0, green: 0.85, blue: 0.4)]
        case 0.66..<1.0: return [Color(red: 0.25, green: 0.78, blue: 0.45), Color(red: 0.45, green: 0.9, blue: 0.6)]
        default: return [Color(red: 0.2, green: 0.85, blue: 0.55), Color(red: 0.4, green: 0.95, blue: 0.7)]
        }
    }
    
    // MARK: - Filter Tabs
    private var filterTabs: some View {
        HStack(spacing: 6) {
            ForEach(TaskFilter.allCases, id: \.self) { filter in
                let count: Int = {
                    switch filter {
                    case .all: return viewModel.totalCount
                    case .ongoing: return viewModel.ongoingTodos.count
                    case .done: return viewModel.completedTodos.count
                    }
                }()
                
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedTab = filter
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(filter.rawValue)
                            .font(.subheadline)
                            .fontWeight(selectedTab == filter ? .semibold : .regular)
                        
                        Text("\(count)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(selectedTab == filter
                                          ? tabCountBgActive
                                          : tabCountBgInactive)
                            )
                    }
                    .foregroundColor(selectedTab == filter ? primaryText : tabInactiveText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(selectedTab == filter
                                  ? tabActiveBg
                                  : Color.clear)
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
    
    // MARK: - Task List
    private var taskList: some View {
        Group {
            if filteredTodos.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredTodos) { item in
                        taskRow(item: item)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 20, bottom: 4, trailing: 20))
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    itemToDelete = item
                                    showDeleteConfirm = true
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button {
                                    editingItem = item
                                    editText = item.title
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(accentBlue)
                            }
                    }
                    .onDelete { offsets in
                        viewModel.deleteTodo(at: offsets, from: filteredTodos)
                    }
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: emptyStateIcon)
                .font(.system(size: 52))
                .foregroundColor(emptyIconColor)
            
            Text(emptyStateMessage)
                .font(.headline)
                .foregroundColor(emptyTitleColor)
            
            Text(emptyStateSubtitle)
                .font(.subheadline)
                .foregroundColor(emptySubColor)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    private var emptyStateIcon: String {
        switch selectedTab {
        case .all: return "checklist"
        case .ongoing: return "clock"
        case .done: return "checkmark.seal"
        }
    }
    
    private var emptyStateMessage: String {
        switch selectedTab {
        case .all: return "No tasks yet"
        case .ongoing: return "No ongoing tasks"
        case .done: return "No completed tasks"
        }
    }
    
    private var emptyStateSubtitle: String {
        switch selectedTab {
        case .all: return "Add your first task below to get started"
        case .ongoing: return "All caught up! 🎉"
        case .done: return "Complete a task to see it here"
        }
    }
    
    // MARK: - Task Row
    private func taskRow(item: TodoItem) -> some View {
        HStack(spacing: 14) {
            // Checkbox
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    viewModel.toggleCompletion(for: item)
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted
                                ? completedGreen
                                : checkboxStroke,
                                lineWidth: 2)
                        .frame(width: 26, height: 26)
                    
                    if item.isCompleted {
                        Circle()
                            .fill(completedGreen)
                            .frame(width: 26, height: 26)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Title & date
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.isCompleted ? completedTextColor : primaryText)
                    .strikethrough(item.isCompleted, color: strikethroughColor)
                    .lineLimit(2)
                
                Text(item.createdAt, style: .relative)
                    .font(.caption2)
                    .foregroundColor(tertiaryText)
                + Text(" ago")
                    .font(.caption2)
                    .foregroundColor(tertiaryText)
            }
            
            Spacer()
            
            // Status indicator
            if item.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(completedGreen)
                    .font(.system(size: 14))
            } else {
                Circle()
                    .fill(ongoingAmber)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(item.isCompleted ? cardBgDimmed : cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(cardStroke, lineWidth: 1)
                )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            editingItem = item
            editText = item.title
        }
    }
    
    // MARK: - Add Task Bar
    private var addTaskBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(accentBlue)
                    .font(.system(size: 22))
                
                TextField("Add a new task...", text: $newTaskTitle)
                    .font(.system(size: 16))
                    .foregroundColor(primaryText)
                    .accentColor(accentBlue)
                    .focused($isInputFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        addNewTask()
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(inputBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isInputFocused
                                ? accentBlue.opacity(0.5)
                                : inputStroke,
                                lineWidth: 1
                            )
                    )
            )
            
            if !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    addNewTask()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(accentBlue)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            bgGradientTop
                .opacity(0.95)
                .ignoresSafeArea(edges: .bottom)
        )
        .animation(.easeInOut(duration: 0.2), value: newTaskTitle)
    }
    
    private func addNewTask() {
        let title = newTaskTitle
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            viewModel.addTodo(title: title)
            newTaskTitle = ""
            if selectedTab == .done {
                selectedTab = .all
            }
        }
        isInputFocused = false
    }
    
    // MARK: - Edit Sheet
    private func editTaskSheet(item: TodoItem) -> some View {
        NavigationView {
            ZStack {
                sheetBg
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Task Name")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(secondaryText)
                            .textCase(.uppercase)
                        
                        TextField("Task name", text: $editText)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(primaryText)
                            .accentColor(accentBlue)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(sheetFieldBg)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(sheetFieldStroke, lineWidth: 1)
                                    )
                            )
                    }
                    
                    // Status toggle
                    HStack {
                        Text("Status")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(secondaryText)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        Text(item.isCompleted ? "Completed ✓" : "Ongoing")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(item.isCompleted ? completedGreen : ongoingAmber)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(item.isCompleted
                                          ? completedGreen.opacity(0.15)
                                          : ongoingAmber.opacity(0.15))
                            )
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(sheetSectionBg)
                    )
                    
                    // Created date
                    HStack {
                        Text("Created")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(secondaryText)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        Text(item.createdAt, format: .dateTime.day().month().year().hour().minute())
                            .font(.subheadline)
                            .foregroundColor(secondaryText)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(sheetSectionBg)
                    )
                    
                    // Delete button
                    Button {
                        editingItem = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                viewModel.deleteTodoItem(item)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Task")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(deleteRed)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(deleteRed.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(deleteRed.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    
                    Spacer()
                }
                .padding(20)
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        editingItem = nil
                    }
                    .foregroundColor(cancelButtonColor)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateTitle(for: item, newTitle: editText)
                        editingItem = nil
                    }
                    .fontWeight(.semibold)
                    .foregroundColor(accentBlue)
                }
            }
            .toolbarBackground(sheetBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(isDarkMode ? .dark : .light, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(userId: "preview_user_id")
            .preferredColorScheme(.dark)
            .environmentObject(AuthViewModel())
    }
}
