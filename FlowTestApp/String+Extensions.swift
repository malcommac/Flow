//
//  String+Extensions.swift
//  FlowTestApp
//
//  Created by danielemargutti on 11/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation

public extension String {
	
	static func randomAlphaNumericString(length: Int) -> String {
		let charactersString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
		let charactersArray : [Character] = Array(charactersString.characters)
		
		var string = ""
		for _ in 0..<length {
			string.append(charactersArray[Int(arc4random()) % charactersArray.count])
		}
		
		return string
	}
	
}
