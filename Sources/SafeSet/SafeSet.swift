//
//  SafeSet.swift
//  Networking
//
//  Created by Sỹ Quân on 26/09/2023.
//

import Foundation
public class SafeSet<T> where T: Hashable {
    private let locker = NSLock()
    private var value: Set<T>

    init(value: Set<T>) {
        self.value = value
    }

    func remove(_ element: T) {
        defer {
            locker.unlock()
        }
        locker.lock()
        value.remove(element)
    }

    func insert(_ element: T) {
        defer {
            locker.unlock()
        }
        locker.lock()
        value.insert(element)
    }

    func contains(_ element: T) -> Bool {
        return value.contains(element)
    }

    func forEach(
        _ body: (T) throws -> Void
    ) rethrows {
        for element in value {
            try body(element)
        }
    }
}
