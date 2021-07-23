//
//  CouchbaseObjectMapper.swift
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
import ObjectMapper

public extension Mappable {
        
    /// Use this get a document from a Mapple object.
    /// - Parameters:
    ///   - id: The id of the document.
    /// - Returns: A couchbase document
    func toDocument(withID id: String) -> CouchbaseDocument? {
        return CouchbaseDocument(id: id, attributes: toJSON())
    }
}

public extension CouchbaseDatabase {
    
    /// Use this method to fetch stored documents.
    /// - Parameters:
    ///   - type: The 'Mappable' generic.
    ///   - expressionProtocol: The 'where' expression to filter specific documents.
    ///   - orderedBy: Sort criteria for the query.
    /// - Returns: An Array of 'Mappable' objects.
    func fetchAll<T: Mappable>(_ type: T.Type, whereExpression expressionProtocol: ExpressionProtocol? = nil,
                                orderedBy: [OrderingProtocol]? = nil) -> [T] {
        let documents = fetchAll(whereExpression: expressionProtocol, orderedBy: orderedBy)
        let JSONArray = documents.compactMap { $0.attributes }
        return Mapper<T>().mapArray(JSONArray: JSONArray)
    }
    
    /// Use this method to fetch a single document.
    /// - Parameters:
    ///   - type: The 'Mappable' type.
    ///   - documentID: The id of the document to fetch.
    /// - Returns: A 'Mappable' object.
    func fetch<T: Mappable>(_ type: T.Type, documentID: String) -> T? {
        guard let JSONObject = fetch(withDocumentID: documentID)?.attributes else { return nil }
        return Mapper<T>().map(JSONObject: JSONObject)
    }
}


