import XCTest
import CouchbaseLiteSwift
import Nimble
@testable import CouchbaseLiteWrapper
    
final class CouchbaseWrapperTests: XCTestCase {
    
    var couchbaseDatabase: CouchbaseDatabase?
    var couchbaseCollection: CouchbaseCollection?
    
    override func setUp() {
        couchbaseDatabase = CouchbaseDatabase(databaseName: "couchbase-db")
        if let database = couchbaseDatabase {
            couchbaseCollection = CouchbaseCollection(collection: "User", database: database)
        }
    }
    
    override func tearDown() {
        try? couchbaseCollection?.deleteAll()
    }
    
    func test_databaseSetup_withDatabaseName() {
        expect(self.couchbaseDatabase).notTo(beNil())
        expect(self.couchbaseDatabase?.database).notTo(beNil())
        expect(self.couchbaseCollection).notTo(beNil())
    }
    
    func test_databaseSetup_withConfiguration() {
        let databaseConfiguration = CouchbaseDatabaseConfiguration(databaseName: "couchbase-db")
        let couchbaseDatabase = CouchbaseDatabase(configuration: databaseConfiguration)
        expect(couchbaseDatabase).notTo(beNil())
        expect(couchbaseDatabase.database).notTo(beNil())
    }
    
    func test_CreateIndex() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        documents.append(CouchbaseDocument(id: "3", attributes: ["name": "Brian", "last_name": "Brandon"]))
        try? couchbaseCollection?.save(documents)
        
        let index = IndexBuilder.fullTextIndex(items: [FullTextIndexItem.property("attributes.name"),
                                                       FullTextIndexItem.property("attributes.last_name")]).ignoreAccents(true)
        
        try? couchbaseCollection?.createIndex(index, withName: "NameLastNameFTSIndex")
        
        let expression = FullTextFunction.match(Expression.fullTextIndex("NameLastNameFTSIndex"), query: "*\("Br")*")
        let orderedBy = Ordering.property("attributes.name").ascending()
        let JSONArray = try? couchbaseCollection?.fetchAll(User.self, whereExpression: expression, orderedBy: [orderedBy])
        
        let count = JSONArray?.count ?? 0
        expect(count).to(equal(2))
        guard count > 2 else { return }
        let firstUser = JSONArray?[0]
        let secondUser = JSONArray?[1]
        expect(firstUser).notTo(beNil())
        expect(secondUser).notTo(beNil())
        
        expect(firstUser?.name).to(equal("Brad"))
        expect(secondUser?.name).to(equal("Brian"))
    }
    
    func test_saveDocument() {
        let document = CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"])
        try? couchbaseCollection?.save(document)
        let documents = try? couchbaseCollection?.fetchAll()
        expect(documents?.first).notTo(beNil())
    }
    
    func test_saveDocuments() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let count = try? couchbaseCollection?.fetchAll().count ?? 0
        expect(count).to(equal(2))
    }
    
    func test_fetchDocument_withExpressions() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        let document = try? couchbaseCollection?.fetchAll(whereExpression: expression).first
        expect(document).notTo(beNil())
        let name = (document?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Brad"))
    }
    
    func test_fetchObjects_withObjectMapper() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        let user = try? couchbaseCollection?.fetchAll(User.self, whereExpression: expression).first
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_fetchDocument_withID() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let document = try? couchbaseCollection?.fetch(withDocumentID: "1")
        let name = (document?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Brad"))
    }
    
    func test_fetchSingleObject_withObjectMapper() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let user = try? couchbaseCollection?.fetch(User.self, documentID: "1")
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_fetchSingleObject_withCodable() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let user = try? couchbaseCollection?.fetch(User.self, documentID: "1")
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_deleteDocument_withExpression() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        try? couchbaseCollection?.deleteAll(whereExpression: expression)
        let document = try? couchbaseCollection?.fetchAll(whereExpression: expression).first
        expect(document).to(beNil())
    }
    
    func test_deleteDocument_withID() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        try? couchbaseCollection?.delete(withDocumentID: "1")
        let savedDocuments = try? couchbaseCollection?.fetchAll()
        expect(savedDocuments?.count).to(equal(1))
        let name = (savedDocuments?.first?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Charles"))
    }
    
    func test_deleteAllDocuments() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        try? couchbaseCollection?.save(documents)
        try? couchbaseCollection?.deleteAll()
        let count = try? couchbaseCollection?.fetchAll().count
        expect(count).to(equal(0))
    }
}
