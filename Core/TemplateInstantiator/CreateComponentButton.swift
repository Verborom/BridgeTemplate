import SwiftUI

/// # CreateComponentButton
///
/// A reusable button that triggers the component creation flow.
/// This button can be placed anywhere in the UI to enable "New Epic",
/// "New Feature", etc. functionality.
///
/// ## Overview
///
/// CreateComponentButton provides a consistent interface for component creation
/// throughout the Bridge Template application. It handles:
/// - Sheet presentation for the creation UI
/// - Type-specific button labels and icons
/// - Creation callbacks and error handling
/// - Visual feedback during creation
///
/// ## Topics
///
/// ### Button Styles
/// - ``style``
/// - ``ButtonStyle``
///
/// ### Customization
/// - ``label``
/// - ``icon``
/// - ``color``
///
/// ## Version History
/// - v1.0.0: Initial implementation
///
/// ## Usage
/// ```swift
/// CreateComponentButton(
///     type: .feature,
///     parentPath: "Modules/Dashboard/Features"
/// ) { result in
///     print("Created: \(result.name)")
/// }
/// ```
public struct CreateComponentButton: View {
    
    // MARK: - Properties
    
    /// Component type to create
    public let type: HierarchyType
    
    /// Parent path for the new component
    public let parentPath: String
    
    /// Button style
    public let style: ButtonStyle
    
    /// Custom label (uses default if nil)
    public let label: String?
    
    /// Custom icon (uses type default if nil)
    public let icon: String?
    
    /// Custom color (uses accent color if nil)
    public let color: Color?
    
    /// Callback when component is created
    public let onCreated: ((CreationResult) -> Void)?
    
    /// Sheet presentation state
    @State private var showCreationSheet = false
    
    // MARK: - Initialization
    
    public init(
        type: HierarchyType,
        parentPath: String,
        style: ButtonStyle = .prominent,
        label: String? = nil,
        icon: String? = nil,
        color: Color? = nil,
        onCreated: ((CreationResult) -> Void)? = nil
    ) {
        self.type = type
        self.parentPath = parentPath
        self.style = style
        self.label = label
        self.icon = icon
        self.color = color
        self.onCreated = onCreated
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: {
            showCreationSheet = true
        }) {
            buttonContent
        }
        .buttonStyle(style.swiftUIStyle)
        .sheet(isPresented: $showCreationSheet) {
            ComponentCreationView(
                parentPath: parentPath,
                onCreated: { result in
                    showCreationSheet = false
                    onCreated?(result)
                },
                onDismiss: {
                    showCreationSheet = false
                }
            )
        }
    }
    
    // MARK: - Subviews
    
    /// Button content based on style
    @ViewBuilder
    private var buttonContent: some View {
        switch style {
        case .prominent:
            HStack(spacing: 8) {
                Image(systemName: icon ?? "plus.circle.fill")
                    .font(.system(size: 16))
                Text(label ?? "New \(type.displayName)")
                    .fontWeight(.medium)
            }
            .foregroundColor(color ?? .accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
        case .compact:
            HStack(spacing: 6) {
                Image(systemName: icon ?? "plus.circle")
                    .font(.system(size: 14))
                Text(label ?? "New \(type.displayName)")
                    .font(.footnote)
            }
            .foregroundColor(color ?? .accentColor)
            
        case .iconOnly:
            Image(systemName: icon ?? "plus.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(color ?? .accentColor)
                
        case .toolbar:
            Label(
                label ?? "New \(type.displayName)",
                systemImage: icon ?? "plus.circle"
            )
            .foregroundColor(color ?? .accentColor)
        }
    }
    
    // MARK: - Button Styles
    
    public enum ButtonStyle {
        case prominent
        case compact
        case iconOnly
        case toolbar
        
        var swiftUIStyle: some PrimitiveButtonStyle {
            switch self {
            case .prominent:
                return .borderedProminent
            case .compact, .toolbar:
                return .bordered
            case .iconOnly:
                return .borderless
            }
        }
    }
}

// MARK: - Convenience Initializers

extension CreateComponentButton {
    
    /// Create a "New Epic" button
    public static func epic(
        parentPath: String,
        style: ButtonStyle = .prominent,
        onCreated: ((CreationResult) -> Void)? = nil
    ) -> CreateComponentButton {
        CreateComponentButton(
            type: .epic,
            parentPath: parentPath,
            style: style,
            icon: "star.circle.fill",
            onCreated: onCreated
        )
    }
    
    /// Create a "New Feature" button
    public static func feature(
        parentPath: String,
        style: ButtonStyle = .prominent,
        onCreated: ((CreationResult) -> Void)? = nil
    ) -> CreateComponentButton {
        CreateComponentButton(
            type: .feature,
            parentPath: parentPath,
            style: style,
            icon: "star.fill",
            onCreated: onCreated
        )
    }
    
    /// Create a "New Task" button
    public static func task(
        parentPath: String,
        style: ButtonStyle = .prominent,
        onCreated: ((CreationResult) -> Void)? = nil
    ) -> CreateComponentButton {
        CreateComponentButton(
            type: .task,
            parentPath: parentPath,
            style: style,
            icon: "checkmark.circle.fill",
            onCreated: onCreated
        )
    }
    
    /// Create a "New Module" button
    public static func module(
        parentPath: String,
        style: ButtonStyle = .prominent,
        onCreated: ((CreationResult) -> Void)? = nil
    ) -> CreateComponentButton {
        CreateComponentButton(
            type: .module,
            parentPath: parentPath,
            style: style,
            icon: "square.grid.2x2.fill",
            onCreated: onCreated
        )
    }
}

// MARK: - Menu Builder

/// A menu that shows multiple component creation options
public struct CreateComponentMenu: View {
    
    /// Parent path for new components
    public let parentPath: String
    
    /// Available component types
    public let types: [HierarchyType]
    
    /// Menu label
    public let label: String
    
    /// Menu icon
    public let icon: String
    
    /// Callback when component is created
    public let onCreated: ((CreationResult) -> Void)?
    
    /// Sheet presentation state
    @State private var showCreationSheet = false
    @State private var selectedType: HierarchyType?
    
    public init(
        parentPath: String,
        types: [HierarchyType] = [.epic, .feature, .task],
        label: String = "Create",
        icon: String = "plus.circle",
        onCreated: ((CreationResult) -> Void)? = nil
    ) {
        self.parentPath = parentPath
        self.types = types
        self.label = label
        self.icon = icon
        self.onCreated = onCreated
    }
    
    public var body: some View {
        Menu {
            ForEach(types, id: \.self) { type in
                Button(action: {
                    selectedType = type
                    showCreationSheet = true
                }) {
                    Label(
                        "New \(type.displayName)",
                        systemImage: type.icon
                    )
                }
            }
        } label: {
            Label(label, systemImage: icon)
        }
        .sheet(isPresented: $showCreationSheet) {
            if let type = selectedType {
                ComponentCreationView(
                    parentPath: parentPath,
                    onCreated: { result in
                        showCreationSheet = false
                        onCreated?(result)
                    },
                    onDismiss: {
                        showCreationSheet = false
                    }
                )
            }
        }
    }
}

// MARK: - Integration Helper

/// Helper to integrate creation buttons into existing views
public struct ComponentCreationToolbar: ViewModifier {
    
    public let parentPath: String
    public let types: [HierarchyType]
    public let placement: ToolbarItemPlacement
    public let onCreated: ((CreationResult) -> Void)?
    
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: placement) {
                    CreateComponentMenu(
                        parentPath: parentPath,
                        types: types,
                        onCreated: onCreated
                    )
                }
            }
    }
}

extension View {
    
    /// Add component creation toolbar
    public func componentCreationToolbar(
        parentPath: String,
        types: [HierarchyType] = [.epic, .feature, .task],
        placement: ToolbarItemPlacement = .primaryAction,
        onCreated: ((CreationResult) -> Void)? = nil
    ) -> some View {
        modifier(ComponentCreationToolbar(
            parentPath: parentPath,
            types: types,
            placement: placement,
            onCreated: onCreated
        ))
    }
}

// MARK: - Preview

#if DEBUG
struct CreateComponentButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Text("Button Styles")
                .font(.headline)
            
            CreateComponentButton(
                type: .feature,
                parentPath: "Modules/Dashboard/Features",
                style: .prominent
            )
            
            CreateComponentButton(
                type: .task,
                parentPath: "Modules/Dashboard/Tasks",
                style: .compact
            )
            
            CreateComponentButton(
                type: .epic,
                parentPath: "Modules/Dashboard/Epics",
                style: .iconOnly
            )
            
            Divider()
            
            Text("Convenience Buttons")
                .font(.headline)
            
            CreateComponentButton.epic(
                parentPath: "Modules/Dashboard/Epics"
            )
            
            CreateComponentButton.feature(
                parentPath: "Modules/Dashboard/Features"
            )
            
            CreateComponentButton.task(
                parentPath: "Modules/Dashboard/Tasks"
            )
            
            Divider()
            
            Text("Menu")
                .font(.headline)
            
            CreateComponentMenu(
                parentPath: "Modules/Dashboard",
                types: [.epic, .feature, .task, .widget]
            )
        }
        .padding()
    }
}
#endif