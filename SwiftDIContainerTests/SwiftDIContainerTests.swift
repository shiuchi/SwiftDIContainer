//
//  SwiftDIContainerTests.swift
//  SwiftDIContainerTests
//
//  Created by shiuchi on 2019/06/25.
//  Copyright © 2019 shiuchi. All rights reserved.
//

import XCTest
@testable import SwiftDIContainer

class SwiftDIContainerTests: XCTestCase {

    private let contaier: SwiftDIContainer = SwiftDIContainer()
    
    func testSwiftDIContainer() {
        let a = ClassA.init(input: "id")
        contaier.register(a)
        contaier.register(ClassB.self)
        contaier.register(ClassC.self, input: (0, "id"))
        
        XCTAssertNotNil(a.instanceClassB)
        XCTAssertNotNil(a.instanceClassC)
        XCTAssertNil(a.instanceClassD)
        
        XCTAssertNotEqual(a, a.instanceClassB.instanceA)
        XCTAssertEqual(a, a.instanceClassC.instanceA)
        
        contaier.register(ClassD.self)
        XCTAssertNotNil(a.instanceClassD)
        
        //not override same class instance
        let otherA = ClassA.init(input: "other A")
        XCTAssertNotEqual(a, otherA)
        
        contaier.register(otherA)
        XCTAssertNotEqual(otherA, a.instanceClassB.instanceA)
    }

}

class ClassA: Injectable {
    typealias Input = String
    
    let id: String
    var instanceClassB: ClassB!
    var instanceClassC: ClassC!
    var instanceClassD: ClassD!
    
    required init(input: Input) {
        self.id = input
    }
}

extension ClassA: Equatable {
    static func == (lhs: ClassA, rhs: ClassA) -> Bool {
        return lhs.id == rhs.id
    }
}

class ClassB: Injectable {
    typealias Input = Void
    
    var instanceA: ClassA = ClassA(input: "innterA")
    required init(input: Void) {
    }
}

class ClassC: Injectable {
    typealias Input = (index: Int, id: String)
    
    private let index: Int
    private let id: String
    var instanceA: ClassA?
    
    required init(input: Input) {
        self.id = input.id
        self.index = input.index
    }
}

class ClassD: Injectable {
    typealias Input = Void
    required init(input: Void) {
    }
}
