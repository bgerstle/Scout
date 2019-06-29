//
//  ExpectVarDSL.swift
//  Scout
//
//  Created by Brian Gerstle on 6/13/19.
//  Copyright © 2019 Brian Gerstle. All rights reserved.
//

import Foundation

public struct ExpectVarDSL {
    let mock: Mock
    let member: String

    @discardableResult
    public func to(_ expectation: Expectation, _ file: StaticString = #file, _ line: UInt = #line) -> ExpectVarDSL {
        mock.append(expectation: expectation, for: member)
        return self
    }
    
    public var and: ExpectVarDSL {
        return self
    }
}
