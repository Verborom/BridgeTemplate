import Foundation

/// # Request Formatter
///
/// Standardizes development requests into consistent format for processing.
///
/// ## Overview
///
/// The Request Formatter ensures all development requests follow a consistent
/// pattern, making them easier to parse and process. It validates requests for
/// completeness and converts natural language into structured format.
///
/// ## Topics
///
/// ### Formatting
/// - ``standardize(_:)``
/// - ``normalize(_:)``
/// - ``extractComponents(from:)``
///
/// ### Validation
/// - ``validate(_:)``
/// - ``ValidationResult``
/// - ``ValidationError``
///
/// ## Usage
///
/// ```swift
/// let formatter = RequestFormatter()
/// let standardized = formatter.standardize("Fix the Add Module button")
/// // Result: "TARGET: ui.sidebar.addModule SCOPE: component ACTION: fix"
/// ```
public class RequestFormatter {
    
    /// Standardize format template
    private let formatTemplate = "TARGET: %@ SCOPE: %@ ACTION: %@ OPTIONS: %@"
    
    /// Intent parser for extracting components
    private let intentParser = IntentParser()
    
    /// Initialize formatter
    public init() {}
    
    /// Convert natural language to standardized format
    ///
    /// - Parameter naturalRequest: Natural language request
    /// - Returns: Standardized format string
    ///
    /// ## Examples
    ///
    /// ```swift
    /// formatter.standardize("Fix the Add Module button")
    /// // "TARGET: ui.sidebar.addModule SCOPE: component ACTION: fix OPTIONS: none"
    ///
    /// formatter.standardize("Add Feature21 to Dashboard")
    /// // "TARGET: dashboard.features.feature21 SCOPE: submodule ACTION: add OPTIONS: none"
    ///
    /// formatter.standardize("Create sidebar tile for system status")
    /// // "TARGET: ui.sidebar.systemStatus SCOPE: component ACTION: add OPTIONS: create_new"
    /// ```
    public func standardize(_ naturalRequest: String) -> String {
        let normalized = normalize(naturalRequest)
        let instructions = intentParser.parseRequest(normalized)
        
        let options = extractOptions(from: naturalRequest, instructions: instructions)
        
        return String(format: formatTemplate,
                      instructions.target,
                      instructions.scope.rawValue,
                      instructions.action.rawValue,
                      options.joined(separator: ","))
    }
    
    /// Validate request has sufficient specificity
    ///
    /// - Parameter request: Request to validate
    /// - Returns: Validation result with any errors
    ///
    /// ## Validation Rules
    ///
    /// 1. Request must specify a clear target
    /// 2. Action must be identifiable
    /// 3. Scope must be determinable
    /// 4. No conflicting instructions
    public func validate(_ request: String) -> ValidationResult {
        var errors: [ValidationError] = []
        
        let normalized = normalize(request)
        let instructions = intentParser.parseRequest(normalized)
        
        // Check target specificity
        if instructions.target == "ui.general.component" {
            errors.append(.insufficientTarget(
                suggestion: "Please specify which component (e.g., 'Add Module button', 'Dashboard stats widget')"
            ))
        }
        
        // Check for new component without clear location
        if instructions.target == "ui.new.component" && !request.contains("sidebar") && !request.contains("dashboard") {
            errors.append(.unclearLocation(
                suggestion: "Please specify where to add the new component (e.g., 'in sidebar', 'to dashboard')"
            ))
        }
        
        // Check scope clarity
        if instructions.scope == .full && !request.contains("rebuild") && !request.contains("full") {
            errors.append(.scopeAmbiguity(
                suggestion: "This seems like a large change. Did you mean to rebuild everything?"
            ))
        }
        
        // Check for conflicting instructions
        if containsConflictingActions(request) {
            errors.append(.conflictingActions(
                suggestion: "Please specify a single action (fix, add, enhance, etc.)"
            ))
        }
        
        // Return result
        if errors.isEmpty {
            return ValidationResult(
                isValid: true,
                errors: [],
                standardized: standardize(request),
                confidence: calculateConfidence(instructions)
            )
        } else {
            return ValidationResult(
                isValid: false,
                errors: errors,
                standardized: nil,
                confidence: 0.0
            )
        }
    }
    
    /// Normalize request text
    private func normalize(_ request: String) -> String {
        var normalized = request.lowercased()
        
        // Expand common abbreviations
        normalized = normalized
            .replacingOccurrences(of: "btn", with: "button")
            .replacingOccurrences(of: "nav", with: "navigation")
            .replacingOccurrences(of: "stats", with: "statistics")
        
        // Remove noise words
        let noiseWords = ["the", "a", "an", "please", "can you", "could you", "i want to", "let's"]
        for word in noiseWords {
            normalized = normalized.replacingOccurrences(of: word + " ", with: "")
        }
        
        return normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Extract additional options from request
    private func extractOptions(from request: String, instructions: BuildInstructions) -> [String] {
        var options: [String] = []
        
        // Check for hot-swap preference
        if request.contains("hot swap") || request.contains("hot-swap") || request.contains("without restart") {
            options.append("hot_swap")
        }
        
        // Check for test requirements
        if request.contains("with tests") || request.contains("test") {
            options.append("run_tests")
        }
        
        // Check for documentation updates
        if request.contains("document") || request.contains("docs") {
            options.append("update_docs")
        }
        
        // Check for new component creation
        if instructions.action == .add && (request.contains("new") || request.contains("create")) {
            options.append("create_new")
        }
        
        // Check for urgent/priority
        if request.contains("urgent") || request.contains("asap") || request.contains("quickly") {
            options.append("priority")
        }
        
        return options.isEmpty ? ["none"] : options
    }
    
    /// Check for conflicting actions
    private func containsConflictingActions(_ request: String) -> Bool {
        let actions = ["fix", "add", "enhance", "remove", "update"]
        var foundCount = 0
        
        for action in actions {
            if request.contains(action) {
                foundCount += 1
            }
        }
        
        return foundCount > 1
    }
    
    /// Calculate confidence score for instructions
    private func calculateConfidence(_ instructions: BuildInstructions) -> Double {
        var score = 1.0
        
        // Reduce confidence for generic targets
        if instructions.target.contains("general") || instructions.target.contains("new") {
            score -= 0.3
        }
        
        // Reduce confidence for large scopes
        if instructions.scope == .system || instructions.scope == .full {
            score -= 0.2
        }
        
        // Increase confidence for well-known components
        if instructions.files.count > 0 {
            score += 0.1
        }
        
        return max(0.0, min(1.0, score))
    }
}

/// # Validation Result
///
/// Result of request validation.
public struct ValidationResult {
    /// Whether the request is valid
    public let isValid: Bool
    
    /// Validation errors if any
    public let errors: [ValidationError]
    
    /// Standardized format if valid
    public let standardized: String?
    
    /// Confidence score (0.0 - 1.0)
    public let confidence: Double
    
    /// Human-readable summary
    public var summary: String {
        if isValid {
            return "Request is valid with \(Int(confidence * 100))% confidence"
        } else {
            return "Request validation failed: \(errors.map { $0.message }.joined(separator: "; "))"
        }
    }
}

/// # Validation Error
///
/// Specific validation error types.
public enum ValidationError {
    /// Target is not specific enough
    case insufficientTarget(suggestion: String)
    
    /// Location for new component is unclear
    case unclearLocation(suggestion: String)
    
    /// Scope seems too large for request
    case scopeAmbiguity(suggestion: String)
    
    /// Multiple conflicting actions detected
    case conflictingActions(suggestion: String)
    
    /// Missing required information
    case missingInformation(field: String, suggestion: String)
    
    /// Human-readable error message
    public var message: String {
        switch self {
        case .insufficientTarget(let suggestion):
            return "Target not specific enough. \(suggestion)"
        case .unclearLocation(let suggestion):
            return "Location unclear. \(suggestion)"
        case .scopeAmbiguity(let suggestion):
            return "Scope ambiguous. \(suggestion)"
        case .conflictingActions(let suggestion):
            return "Conflicting actions. \(suggestion)"
        case .missingInformation(let field, let suggestion):
            return "Missing \(field). \(suggestion)"
        }
    }
}

/// # Request Components
///
/// Extracted components from a request.
public struct RequestComponents {
    public let action: String
    public let target: String
    public let location: String?
    public let modifiers: [String]
}

/// # Format Options
///
/// Additional options that can be specified in requests.
public struct FormatOptions {
    public static let hotSwap = "hot_swap"
    public static let runTests = "run_tests"
    public static let updateDocs = "update_docs"
    public static let createNew = "create_new"
    public static let priority = "priority"
}