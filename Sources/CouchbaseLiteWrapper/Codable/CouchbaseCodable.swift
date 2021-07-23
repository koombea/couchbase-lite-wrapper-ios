//
//  CouchbaseCodable.swift
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

public extension CouchbaseDatabase {
    
    //MARK: - Fetch
    
    /// Use this method to fetch stored documents.
    /// - Parameters:
    ///   - type: The 'Codable' generic.
    ///   - expressionProtocol: The 'where' expression to filter specific documents.
    ///   - orderedBy: Sort criteria for the query.
    /// - Returns: An Array of 'Codable' objects.
    func fetchAll<T: Codable>(_ type: T.Type, whereExpression expressionProtocol: ExpressionProtocol? = nil,
                                orderedBy: [OrderingProtocol]? = nil) -> [T] {
        let documents = fetchAll(whereExpression: expressionProtocol, orderedBy: orderedBy)
        let JSONArray = documents.compactMap { $0.attributes }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: JSONArray, options: .prettyPrinted)
            let decoder = JSONDecoder()
            return try decoder.decode([T].self, from: jsonData)
        } catch {
            return []
        }
    }
    
    /// Use this method to fetch a single document.
    /// - Parameters:
    ///   - type: The 'Codable' type.
    ///   - documentID: The id of the document to fetch..
    /// - Returns: A 'Mappable' object.
    func fetch<T: Codable>(_ type: T.Type, documentID: String) -> T? {
        guard let JSONObject = fetch(withDocumentID: documentID)?.attributes else { return nil }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: jsonData)
        } catch {
            return nil
        }
    }
}
