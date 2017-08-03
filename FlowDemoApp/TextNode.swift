//
//  TextNode.swift
//  Flow
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation

public struct TextNode {
	public var title: String
	public var subtitle: String
	
	public static func load(_ name: String) -> [TextNode] {
		guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {
			return []
		}
		let list = NSArray(contentsOfFile: path)
		return (list as! [Any]).map({
			return TextNode(title: ($0 as! NSDictionary).value(forKey: "title") as! String, subtitle: ($0 as! NSDictionary).value(forKey: "subtitle") as! String)
		}) as [TextNode]
	}
}
