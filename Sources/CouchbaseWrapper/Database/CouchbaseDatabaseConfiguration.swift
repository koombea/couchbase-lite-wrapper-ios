//
//  CouchbaseDatabaseConfiguration.swift
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

public struct CouchbaseDatabaseConfiguration {
    
    public var databaseName: String
    public var appGroupIdentifier: String?
    
    /// Use this method to initialize a database configuration
    /// - Parameters:
    ///   - name: The name of the database.
    ///   - appGroupContainerURL: The app group identifier.
    public init(databaseName: String, appGroupIdentifier: String? = nil) {
        self.databaseName = databaseName.lowercased()
        self.appGroupIdentifier = appGroupIdentifier
    }
}
