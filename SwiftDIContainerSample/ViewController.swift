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
        
//        var hoge = Hoge(id: 0)
//        list.register(&hoge)
//        hoge.id = 2
//
//        print(hoge.id)
    }
}



struct Hoge {
    var id: Int
    var a: ClassA? = nil
    init(id: Int, a: ClassA? = nil){
        self.id = id
    }
    
    mutating func update(id: Int) {
        self.id = id
    }
}

class ClassA: Injectable {
    typealias Input = String

    let id: String
    var hoge = Hoge(id: 0)
    var instanceClassB: ClassB!
    var instanceClassC: ClassC!

    required init(input: Input) {
        self.id = input
    }

    func log() {
        print(instanceClassB)
        print(instanceClassC)
        print(hoge.id)
    }

}

class ClassB: Injectable {
    typealias Input = Void

    var instanceA: ClassA = ClassA(input: "idddd")
    var hoge: Hoge?

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
