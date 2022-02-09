//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

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
    associatedtype IdentifierNext: AnyModelIdentifier
}

//public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Default {
//    typealias IdentifierNext = ModelIdentifier<ModelIdentifierFormat.Default>
//}
//
//public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Custom {
//    typealias IdentifierNext = ModelIdentifier<ModelIdentifierFormat.Custom>
//}

public protocol AnyModelIdentifier {
    typealias Field = (name: String, value: Persistable)
    typealias Fields = [Field]

    var stringValue: String { get }
    var values: [Persistable] { get }
    var predicate: QueryPredicate { get }
}

public struct ModelIdentifier<Format: AnyModelIdentifierFormat>: AnyModelIdentifier {
    var fields: ModelIdentifier.Fields
    public var stringValue: String {
        fields.map { "\($0.value)" }.joined(separator: "#")
    }

    public var values: [Persistable] {
        fields.map { $0.value }
    }

    public var predicate: QueryPredicate {
        // TODO CPK: error handling if identifier is an empty array?
        let firstField = fields[0]
        return fields.reduce(field(firstField.name).eq(firstField.value)) { acc, modelField in
            field(modelField.name).eq(modelField.value) && acc
        }
    }
}

public extension ModelIdentifier where Format == ModelIdentifierFormat.Default {
    static let defaultIdentifier = "id"
    static func makeDefault(id: String) -> Self {
        Self(fields: [(name: Self.defaultIdentifier, value: id)])
    }
}
public extension ModelIdentifier where Format == ModelIdentifierFormat.Custom {
    static let defaultIdentifier = "id"
    static func make(fields: AnyModelIdentifier.Field...) -> Self {
        Self(fields: fields)
    }
}

