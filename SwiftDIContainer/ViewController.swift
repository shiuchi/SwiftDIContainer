//
//  ViewController.swift
//  SwiftDIContainer
//
//  Created by 志内 幸彦 on 2015/11/24.
//  Copyright © 2018年 shiuchi. All rights reserved.
//

import UIKit
import SwiftKVC

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let router = Router()
        
        var a = A()
        
        router.register(&a)
        router.register(B.self)
        router.register(C.self)
        
        a.b.log()
    }
}

class A: Injectable {
    var b: B!
    
    required init() {
    }
    
    func log() {
        print("A")
    }
}

class B: Injectable {
    var a: A!
    
    required init(){
    }
    
    func log() {
        print("B")
    }
}

class C: Injectable {
    var a:A!
    var b:B!
    
    required init(){
    }
    
    func log() {
        print("C")
    }
}


