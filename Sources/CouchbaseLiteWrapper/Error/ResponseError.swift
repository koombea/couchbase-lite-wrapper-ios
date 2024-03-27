//
//  ResponseError.swift
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

public enum ResponseError: Error, LocalizedError {
    
    case `default`
    case invalidCollection
    case invalidDataBase
    case custom(message: String)
    
    public var errorDescription: String? { localizedDescription }
    
    var localizedDescription: String {
        switch self {
        case .custom(let message):
            return message
        case .invalidCollection:
            return "Invalid collection"
        case .invalidDataBase:
            return "Invalid database"
        default:
            return "Something went wrong, please try again later."
        }
    }
    
    static func == (_ lhs: ResponseError, rhs: ResponseError) -> Bool {
        lhs.errorDescription == rhs.errorDescription
    }
    
    static func != (_ lhs: ResponseError, rhs: ResponseError) -> Bool {
        lhs.errorDescription != rhs.errorDescription
    }
}
