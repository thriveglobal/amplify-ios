//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

extension Model {
    /// TODO: for backward compatibility, returns an empty string as default for models
    /// with a different primary key
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
    typealias Identifier = ModelIdentifierDefault
}

public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Custom {
    typealias Identifier = ModelIdentifierCustom
}

public protocol ModelIdentifier {
    var fields: [ModelFieldName: Persistable] { get }
}


public struct ModelIdentifierDefault: ModelIdentifier {
    static let fieldName = "id"

    public var fields: [ModelFieldName : Persistable]

    public init(fields: [ModelFieldName : Persistable]) {
        self.fields = fields
    }

    static func identifier(id: String) -> ModelIdentifierDefault {
        ModelIdentifierDefault(fields: [fieldName: id])
    }
}

public struct ModelIdentifierCustom {
    public var fields: [ModelFieldName : Persistable]

    public init(fields: [ModelFieldName : Persistable]) {
        self.fields = fields
    }
}
