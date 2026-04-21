//
//  todoApp.swift
//  todo
//
//  Created by 29 on 2026/4/21.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// MARK: - Data Model
struct TodoItem: Identifiable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
    
    /// Convert to Firestore dictionary
    var firestoreData: [String: Any] {
        return [
            "id": id.uuidString,
            "title": title,
            "isCompleted": isCompleted,
            "createdAt": Timestamp(date: createdAt)
        ]
    }
    
    /// Create from Firestore document
    static func fromFirestore(_ data: [String: Any]) -> TodoItem? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let title = data["title"] as? String,
              let isCompleted = data["isCompleted"] as? Bool,
              let timestamp = data["createdAt"] as? Timestamp else {
            return nil
        }
        return TodoItem(id: id, title: title, isCompleted: isCompleted, createdAt: timestamp.dateValue())
    }
}

// MARK: - View Model
class TodoViewModel: ObservableObject {
    @Published var todos: [TodoItem] = []
    
    private let db = Firestore.firestore()
    private let collectionName = "todos"
    private var listener: ListenerRegistration?
    
    init() {
        listenToFirestore()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Firestore Real-time Listener
    
    private func listenToFirestore() {
        listener = db.collection(collectionName)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("❌ Firestore listen error: \(error.localizedDescription)")
                    return
                }
                guard let documents = snapshot?.documents else { return }
                
                self.todos = documents.compactMap { doc in
                    TodoItem.fromFirestore(doc.data())
                }
            }
    }
    
    // MARK: - CRUD Operations
    
    /// Create — adds to Firestore, listener updates local array
    func addTodo(title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let newItem = TodoItem(title: trimmed)
        
        db.collection(collectionName).document(newItem.id.uuidString).setData(newItem.firestoreData) { error in
            if let error = error {
                print("❌ Error adding todo: \(error.localizedDescription)")
            }
        }
    }
    
    /// Update - toggle completion
    func toggleCompletion(for item: TodoItem) {
        let newValue = !item.isCompleted
        db.collection(collectionName).document(item.id.uuidString).updateData([
            "isCompleted": newValue
        ]) { error in
            if let error = error {
                print("❌ Error toggling todo: \(error.localizedDescription)")
            }
        }
    }
    
    /// Update - rename
    func updateTitle(for item: TodoItem, newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        db.collection(collectionName).document(item.id.uuidString).updateData([
            "title": trimmed
        ]) { error in
            if let error = error {
                print("❌ Error updating title: \(error.localizedDescription)")
            }
        }
    }
    
    /// Delete from list by offsets
    func deleteTodo(at offsets: IndexSet, from list: [TodoItem]) {
        for index in offsets {
            let item = list[index]
            deleteFromFirestore(item)
        }
    }
    
    /// Delete a single item
    func deleteTodoItem(_ item: TodoItem) {
        deleteFromFirestore(item)
    }
    
    private func deleteFromFirestore(_ item: TodoItem) {
        db.collection(collectionName).document(item.id.uuidString).delete { error in
            if let error = error {
                print("❌ Error deleting todo: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var ongoingTodos: [TodoItem] {
        todos.filter { !$0.isCompleted }
    }
    
    var completedTodos: [TodoItem] {
        todos.filter { $0.isCompleted }
    }
    
    var totalCount: Int {
        todos.count
    }
    
    var completedCount: Int {
        completedTodos.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
}

@main
struct todoApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
    }
}
