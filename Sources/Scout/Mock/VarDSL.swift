//
//  VarDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/12/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

@dynamicMemberLookup
public struct VarDSL {
    let mock: Mock

    public subscript<T>(dynamicMember member: String) -> T! {
        get {
            let value = mock.next(expectationFor: member)
            guard let nonNilValue: Any = value else {
                return nil
            }

            guard let typedValue = nonNilValue as? T else {
                recordFailure("Expected value of type \(T.self) for \(member), got \(type(of: nonNilValue))")
                return nil
            }
            return typedValue
        }
    }
}
