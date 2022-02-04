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
    associatedtype Identifier: ModelIdentifierSerializable
}

public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Default {
    typealias Identifier = ModelIdentifierDefault
}

public extension ModelIdentifiable where IdentifierFormat == ModelIdentifierFormat.Custom {
    typealias Identifier = ModelIdentifierCustom
}

public protocol ModelIdentifierSerializable {
    var fields: [ModelFieldName: Persistable] { get }
}

public struct ModelIdentifierDefault: ModelIdentifierSerializable {
    static let fieldName = "id"

    public var fields: [ModelFieldName: Persistable]

    public init(id: String) {
        self.fields = [Self.fieldName: id]
    }
}

public struct ModelIdentifierCustom: ModelIdentifierSerializable {
    public var fields: [ModelFieldName: Persistable]

    public init(fields: [ModelFieldName: Persistable]) {
        self.fields = fields
    }
}

public typealias ModelIdentifier = [(name: ModelFieldName, value: Persistable)]
extension ModelIdentifier {
    public var stringValue: String {
        map { "\($0.value)" }.joined(separator: "#")
    }
    
    public var values: [Persistable] {
        self.map { $0.value }
    }
    
    public var predicate: QueryPredicate {
        // TODO CPK: error handling if identifier is an empty array?
        let firstField = self[0]
        return self.reduce(field(firstField.name).eq(firstField.value)) { (acc, f) in
            field(f.name).eq(f.value) && acc
        }
    }
}

