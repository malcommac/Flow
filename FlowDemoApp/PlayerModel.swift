//
//  PlayerModel.swift
//  Flow
//
//  Created by dan on 05/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit

public struct PlayerModel {
	
	public enum Role: String {
		case goalkeeper = "goalkeeper"
		case defender = "defender"
		case midfielder = "midfielder"
		case forward = "forward"
		case coach = "coach"
		
		public var color: UIColor {
			switch self {
			case .goalkeeper: return UIColor.fromHex("#00C5D1")
			case .defender: return UIColor.fromHex("#E01111")
			case .midfielder: return UIColor.fromHex("#2911E0")
			case .forward: return UIColor.fromHex("#D3C728")
			case .coach: return UIColor.fromHex("#1F1F1F")
			}
		}
	}
	
	public var firstName: String
	public var lastName: String
	public var avatarURL: URL?
	public var role: Role
	public var shirtNumber: Int?
	
	public var fullName: String {
		return "\(self.firstName) \(self.lastName)".trimmingCharacters(in: .whitespaces).capitalized
	}
	
	public init(_ first: String, _ last: String, _ role: Role) {
		self.firstName = first
		self.lastName = last
		self.role = role
	}
	
	public static func load(_ name: String) -> [PlayerModel] {
		guard let path = Bundle.main.path(forResource: name, ofType: "plist") else {
			return []
		}
		let list = NSDictionary(contentsOfFile: path)?.value(forKey: "members") as! NSArray
		return (list as! [NSDictionary]).map({
			var player = PlayerModel($0.value(forKey: "first") as! String,
			                         $0.value(forKey: "last") as! String,
			                         Role(rawValue: $0.value(forKey: "role") as! String)!)
			if let url = $0.value(forKey: "url") as? String {
				player.avatarURL = URL(string: url)
			}
			if let shirt = $0.value(forKey: "number") as? String {
				player.shirtNumber = Int(shirt)!
			}
			return player
		}) as [PlayerModel]
	}
	
}
