//
//  CouchbaseDocument.swift
//  CouchBaseWrapper
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
 
public struct CouchbaseDocument {
    
    public var id: String
    public var attributes: [String: Any]?
    
    internal var mutableDocument: MutableDocument {
        let document = MutableDocument(id: id)
        document.setValue(id, forKey: "id")
        document.setValue(attributes, forKey: "attributes")
        return document
    }
    
    /// Use this method to initialize a couchbase document
    /// - Parameters:
    ///   - id: The id of the document.
    ///   - attributes: The attributes of the document
    public init(id: String, attributes: [String: Any]? = nil) {
        self.id = id
        self.attributes = attributes
    }
    
    internal init(dictionary: [String: Any]) {
        self.id = (dictionary["id"] as? String) ?? ""
        self.attributes = dictionary["attributes"] as? [String: Any]
    }
    
}
