//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

/// TODO: for backward compatibility, returns an empty string as default for models
/// with a different primary key
extension Model {
    public var id: Identifier { "" }
}

/// AnyModelIdentifierFormat
public protocol AnyModelIdentifierFormat {}

/// Defines the identifier (primary key) format
public enum ModelIdentifierFormat {
    public enum Default: AnyModelIdentifierFormat {} // id
    public enum Custom: AnyModelIdentifierFormat {} // Custom or Composite
}

/// Define requirements for a model to be identifiable with a unique identifier
/// that can be either a single field or a combination of fields
public protocol ModelIdentifiable {
    associatedtype IdentifierFormat: AnyModelIdentifierFormat
    associatedtype Identifier: ModelIdentifier
}
public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Default {
    typealias Identifier = ModelDefaultId
}

public protocol ModelIdentifier {
    func serialized() -> ModelIdentifierSerialized
}
public extension ModelIdentifier {
    func serialized() -> ModelIdentifierSerialized {
        // TODO default implementation
        .custom([:])
    }
}

public enum ModelIdentifierSerialized {
    case id
    case custom([String: Persistable])
}

public struct ModelDefaultId: ModelIdentifier {
    var id: String
    static func identifier(id: String) -> ModelDefaultId {
        ModelDefaultId(id: id)
    }
}
