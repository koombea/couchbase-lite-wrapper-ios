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

public struct CouchbaseDatabase {
    
    private var configuration: CouchbaseDatabaseConfiguration
    private(set) var database: Database?
    
    public init(databaseName: String) {
        configuration = CouchbaseDatabaseConfiguration(databaseName: databaseName)
        setup()
    }
    
    public init(configuration: CouchbaseDatabaseConfiguration) {
        self.configuration = configuration
        setup()
    }
    
    private mutating func setup() {
        var databaseConfiguration = DatabaseConfiguration()
        if let appGroupIdentifier = configuration.appGroupIdentifier,
           let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) {
            let dbURL = sharedContainerURL.appendingPathComponent(configuration.databaseName)
            if !FileManager.default.fileExists(atPath: dbURL.path) {
                try? FileManager.default.createDirectory(
                    atPath: dbURL.path,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            }
            databaseConfiguration.directory = sharedContainerURL.relativePath
        }
        database = try? Database(name: configuration.databaseName, config: databaseConfiguration)
    }
}
