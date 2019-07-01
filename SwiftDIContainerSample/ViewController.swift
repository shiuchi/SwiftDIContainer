//
//  ViewController.swift
//  SwiftDIContainerSample
//
//  Created by shiuchi on 2019/06/25.
//  Copyright © 2019 shiuchi. All rights reserved.
//

import UIKit
import SwiftDIContainer

class ViewController: UIViewController {
    
    var instanceClassA = ClassA(input: "classA::id")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let container = SwiftDIContainer()
        container.register(instanceClassA)
        container.register(ClassB.self)
        container.register(ClassC.self, input: (index: 0, id: "id"))
        instanceClassA.log()
    }
}

class ClassA: Injectable {
    typealias Input = String

    let id: String
    var instanceClassB: ClassB!
    var instanceClassC: ClassC!

    required init(input: Input) {
        self.id = input
    }

    func log() {
        print("ClassA:log")
        print(instanceClassB)
        print(instanceClassC)
    }
}

class ClassB: Injectable {
    typealias Input = Void

    var instanceA: ClassA = ClassA(input: "Inner classA")
    required init(input: Void) {
    }
}

class ClassC: Injectable {
    typealias Input = (index: Int, id: String)

    private let index: Int
    private let id: String

    required init(input: Input) {
        self.id = input.id
        self.index = input.index
    }
}
