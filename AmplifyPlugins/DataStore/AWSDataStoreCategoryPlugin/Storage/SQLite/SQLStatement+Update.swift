//
// Copyright Amazon.com Inc. or its affiliates.
// All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import Amplify
import Foundation
import SQLite

/// Represents a `update` SQL statement.
struct UpdateStatement: SQLStatement {

    let modelSchema: ModelSchema
    let conditionStatement: ConditionStatement?

    private let model: Model

    init(model: Model, modelSchema: ModelSchema, condition: QueryPredicate? = nil) {
        self.model = model
        self.modelSchema = modelSchema

        var conditionStatement: ConditionStatement?
        if let condition = condition {
            let statement = ConditionStatement(modelSchema: modelSchema,
                                               predicate: condition)
            conditionStatement = statement
        }

        self.conditionStatement = conditionStatement
    }

    var stringValue: String {
        let columns = updateColumns.map { $0.columnName() }

        let columnsStatement = columns.map { column in
            "  \(column) = ?"
        }

        let searchCondition = modelSchema.primaryKey
            .map { "\($0.columnName()) = ?" }
            .joined(separator: " AND ")

        var sql = """
        update \(modelSchema.name)
        set
        \(columnsStatement.joined(separator: ",\n"))
        where \(searchCondition)
        """

        if let conditionStatement = conditionStatement {
            sql = """
            \(sql)
            \(conditionStatement.stringValue)
            """
        }

        return sql
    }

    var variables: [Binding?] {
        var bindings = model.sqlValues(for: updateColumns, modelSchema: modelSchema)
        // TODO CPK: can we use an extension for Array and Binding here?
        bindings.append(contentsOf: model.identifier(schema: modelSchema).values.map { $0.asBinding() })
        if let conditionStatement = conditionStatement {
            bindings.append(contentsOf: conditionStatement.variables)
        }
        return bindings
    }

    private var updateColumns: [ModelField] {
        modelSchema.columns.filter { !$0.isPrimaryKey }
    }
}
