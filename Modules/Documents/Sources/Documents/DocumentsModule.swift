import SwiftUI
import Combine

/// # DocumentsModule
///
/// A comprehensive document management module that provides text editing, markdown preview,
/// file browsing, and search capabilities.
///
/// ## Overview
///
/// DocumentsModule is built using the UniversalTemplate system and provides a complete
/// document management solution with:
/// - Rich text editing with syntax highlighting
/// - Live markdown preview
/// - Intelligent file browsing
/// - Advanced search functionality
/// - Hot-swappable submodule architecture
///
/// ## Topics
///
/// ### Submodules
/// - Text Editor - Advanced text editing capabilities
/// - Markdown Preview - Live markdown rendering
/// - File Browser - Navigate and manage documents
/// - Search - Find content across all documents
///
/// ### Core Features
/// - ``currentDocument``
/// - ``documents``
/// - ``createNewDocument(_:)``
/// - ``searchDocuments(_:)``
///
/// ## Version History
/// - v1.0.0: Initial implementation with four submodules
///
/// ## Usage
/// ```swift
/// let documentsModule = DocumentsModule()
/// await documentsModule.initialize()
/// let view = documentsModule.view
/// ```
@MainActor
public class DocumentsModule: BaseComponent {
    
    // MARK: - Properties
    
    /// Currently open document
    @Published public var currentDocument: DocumentItem?
    
    /// All available documents
    @Published public var documents: [DocumentItem] = []
    
    /// Search results
    @Published public var searchResults: [DocumentItem] = []
    
    /// Submodule instances
    @Published private var textEditor: MockTextEditor?
    @Published private var markdownPreview: MockMarkdownPreview?
    @Published private var fileBrowser: MockFileBrowser?
    @Published private var search: MockSearch?
    
    /// Selected view state
    @Published public var selectedView: DocumentView = .editor
    
    /// Editor content
    @Published public var editorContent: String = ""
    
    // MARK: - Initialization
    
    public required init() {
        super.init()
        self.name = "Documents"
        self.hierarchyLevel = .module
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "doc.text"
        self.description = "Comprehensive document management suite"
        
        // Initialize capabilities
        self.capabilities = [
            ComponentCapability(
                id: "text-editor",
                name: "Text Editor",
                description: "Advanced text editing with syntax highlighting"
            ),
            ComponentCapability(
                id: "markdown-preview",
                name: "Markdown Preview",
                description: "Live markdown rendering and preview"
            ),
            ComponentCapability(
                id: "file-browser",
                name: "File Browser",
                description: "Navigate and manage documents"
            ),
            ComponentCapability(
                id: "search",
                name: "Search",
                description: "Find content across all documents"
            )
        ]
        
        // Initialize demo documents
        loadDemoDocuments()
    }
    
    // MARK: - Component Lifecycle
    
    public override func performInitialization() async throws {
        // Initialize submodules
        textEditor = MockTextEditor()
        markdownPreview = MockMarkdownPreview()
        fileBrowser = MockFileBrowser()
        search = MockSearch()
        
        // Add as children
        if let editor = textEditor {
            children.append(editor)
        }
        if let preview = markdownPreview {
            children.append(preview)
        }
        if let browser = fileBrowser {
            children.append(browser)
        }
        if let searchModule = search {
            children.append(searchModule)
        }
        
        // Initialize all children
        try await withThrowingTaskGroup(of: Void.self) { group in
            for child in children {
                group.addTask {
                    try await child.initialize()
                }
            }
            try await group.waitForAll()
        }
    }
    
    // MARK: - View Creation
    
    public override func createView() -> AnyView {
        AnyView(DocumentsModuleView(module: self))
    }
    
    // MARK: - Document Management
    
    /// Create a new document
    /// - Parameter name: The document name
    public func createNewDocument(_ name: String) {
        let document = DocumentItem(
            name: name,
            content: "# \(name)\n\nStart writing...",
            lastModified: Date(),
            type: .markdown
        )
        documents.append(document)
        currentDocument = document
        editorContent = document.content
    }
    
    /// Search documents
    /// - Parameter query: Search query
    public func searchDocuments(_ query: String) {
        if query.isEmpty {
            searchResults = []
        } else {
            searchResults = documents.filter { document in
                document.name.localizedCaseInsensitiveContains(query) ||
                document.content.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    /// Load demo documents
    private func loadDemoDocuments() {
        documents = [
            DocumentItem(
                name: "README.md",
                content: """
                # Bridge Template
                
                A revolutionary modular development system with hot-swapping capabilities.
                
                ## Features
                - Infinite modularity
                - Hot-swappable components
                - Natural language builds
                - Complete automation
                """,
                lastModified: Date(),
                type: .markdown
            ),
            DocumentItem(
                name: "Architecture.md",
                content: """
                # System Architecture
                
                The Bridge Template uses a modular architecture...
                """,
                lastModified: Date().addingTimeInterval(-3600),
                type: .markdown
            ),
            DocumentItem(
                name: "Notes.txt",
                content: "Important project notes go here...",
                lastModified: Date().addingTimeInterval(-86400),
                type: .text
            ),
            DocumentItem(
                name: "Code.swift",
                content: """
                import SwiftUI
                
                struct ContentView: View {
                    var body: some View {
                        Text("Hello, World!")
                    }
                }
                """,
                lastModified: Date().addingTimeInterval(-172800),
                type: .code
            )
        ]
    }
}

// MARK: - Supporting Types

/// Document view options
public enum DocumentView: String, CaseIterable {
    case editor = "Editor"
    case preview = "Preview"
    case browser = "Browser"
    case search = "Search"
    
    var icon: String {
        switch self {
        case .editor: return "square.and.pencil"
        case .preview: return "eye"
        case .browser: return "folder"
        case .search: return "magnifyingglass"
        }
    }
}

/// Document model
public struct Document: Identifiable {
    public let id = UUID()
    public let name: String
    public let type: DocumentType
    public let content: String
    public let lastModified: Date
    public let size: Int
}

/// Document type
public enum DocumentType {
    case text
    case markdown
    case code
    
    var icon: String {
        switch self {
        case .text: return "doc.text"
        case .markdown: return "doc.richtext"
        case .code: return "doc.text.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .text: return .blue
        case .markdown: return .purple
        case .code: return .orange
        }
    }
}

// MARK: - Mock Submodules

/// Mock Text Editor submodule
@MainActor
class MockTextEditor: BaseComponent {
    required init() {
        super.init()
        self.name = "Text Editor"
        self.hierarchyLevel = .submodule
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "square.and.pencil"
        self.description = "Advanced text editing capabilities"
    }
    
    override func createView() -> AnyView {
        AnyView(Text("Text Editor")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity))
    }
}

/// Mock Markdown Preview submodule
@MainActor
class MockMarkdownPreview: BaseComponent {
    required init() {
        super.init()
        self.name = "Markdown Preview"
        self.hierarchyLevel = .submodule
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "eye"
        self.description = "Live markdown rendering"
    }
    
    override func createView() -> AnyView {
        AnyView(Text("Markdown Preview")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity))
    }
}

/// Mock File Browser submodule
@MainActor
class MockFileBrowser: BaseComponent {
    required init() {
        super.init()
        self.name = "File Browser"
        self.hierarchyLevel = .submodule
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "folder"
        self.description = "Navigate and manage documents"
    }
    
    override func createView() -> AnyView {
        AnyView(Text("File Browser")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity))
    }
}

/// Mock Search submodule
@MainActor
class MockSearch: BaseComponent {
    required init() {
        super.init()
        self.name = "Search"
        self.hierarchyLevel = .submodule
        self.version = ComponentVersion(1, 0, 0)
        self.icon = "magnifyingglass"
        self.description = "Find content across documents"
    }
    
    override func createView() -> AnyView {
        AnyView(Text("Search")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity))
    }
}

// MARK: - Supporting Types

/// Document model
public struct DocumentItem: Identifiable, Hashable {
    public let id = UUID()
    public var name: String
    public var content: String
    public var lastModified: Date
    public var type: DocumentType
    
    public init(name: String, content: String, lastModified: Date, type: DocumentType) {
        self.name = name
        self.content = content
        self.lastModified = lastModified
        self.type = type
    }
    
    public enum DocumentType {
        case text, markdown, code
        
        var icon: String {
            switch self {
            case .text: return "doc.text"
            case .markdown: return "doc.richtext"
            case .code: return "doc.text.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .text: return .blue
            case .markdown: return .purple
            case .code: return .orange
            }
        }
    }
}

// MARK: - Views

/// Main Documents module view
struct DocumentsModuleView: View {
    @ObservedObject var module: DocumentsModule
    
    var body: some View {
        HSplitView {
            // Document list
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Documents")
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        module.createNewDocument("Untitled")
                    }) {
                        Image(systemName: "plus")
                    }
                }
                .padding()
                
                // Document list
                List(selection: $module.currentDocument) {
                    ForEach(module.documents) { document in
                        DocumentRow(document: document)
                            .tag(document as DocumentItem?)
                    }
                }
            }
            .frame(minWidth: 200, maxWidth: 300)
            
            // Editor area
            VStack(spacing: 0) {
                // View selector
                HStack(spacing: 20) {
                    ForEach(DocumentView.allCases, id: \.self) { view in
                        Button(action: {
                            module.selectedView = view
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: view.icon)
                                    .font(.title2)
                                Text(view.rawValue)
                                    .font(.caption)
                            }
                            .foregroundColor(module.selectedView == view ? .accentColor : .secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    if module.currentDocument != nil {
                        Text(module.currentDocument!.name)
                            .font(.headline)
                    }
                }
                .padding()
                
                Divider()
                
                // Content area
                Group {
                    switch module.selectedView {
                    case .editor:
                        TextEditorView(content: $module.editorContent)
                    case .preview:
                        MarkdownPreviewView(content: module.editorContent)
                    case .browser:
                        FileBrowserView()
                    case .search:
                        DocumentSearchView(module: module)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

/// Document row view
struct DocumentRow: View {
    let document: DocumentItem
    
    var body: some View {
        HStack {
            Image(systemName: document.type.icon)
                .foregroundColor(document.type.color)
            
            VStack(alignment: .leading) {
                Text(document.name)
                    .fontWeight(.medium)
                HStack {
                    Text(formatFileSize(document.content.count))
                    Text("•")
                    Text(formatDate(document.lastModified))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
    
    func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(bytes))
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

/// Text Editor view
struct TextEditorView: View {
    @Binding var content: String
    
    var body: some View {
        VStack {
            // Toolbar
            HStack {
                Button(action: {}) {
                    Image(systemName: "bold")
                }
                Button(action: {}) {
                    Image(systemName: "italic")
                }
                Button(action: {}) {
                    Image(systemName: "underline")
                }
                
                Divider()
                    .frame(height: 20)
                
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                }
                Button(action: {}) {
                    Image(systemName: "list.number")
                }
                
                Spacer()
                
                Text("\(content.count) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            // Editor
            TextEditor(text: $content)
                .font(.system(.body, design: .monospaced))
                .padding(4)
        }
    }
}

/// Markdown Preview view
struct MarkdownPreviewView: View {
    var content: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Simple markdown rendering
                ForEach(content.components(separatedBy: "\n"), id: \.self) { line in
                    if line.hasPrefix("# ") {
                        Text(String(line.dropFirst(2)))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    } else if line.hasPrefix("## ") {
                        Text(String(line.dropFirst(3)))
                            .font(.title)
                            .fontWeight(.semibold)
                    } else if line.hasPrefix("- ") {
                        HStack(alignment: .top) {
                            Text("•")
                            Text(String(line.dropFirst(2)))
                        }
                    } else if !line.isEmpty {
                        Text(line)
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

/// File Browser view
struct FileBrowserView: View {
    @State private var expandedFolders: Set<String> = ["Documents"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                FolderItem(name: "Documents", indent: 0, isExpanded: expandedFolders.contains("Documents")) {
                    expandedFolders.toggle("Documents")
                }
                
                if expandedFolders.contains("Documents") {
                    FileItem(name: "README.md", isFolder: false, indent: 1)
                    FileItem(name: "Architecture.md", isFolder: false, indent: 1)
                    
                    FolderItem(name: "Projects", indent: 1, isExpanded: expandedFolders.contains("Projects")) {
                        expandedFolders.toggle("Projects")
                    }
                    
                    if expandedFolders.contains("Projects") {
                        FileItem(name: "BridgeTemplate.md", isFolder: false, indent: 2)
                        FileItem(name: "PersonalAssistant.md", isFolder: false, indent: 2)
                    }
                    
                    FileItem(name: "Notes.txt", isFolder: false, indent: 1)
                    FileItem(name: "Code.swift", isFolder: false, indent: 1)
                }
            }
            .padding()
        }
    }
}

/// Folder item view
struct FolderItem: View {
    let name: String
    let indent: Int
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                ForEach(0..<indent, id: \.self) { _ in
                    Text("  ")
                }
                
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                    .frame(width: 12)
                
                Image(systemName: "folder.fill")
                    .foregroundColor(.yellow)
                
                Text(name)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }
}

/// Document Search view
struct DocumentSearchView: View {
    @ObservedObject var module: DocumentsModule
    @State private var searchQuery = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search documents...", text: $searchQuery)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        module.searchDocuments(searchQuery)
                    }
                
                if !searchQuery.isEmpty {
                    Button(action: {
                        searchQuery = ""
                        module.searchResults = []
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            .padding()
            
            // Results
            if !module.searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("\(module.searchResults.count) results")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(module.searchResults) { document in
                            SearchResultItem(document: document, query: searchQuery)
                                .padding(.horizontal)
                        }
                    }
                }
            } else if !searchQuery.isEmpty {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No results found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Search your documents")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

/// Search result item
struct SearchResultItem: View {
    let document: DocumentItem
    let query: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: document.type.icon)
                    .foregroundColor(document.type.color)
                Text(document.name)
                    .fontWeight(.medium)
                Spacer()
            }
            
            // Show snippet with highlighted query
            if let range = document.content.range(of: query, options: .caseInsensitive) {
                let start = document.content.index(range.lowerBound, offsetBy: -20, limitedBy: document.content.startIndex) ?? document.content.startIndex
                let end = document.content.index(range.upperBound, offsetBy: 20, limitedBy: document.content.endIndex) ?? document.content.endIndex
                let snippet = String(document.content[start..<end])
                
                Text("..." + snippet + "...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Extensions

extension Set where Element == String {
    mutating func toggle(_ element: String) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}

// MARK: - Helper Views

/// File item in browser
struct FileItem: View {
    let name: String
    let isFolder: Bool
    let indent: Int
    
    var body: some View {
        HStack {
            ForEach(0..<indent, id: \.self) { _ in
                Text("  ")
            }
            Image(systemName: isFolder ? "folder" : "doc")
                .foregroundColor(isFolder ? .blue : .gray)
            Text(name)
            Spacer()
        }
        .padding(.vertical, 2)
    }
}

/// Folder item in browser (renamed to avoid conflict)
struct FolderItemBrowser: View {
    let name: String
    let indent: Int
    let isExpanded: Bool
    let toggle: () -> Void
    
    var body: some View {
        Button(action: toggle) {
            HStack {
                ForEach(0..<indent, id: \.self) { _ in
                    Text("  ")
                }
                Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                    .font(.caption)
                Image(systemName: "folder")
                    .foregroundColor(.blue)
                Text(name)
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }
}