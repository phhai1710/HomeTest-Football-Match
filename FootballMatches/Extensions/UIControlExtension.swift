//
//  UIControlExtension.swift
//  FootballMatches
//
//  Created by Hai Pham on 03/03/2023.
//

import Foundation
import UIKit

private class Invoker: ClosureWrapper<UIControl?> {
    weak var control: UIControl?

    convenience init(_ control: UIControl, _ closure: @escaping (UIControl?) -> Void) {
        self.init(closure)
        self.control = control
    }

    @objc func invoke() {
        closure(control)
    }
}

private typealias Dealer = DicWrapper<UInt, ArrayWrapper<Invoker>>

private var dealerKey: UInt = 0

extension UIControl: Attachable {

    fileprivate func invokers(
        forEvents events: UIControl.Event, createIfNotExist: Bool = true) -> ArrayWrapper<Invoker>? {
        let dealer: Dealer? = self.getAttach(forKey: &dealerKey) as? Dealer ?? {
            if !createIfNotExist {
                return nil
            }
            let dealer = Dealer()
            self.set(dealer, forKey: &dealerKey)
            return dealer
            }()
        if nil == dealer {
            return nil
        }
        let invokers: ArrayWrapper<Invoker>? = dealer!.dic[events.rawValue] ?? {
            if !createIfNotExist {
                return nil
            }
            let invokers = ArrayWrapper<Invoker>()
            dealer!.dic[events.rawValue] = invokers
            return invokers
            }()
        return invokers
    }

    public func add(_ events: UIControl.Event, _ closure: @escaping (UIControl?) -> Void) {
        removeTarget(nil, action: nil, for: .allEvents)
        let box = invokers(forEvents: events)
        let invoker = Invoker(self, closure)
        box!.array.append(invoker)
        self.addTarget(invoker, action: #selector(Invoker.invoke), for: events)
    }

    public func remove(_ events: UIControl.Event) {
        guard let box = invokers(forEvents: events, createIfNotExist: false) else {
            return
        }
        for invoker in box.array {
            self.removeTarget(invoker, action: #selector(Invoker.invoke), for: events)
        }
        box.array.removeAll()
    }

    public func didAdd(_ events: UIControl.Event) -> Bool {
        guard let box = invokers(forEvents: events, createIfNotExist: false) else {
            return false
        }
        return box.array.count > 0
    }
}

class DicWrapper<K: Hashable, V> {
    var dic = [K: V]()
}

class ArrayWrapper<T> {
    var array = [T]()
}

class ClosureWrapper<T> {
    var closure: (T) -> Void
    init(_ closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}

public protocol Attachable {

    func set(_ attachObj: Any?, forKey key: inout UInt)
    func getAttach(forKey key: inout UInt) -> Any?

}

extension Attachable {

    public func set(_ attachObj: Any?, forKey key: inout UInt) {
        objc_setAssociatedObject(self, &key, attachObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    public func getAttach(forKey key: inout UInt) -> Any? {
        return objc_getAssociatedObject(self, &key)
    }
}
