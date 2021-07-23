//
//  CouchbaseDatabase.swift
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

public class CouchbaseDatabase {
    
    private var configuration: CouchbaseDatabaseConfiguration
    internal var database: Database?
    
    public init(databaseName: String) {
        configuration = CouchbaseDatabaseConfiguration(databaseName: databaseName)
        setup()
    }
    
    public init(configuration: CouchbaseDatabaseConfiguration) {
        self.configuration = configuration
        setup()
    }
    
    private func setup() {
        let databaseConfiguration = DatabaseConfiguration()
        if let appGroupIdentifier = configuration.appGroupIdentifier,
           let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let dbURL = sharedContainerURL.appendingPathComponent(configuration.databaseName)
            if !FileManager.default.fileExists(atPath: dbURL.path) {
                try? FileManager.default.createDirectory(atPath: dbURL.path, withIntermediateDirectories: false, attributes: nil)
            }
            databaseConfiguration.directory = sharedContainerURL.relativePath
        }
        database = try? Database(name: configuration.databaseName, config: databaseConfiguration)
    }
    
    //MARK: - Save/Create
    
    /// Use this method to save a single document.
    /// - Parameters:
    ///   - document: The specific document to be saved.
    public func save(_ document: CouchbaseDocument) {
        do {
            try database?.saveDocument(document.mutableDocument)
        } catch let error {
            print(error)
        }
    }
    
    /// Use this method to save a single document.
    /// - Parameters:
    ///   - document: The specific document to be saved.
    public func save(_ documents: [CouchbaseDocument]) {
        try? database?.inBatch {
            documents.forEach { save($0) }
        }
    }
    
    //MARK: - Fetch
    
    /// Use this method to fetch stored documents.
    /// - Parameters:
    ///   - expressionProtocol: The 'where' expression to filter specific documents.
    ///   - orderedBy: Sort criteria for the query.
    /// - Returns: Documents of the current database.
    public func fetchAll(whereExpression expressionProtocol: ExpressionProtocol? = nil,
                         orderedBy: [OrderingProtocol]? = nil) -> [CouchbaseDocument] {
        guard let database = database else { return [] }
        var query: Query = QueryBuilder.select(SelectResult.all())
                            .from(DataSource.database(database))
        if let fromQuery = query as? From {
            if let expressionProtocol = expressionProtocol {
                query = fromQuery.where(expressionProtocol)
                if let whereQuery = query as? Where, let orderedBy = orderedBy { query = whereQuery.orderBy(orderedBy) }
            } else if let orderedBy = orderedBy {
                query = fromQuery.orderBy(orderedBy)
            }
        }
        return fetchQuery(query)
    }
    
    /// Use this method to fetch a single document.
    /// - Parameters:
    ///   - documentID: The id of the document to fetch.
    /// - Returns: Document of the current database.
    public func fetch(withDocumentID documentID: String) -> CouchbaseDocument? {
        let databaseDocument = database?.document(withID: documentID)
        guard let dictionary = databaseDocument?.toDictionary() else { return nil }
        return CouchbaseDocument(dictionary: dictionary)
    }
    
    //MARK: - Delete
    
    /// Use this method to delete stored documents.
    /// - Parameters:
    ///   - expressionProtocol: The 'where' expression to delete specific documents.
    public func deleteAll(whereExpression expressionProtocol: ExpressionProtocol? = nil) {
        guard let database = database else { return }
        var query: Query = QueryBuilder.select(SelectResult.all())
                            .from(DataSource.database(database))
        if let fromQuery = query as? From {
            if let expressionProtocol = expressionProtocol {
                query = fromQuery.where(expressionProtocol)
            }
        }
        try? database.inBatch {
            fetchQuery(query).forEach { delete(withDocumentID: $0.id) }
        }
    }
    
    /// Use this method to delete a single document.
    /// - Parameters:
    ///   - documentID: The id of the document to delete.
    public func delete(withDocumentID documentID: String) {
        guard let databaseDocument = database?.document(withID: documentID) else { return }
        do {
            try database?.deleteDocument(databaseDocument)
        } catch { }
    }
    
    //MARK: - Private
    
    private func fetchQuery(_ query: Query) -> [CouchbaseDocument] {
        var documents: [CouchbaseDocument] = []
        do {
            for resultSet in try query.execute() {
                if let dictionary = resultSet.dictionary(forKey: configuration.databaseName)?.toDictionary() {
                    documents.append(CouchbaseDocument(dictionary: dictionary))
                }
            }
        } catch { }
        return documents
    }
}

