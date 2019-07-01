//
//  SwiftDIContainer.swift
//  reflect
//
//  Created by shiuchi on 2018/01/26.
//  Copyright © 2018年 shiuchi. All rights reserved.
//

import Runtime

/// Simple DIContainer
public class SwiftDIContainer {
    
    private typealias Label = String
    private typealias Instance = Any
    private typealias ClassName = String

    private struct WattingData {
        fileprivate var instance: Instance
        fileprivate let property: PropertyInfo
    }

    private var list: [ ClassName : Instance ] = [:]
    private var waittings: [ ClassName : [ WattingData ] ] = [:]

    public init() {
    }

    /// Register ClassType
    ///
    /// - Parameter clazz:　Injectable.Type
    public func register<T: Injectable, Input>(_ clazz: T.Type, input: Input) where T.Input == Input{
        let instance = clazz.init(input: input)
        register(instance)
    }

    public func register<T: Injectable>(_ clazz: T.Type) where T.Input == Void {
        let instance = clazz.instantiate()
        register(instance)
    }

    public func register<T: Injectable>(_ _instance: T) {
        var instance = _instance
        register(&instance)
    }
    
    /// Register
    ///
    /// - Parameter instance Injectable
    private func register<T: Injectable>(_ instance:  inout T) {
        //get class name
        let className = String(describing: type(of: instance))

        //add list, if already register class, do nothing...
        if list[className] == nil {
            list[className] = instance
        } else {
            return
        }
        
        guard let info = try? typeInfo(of: T.self) else {
            return
        }
        
        //injection
        info.properties.filter { p in
            //todo except for Injectable
            return !isSwiftStandardLibrary(p.type) && p.isVar
        }.filter { p in
            if let value = try? p.get(from: instance) {
                if isOptional(p.type) {
                    return cast(value: value, type: p.type) == nil
                }
                return false
            } else {
                return true
            }
        }.forEach { p in
            if let obj = find(p.type) {
                try? p.set(value: obj, on: &instance)
            } else {
                // if could not find class instance, add wating list
                let wattingClassName = getClassName(p.type)
                let watingData = WattingData(instance: instance, property: p)
                if var waittings = waittings[wattingClassName] {
                    waittings.append(watingData)
                } else {
                    waittings[wattingClassName] = [watingData]
                }
            }
        }
            
        //search watting list, and inject.
        if let waitList = waittings[className] {
            waitList.forEach { data in
                var wattingInstance = data.instance
                try? data.property.set(value: instance, on: &wattingInstance)
            }
            waittings.removeValue(forKey: className)
        }
    }

    private func cast<T>(value: Any, type: T) -> T? {
        return value as? T
    }
    
    private func isSwiftStandardLibrary<T>(_ c: T) -> Bool {
        return getModuleName(c.self) == "Swift"
    }
    
    private func isOptional<T>(_ c: T) -> Bool {
        return String(describing: c.self).contains("Optional<")
    }
    
    /// return Module Name
    ///
    /// - Parameter c: some class
    /// - Returns: String
    private func getModuleName<T>(_ c: T) -> String {
        var className = String(reflecting: c.self)
        if className.contains("Swift.Optional<") {
            let ignoreCases = ["Swift.Optional<", ">"]
            ignoreCases.forEach { ignoreString in
                className = className.replacingOccurrences(of: ignoreString, with: "")
            }
        }
        return className.components(separatedBy: ".").first ?? className
    }
    
    
    /// return class name
    ///
    /// - Parameter c: some class
    /// - Returns: String
    private func getClassName<T>(_ c: T) -> String {
        var className = String(describing: c.self).components(separatedBy: ".").first!
        //remove optional
        let ignoreCases = ["Optional<", ">"]
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

public protocol Injectable: class {
    associatedtype Input
    init(input: Input)
}

public extension Injectable where Input == Void {
    static func instantiate() -> Self {
        return self.init(input: ())
    }
}
