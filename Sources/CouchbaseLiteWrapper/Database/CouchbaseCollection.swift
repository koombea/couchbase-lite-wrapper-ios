//
//  CouchbaseCollection.swift
//  CouchBaseLiteWrapper
//
// Copyright (c) 2021 Koombea, Inc All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import CouchbaseLiteSwift

public struct CouchbaseCollection {
    
    private var database: Database?
    private var collection: Collection?
    
    public init(collection: String, database: CouchbaseDatabase) {
        self.database = database.database
        self.collection = try? self.database?.createCollection(name: collection)
    }
    
    // MARK: - Index
    
    /// Use this method to a couchbase index
    /// - Parameters:
    ///   - index: The specific index to be created.
    ///   - name: The index name.
    public func createIndex(_ index: CouchbaseLiteSwift.Index, withName name: String) throws {
        guard let collection else { throw ResponseError.invalidCollection }
        try collection.createIndex(index, name: name)
    }
    
    //MARK: - Save/Create
    
    /// Use this method to save a single document.
    /// - Parameters:
    ///   - document: The specific document to be saved.
    public func save(_ document: CouchbaseDocument) throws {
        guard let collection else { throw ResponseError.invalidCollection }
        try collection.save(document: document.mutableDocument)
    }
    
    /// Use this method to save a single document.
    /// - Parameters:
    ///   - document: The specific document to be saved.
    public func save(_ documents: [CouchbaseDocument]) throws {
        guard let database else { throw ResponseError.invalidDataBase }
        try database.inBatch {
            try documents.forEach { try save($0) }
        }
    }
    
    //MARK: - Fetch
    
    /// Use this method to fetch stored documents.
    /// - Parameters:
    ///   - expressionProtocol: The 'where' expression to filter specific documents.
    ///   - orderedBy: Sort criteria for the query.
    /// - Returns: Documents of the current collection.
    public func fetchAll(whereExpression expressionProtocol: ExpressionProtocol? = nil,
                         orderedBy: [OrderingProtocol]? = nil) throws -> [CouchbaseDocument] {
        guard let collection else { throw ResponseError.invalidCollection }
        var query: Query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.collection(collection))
        if let fromQuery = query as? From {
            if let expressionProtocol = expressionProtocol {
                query = fromQuery.where(expressionProtocol)
                if let whereQuery = query as? Where, let orderedBy = orderedBy {
                    query = whereQuery.orderBy(orderedBy)
                }
            } else if let orderedBy = orderedBy {
                query = fromQuery.orderBy(orderedBy)
            }
        }
        return try fetchQuery(query)
    }
    
    /// Use this method to fetch a single document.
    /// - Parameters:
    ///   - documentID: The id of the document to fetch.
    /// - Returns: Document of the current collection.
    public func fetch(withDocumentID documentID: String) throws -> CouchbaseDocument? {
        guard let collection else { throw ResponseError.invalidCollection }
        let document = try collection.document(id: documentID)
        guard let dictionary = document?.toDictionary() else { return nil }
        return CouchbaseDocument(dictionary: dictionary)
    }
    
    //MARK: - Delete
    
    /// Use this method to delete stored documents.
    /// - Parameters:
    ///   - expressionProtocol: The 'where' expression to delete specific documents.
    public func deleteAll(whereExpression expressionProtocol: ExpressionProtocol? = nil) throws {
        guard let collection else { throw ResponseError.invalidCollection }
        guard let database else { throw ResponseError.invalidDataBase }
        var query: Query = QueryBuilder.select(SelectResult.all())
            .from(DataSource.collection(collection))
        if let fromQuery = query as? From {
            if let expressionProtocol = expressionProtocol {
                query = fromQuery.where(expressionProtocol)
            }
        }
        try database.inBatch {
            try fetchQuery(query).forEach { try delete(withDocumentID: $0.id) }
        }
    }
    
    /// Use this method to delete a single document.
    /// - Parameters:
    ///   - documentID: The id of the document to delete.
    public func delete(withDocumentID documentID: String) throws {
        guard let collection else { throw ResponseError.invalidCollection }
        guard let document = try collection.document(id: documentID) else { return }
        try collection.delete(document: document)
    }
    
    //MARK: - Private
    
    private func fetchQuery(_ query: Query) throws -> [CouchbaseDocument] {
        guard let collection else { throw ResponseError.invalidCollection }
        var documents: [CouchbaseDocument] = []
        for resultSet in try query.execute() {
            print(resultSet.keys)
            if let dictionary = resultSet.dictionary(forKey: collection.name)?.toDictionary() {
                documents.append(CouchbaseDocument(dictionary: dictionary))
            }
        }
        return documents
    }
}
