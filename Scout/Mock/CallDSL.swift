//
//  CalLDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/12/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

// DSL for invoking expected function calls on a mock.
@dynamicMemberLookup
public struct CallDSL {
    let mock: Mock

    public subscript(dynamicMember member: String) -> MockKeywordCall {
        get {
            return MockKeywordCall(mock: mock, member: member)
        }
    }
}

@dynamicCallable
public struct MockKeywordCall {
    let mock: Mock
    let member: String

    @discardableResult
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, Any?>) throws -> Any? {
        let expectationValue = mock.next(expectationFor: member)
        guard let action = expectationValue as? FuncExpectationBlock else {
            // no more expectations defined, which Mock should have reported
            return nil
        }
        return try action(args)
    }
}
