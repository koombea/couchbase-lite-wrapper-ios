# Couchbase Lite Wrapper for iOS and MacOS

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 
[![Swift Package Manager](https://rawgit.com/jlyonsmith/artwork/master/SwiftPackageManager/swiftpackagemanager-compatible.svg)](https://swift.org/package-manager/)

**Couchbase Lite Wrapper** is a library written in Swift that makes it easy for you to implement database CRUD operations with [Couchbase Lite for iOS and MacOS](https://github.com/couchbase/couchbase-lite-ios)

## Requirements
- iOS 13.0+ | MacOS 10.13+

## Installation

### Swift Package Manager

The Swift Package Manager is a tool for managing the distribution of Swift code. It’s integrated with the Swift build system to automate the process of downloading, compiling, and linking dependencies.

The Package Manager is included in Swift 3.0 and above.

```swift
dependencies: [
        .package(name: "CouchbaseLiteWrapper",
                 url: "https://github.com/koombea/couchbase-lite-wrapper-ios.git", 
                 from: "1.0.0"),
    ],
```

## The Basics

### Setup

Create a couchbase database for each of the models you want to store

```swift
couchbaseDatabase = CouchbaseDatabase(databaseName: "User")

```

### Create / Update document

```swift
let document = CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"])
couchbaseDatabase.save(document)

```

### Fetch documents

```swift
let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
let documents = couchbaseDatabase.fetchAll(whereExpression: expression)

```

### Delete Documents

```swift
let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
couchbaseDatabase.deleteAll(whereExpression: expression)

```

## Couchbase Lite Wrapper + Codable
[Codable](https://developer.apple.com/documentation/swift/codable) is a type alias for the `Encodable` and `Decodable` protocols part of the Swift Standard Library framework that makes your data types encodable and decodable for compatibility with external representations such as JSON.

Having a `User: Codable` model, you can fetch models like this:

```swift
let users = couchbaseDatabase.fetchAll(User.self)

```
