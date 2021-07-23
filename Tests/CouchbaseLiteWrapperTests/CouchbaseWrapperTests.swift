import XCTest
import CouchbaseLiteSwift
import Nimble
@testable import CouchbaseLiteWrapper
    
final class CouchbaseWrapperTests: XCTestCase {
    
    var couchbaseDataBase: CouchbaseDatabase?
    
    override func setUp() {
        couchbaseDataBase = CouchbaseDatabase(databaseName: "User")
    }
    
    override func tearDown() {
        couchbaseDataBase?.deleteAll()
    }
    
    func test_databaseSetup_withDatabaseName() {
        expect(self.couchbaseDataBase).notTo(beNil())
        expect(self.couchbaseDataBase?.database).notTo(beNil())
    }
    
    func test_databaseSetup_withConfiguration() {
        let databaseConfiguration = CouchbaseDatabaseConfiguration(databaseName: "User")
        let couchbaseDatabase = CouchbaseDatabase(configuration: databaseConfiguration)
        expect(couchbaseDatabase).notTo(beNil())
        expect(couchbaseDatabase.database).notTo(beNil())
    }
    
    func test_saveDocument() {
        let document = CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"])
        couchbaseDataBase?.save(document)
        let documents = couchbaseDataBase?.fetchAll()
        expect(documents?.first).notTo(beNil())
    }
    
    func test_saveDocuments() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let count = couchbaseDataBase?.fetchAll().count ?? 0
        expect(count).to(equal(2))
    }
    
    func test_fetchDocument_withExpressions() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        let document = couchbaseDataBase?.fetchAll(whereExpression: expression).first
        expect(document).notTo(beNil())
        let name = (document?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Brad"))
    }
    
    func test_fetchObjects_withObjectMapper() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        let user = couchbaseDataBase?.fetchAll(User.self, whereExpression: expression).first
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_fetchDocument_withID() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let document = couchbaseDataBase?.fetch(withDocumentID: "1")
        let name = (document?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Brad"))
    }
    
    func test_fetchSingleObject_withObjectMapper() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let user = couchbaseDataBase?.fetch(User.self, documentID: "1")
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_fetchSingleObject_withCodable() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let user = couchbaseDataBase?.fetch(UserCodable.self, documentID: "1")
        expect(user?.name).to(equal("Brad"))
        expect(user?.lastName).to(equal("Depp"))
    }
    
    func test_deleteDocument_withExpression() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        let expression = Expression.property("attributes.name").equalTo(Expression.string("Brad"))
        couchbaseDataBase?.deleteAll(whereExpression: expression)
        let document = couchbaseDataBase?.fetchAll(whereExpression: expression).first
        expect(document).to(beNil())
    }
    
    func test_deleteDocument_withID() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        couchbaseDataBase?.delete(withDocumentID: "1")
        let savedDocuments = couchbaseDataBase?.fetchAll()
        expect(savedDocuments?.count).to(equal(1))
        let name = (savedDocuments?.first?.attributes?["name"] as? String) ?? ""
        expect(name).to(equal("Charles"))
    }
    
    func test_deleteAllDocuments() {
        var documents: [CouchbaseDocument] = []
        documents.append(CouchbaseDocument(id: "1", attributes: ["name": "Brad", "last_name": "Depp"]))
        documents.append(CouchbaseDocument(id: "2", attributes: ["name": "Charles", "last_name": "Xavier"]))
        couchbaseDataBase?.save(documents)
        couchbaseDataBase?.deleteAll()
        let count = couchbaseDataBase?.fetchAll().count
        expect(count).to(equal(0))
    }
    
}
