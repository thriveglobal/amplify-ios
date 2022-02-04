//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Foundation

// MARK: - Model

/// All persistent models should conform to the Model protocol.
public protocol Model: Codable {

    /// Alias of Model identifier (i.e. primary key)
    typealias Identifier = String

    /// A reference to the `ModelSchema` associated with this model.
    static var schema: ModelSchema { get }

    /// The name of the model, as registered in `ModelRegistry`.
    static var modelName: String { get }

    /// Convenience property to return the Type's `modelName`. Developers are strongly encouraged not to override the
    /// instance property, as an implementation that returns a different value for the instance property will cause
    /// undefined behavior.
    var modelName: String { get }

    var identifier: ModelIdentifier { get }
}

extension Model {
    public var identifier: ModelIdentifier {
        self.schema.primaryKey.map {
            let value = self[$0.name] as? Persistable ?? ""
            return (name: $0.name, value: value)
        }
    }
}
