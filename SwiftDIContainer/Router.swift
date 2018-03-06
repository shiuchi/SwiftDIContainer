//
//  Router.swift
//  reflect
//
//  Created by 志内 幸彦 on 2018/01/26.
//  Copyright © 2018年 shiuchi. All rights reserved.
//

import Foundation
import SwiftKVC


/// 簡易DIContainer
class Router {
    
    private typealias Label = String
    private typealias Instance = Value
    private typealias ClassName = String
    
    private struct WattingData {
        fileprivate let label: Label
        fileprivate var instance: Instance
    }
    
    private var list: [ ClassName : Instance ] = [:]
    private var waittings: [ ClassName : [ WattingData ] ] = [:]
    
    
    
    /// ClassType使用して登録
    ///
    /// - Parameter clazz:　Injectable.Type
    func register<T: Injectable>(_ clazz: T.Type) {
        var instance = clazz.init()
        register(&instance)
    }
    
    
    /// インスタンスを登録
    ///
    /// - Parameter instance: Injectable
    func register<T: Injectable>(_ instance:  inout T) {
        //get class name
        let className = String(describing: type(of: instance))
        
        //listに登録 すでに登録済みの場合は終了
        if list[className] == nil {
            list[className] = instance
            print("register : \(className)")
        } else {
            return
        }
    
        //必用なinstanceをlistから検索する
        let ref = Mirror(reflecting: instance)
        ref.children.forEach { param in
            guard let label = param.label else { return }
            let classType = type(of: param.value)
            //if instance[label] == nil {
                //登録済みclassから検索する
                if let obj = find(classType) {
                    do {
                        print("set \(className).\(label) = \(obj)")
                        try instance.set(value: obj, key: label)
                    } catch {
                        print(error)
                    }
                } else {
                    let wattingClassName = getClassName(classType)
                    // 見つからなかった場合はwaittingListに追加
                    if var waittings = waittings[wattingClassName] {
                        waittings.append(WattingData(label: label, instance: instance))
                    } else {
                        waittings[wattingClassName] = [WattingData(label: label, instance: instance)]
                    }
                }
            //}
        }
        
        //watting listを検索して登録
        if let waittings = waittings[className] {
            waittings.forEach { data in
                var wattingInstance = data.instance
                do {
                    try wattingInstance.set(value: instance, key: data.label)
                    print("set \(getClassName(instance)).\(data.label) = \(instance)")
                } catch {
                    print(error)
                }
            }
        }
    }
    
    // クラス参照からクラス名を返却する optionalの場合もクラス名だけを返却する
    private func getClassName<T>(_ c: T) -> String {
        var className = String(describing: type(of: c)).components(separatedBy: ".").first!
        //optionalを取り除く
        let ignoreCases = ["Optional<", ">", "ImplicitlyUnwrapped"]
        ignoreCases.forEach { ignoreString in
            className = className.replacingOccurrences(of: ignoreString, with: "")
        }
        return className
    }
    
    private func find<T>(_ c: T) -> Any? {
        let className = getClassName(c)
        return list[className]
    }
    
}


public protocol Injectable: class, Value {
    init()
}

extension Injectable {
    
}
