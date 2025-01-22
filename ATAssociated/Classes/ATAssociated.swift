//
//  ATAssociated.swift
//  ATAssociated
//
//  Created by abiaoyo on 2024/6/19.
//

import Foundation

// MARK: - SafeDictionary
class _SafeDictionary<Key, Value> where Key: Hashable {
    let queue = DispatchQueue(label: "at.associated.safedictionary.queue", attributes: .concurrent)
    fileprivate var dictionary = [Key: Value]()
    public init() {}
    subscript(key: Key) -> Value? {
        get {
            var result:Value?
            queue.sync {
                result = dictionary[key]
            }
            return result
        }
        set(newValue) {
            queue.async(flags: .barrier, execute: { [weak self] in
                self?.dictionary[key] = newValue
            })
        }
    }
}

private struct ATAssociated_Keys {
    static var kWeek: Int = "at.associated.key.week".hashValue
    static var kStrong: Int = "at.associated.key.strong".hashValue
}

final public class ATAssociated_Strong{
    private lazy var container = _SafeDictionary<String,Any>()
    public subscript(key: String) -> Any? {
        get {
            return container[key]
        }
        set(newValue) {
            container[key] = newValue
        }
    }
    
    public func get<Value>(key:String, type:Value) -> Value? {
        return container[key] as? Value
    }
    
    public func get<Value>(key:String, defValue:Value, isSaveDefValue:Bool) -> Value {
        if let result:Value = container[key] as? Value {
            return result
        }
        if isSaveDefValue {
            container[key] = defValue
        }
        return defValue
    }
}

final public class ATAssociated_Weak {
    private lazy var container = NSMapTable<NSString,AnyObject>.strongToWeakObjects()
    public subscript(key: String) -> AnyObject? {
        get {
            return container.object(forKey: key as NSString)
        }
        set(newValue) {
            container.setObject(newValue, forKey: key as NSString)
        }
    }
}

public protocol ATAssociated:AnyObject {
    
}

extension ATAssociated {
    public var at_associated_weakContainer:ATAssociated_Weak {
        set { objc_setAssociatedObject(self, &ATAssociated_Keys.kWeek, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get {
            var container:ATAssociated_Weak? = objc_getAssociatedObject(self, &ATAssociated_Keys.kWeek) as? ATAssociated_Weak
            if container == nil {
                container = ATAssociated_Weak()
                objc_setAssociatedObject(self, &ATAssociated_Keys.kWeek, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return container!
        }
    }
    public var at_associated_strongContainer:ATAssociated_Strong {
        set { objc_setAssociatedObject(self, &ATAssociated_Keys.kStrong, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
        get {
            var container:ATAssociated_Strong? = objc_getAssociatedObject(self, &ATAssociated_Keys.kStrong) as? ATAssociated_Strong
            if container == nil {
                container = ATAssociated_Strong()
                objc_setAssociatedObject(self, &ATAssociated_Keys.kStrong, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return container!
        }
    }
}
