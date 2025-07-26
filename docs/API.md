# API Documentation

## Overview

This document describes the public APIs exposed by the BridgeCore framework and platform-specific implementations.

## BridgeCore API

### Core Protocols

#### BridgeModule
Base protocol for all modules in the system.

```swift
public protocol BridgeModule {
    /// Unique identifier for the module
    var identifier: String { get }
    
    /// Current version of the module
    var version: String { get }
    
    /// Module dependencies
    var dependencies: [String] { get }
    
    /// Initialize the module
    func initialize() throws
    
    /// Cleanup module resources
    func teardown()
    
    /// Module configuration
    func configure(with config: ModuleConfiguration)
}
```

#### DataProvider
Protocol for data access layers.

```swift
public protocol DataProvider {
    associatedtype Model: Codable
    
    /// Fetch all items
    func fetchAll() async throws -> [Model]
    
    /// Fetch item by ID
    func fetch(id: String) async throws -> Model?
    
    /// Save item
    func save(_ item: Model) async throws
    
    /// Delete item
    func delete(id: String) async throws
    
    /// Observe changes
    func observe() -> AsyncStream<DataChange<Model>>
}
```

### Core Services

#### NetworkService
Handles all network operations.

```swift
public class NetworkService {
    /// Shared instance
    public static let shared = NetworkService()
    
    /// Perform GET request
    public func get<T: Decodable>(
        _ endpoint: String,
        parameters: [String: Any]? = nil
    ) async throws -> T
    
    /// Perform POST request
    public func post<T: Decodable>(
        _ endpoint: String,
        body: Encodable? = nil
    ) async throws -> T
    
    /// Upload file
    public func upload(
        _ endpoint: String,
        file: Data,
        filename: String
    ) async throws -> UploadResponse
    
    /// Download file
    public func download(
        _ endpoint: String
    ) async throws -> Data
}
```

#### StorageService
Manages local data persistence.

```swift
public class StorageService {
    /// Storage types
    public enum StorageType {
        case userDefaults
        case keychain
        case coreData
        case fileSystem
    }
    
    /// Save data
    public func save<T: Codable>(
        _ object: T,
        key: String,
        type: StorageType = .userDefaults
    ) throws
    
    /// Load data
    public func load<T: Codable>(
        _ type: T.Type,
        key: String,
        storageType: StorageType = .userDefaults
    ) throws -> T?
    
    /// Delete data
    public func delete(
        key: String,
        type: StorageType = .userDefaults
    ) throws
    
    /// Clear all data
    public func clearAll(type: StorageType) throws
}
```

#### AuthenticationService
Handles user authentication.

```swift
public class AuthenticationService {
    /// Authentication states
    public enum AuthState {
        case unauthenticated
        case authenticated(User)
        case expired
    }
    
    /// Current auth state
    @Published public var authState: AuthState
    
    /// Sign in with credentials
    public func signIn(
        username: String,
        password: String
    ) async throws -> User
    
    /// Sign in with biometrics
    public func signInWithBiometrics() async throws -> User
    
    /// Sign out
    public func signOut() async throws
    
    /// Refresh token
    public func refreshToken() async throws
}
```

### Data Models

#### User
Represents a user in the system.

```swift
public struct User: Codable, Identifiable {
    public let id: String
    public let username: String
    public let email: String
    public let displayName: String
    public let avatarURL: URL?
    public let createdAt: Date
    public let preferences: UserPreferences
}
```

#### Project
Represents a project entity.

```swift
public struct Project: Codable, Identifiable {
    public let id: String
    public var name: String
    public var description: String
    public var status: ProjectStatus
    public var createdAt: Date
    public var updatedAt: Date
    public var tags: [String]
    
    public enum ProjectStatus: String, Codable {
        case draft
        case active
        case completed
        case archived
    }
}
```

### Utilities

#### Logger
Centralized logging system.

```swift
public struct Logger {
    /// Log levels
    public enum Level {
        case debug, info, warning, error, critical
    }
    
    /// Log a message
    public static func log(
        _ message: String,
        level: Level = .info,
        category: String = "General",
        file: String = #file,
        function: String = #function,
        line: Int = #line
    )
}
```

#### Extensions
Common Swift extensions.

```swift
// String extensions
public extension String {
    /// Check if string is valid email
    var isValidEmail: Bool { get }
    
    /// Convert to URL
    var url: URL? { get }
    
    /// Base64 encode
    var base64Encoded: String { get }
}

// Date extensions
public extension Date {
    /// Format date as string
    func formatted(style: DateFormatter.Style) -> String
    
    /// Time ago representation
    var timeAgo: String { get }
}
```

## Platform-Specific APIs

### macOS (BridgeMac)

#### WindowManager
Manages application windows.

```swift
public class WindowManager {
    /// Show main window
    public func showMainWindow()
    
    /// Show preferences window
    public func showPreferences()
    
    /// Create new document window
    public func newDocumentWindow() -> NSWindow
    
    /// Close all windows
    public func closeAllWindows()
}
```

#### MenuBarManager
Handles menu bar integration.

```swift
public class MenuBarManager {
    /// Show/hide menu bar icon
    public func setMenuBarVisible(_ visible: Bool)
    
    /// Update menu bar status
    public func updateStatus(_ text: String)
    
    /// Add menu item
    public func addMenuItem(
        title: String,
        action: @escaping () -> Void
    )
}
```

### iOS (BridgeiOS)

#### NotificationManager
Manages push notifications.

```swift
public class NotificationManager {
    /// Request notification permissions
    public func requestPermissions() async throws
    
    /// Schedule local notification
    public func scheduleNotification(
        title: String,
        body: String,
        date: Date
    ) throws
    
    /// Handle remote notification
    public func handleRemoteNotification(
        _ userInfo: [AnyHashable: Any]
    )
}
```

#### WidgetManager
Manages widget extensions.

```swift
public class WidgetManager {
    /// Update widget content
    public func updateWidget(with data: WidgetData)
    
    /// Reload all widgets
    public func reloadAllWidgets()
    
    /// Get widget configuration
    public func getConfiguration() -> WidgetConfiguration
}
```

## Error Handling

### BridgeError
Common error types.

```swift
public enum BridgeError: LocalizedError {
    case networkError(underlying: Error)
    case authenticationFailed(reason: String)
    case dataCorrupted
    case featureNotAvailable
    case custom(String)
    
    public var errorDescription: String? { get }
}
```

## Migration

### DataMigrator
Handles data migration between versions.

```swift
public protocol DataMigrator {
    /// Source version
    var fromVersion: String { get }
    
    /// Target version
    var toVersion: String { get }
    
    /// Perform migration
    func migrate() async throws
}
```

## Usage Examples

### Basic Network Request
```swift
// Fetch user data
let user: User = try await NetworkService.shared.get("/api/user/me")
```

### Save to Storage
```swift
// Save user preferences
try StorageService.shared.save(
    preferences,
    key: "user_preferences",
    type: .userDefaults
)
```

### Authentication Flow
```swift
// Sign in
do {
    let user = try await AuthenticationService.shared.signIn(
        username: "user@example.com",
        password: "password123"
    )
    print("Signed in as \(user.displayName)")
} catch {
    print("Sign in failed: \(error)")
}
```

---

For more examples and detailed usage, see the sample projects in the repository.