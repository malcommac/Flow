//
//  Models.swift
//  Flow-iOS
//
//  Created by dan on 28/09/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit


public struct LoginCredentialsModel {
	var email: String = ""
	var password: String = ""
}

public struct UserProfile {
	var firstName: String
	var lastName: String
	var mood: String
	
	public lazy var friends: [FriendUser] = {
		let friends = [
			FriendUser("Tim","Cook", UIImage(named: "cook")!),
			FriendUser("Steve","Jobs", UIImage(named: "jobs")!),
			FriendUser("Jeff","Bezos", UIImage(named: "bezos")!),
			FriendUser("Sundar","Pichai", UIImage(named: "pichai")!),
			FriendUser("Bill","Gates", UIImage(named: "gates")!)
		]
		return friends
	}()
}

public struct UserProfileAttribute {
	var label: String
	var value: String
	
	init(_ label: String, value: String) {
		self.label = label
		self.value = value
	}
}

public struct FriendUser {
	var firstName: String
	var lastName: String
	var avatar: UIImage
	
	init(_ first: String, _ last: String, _ avatar: UIImage) {
		self.firstName = first
		self.lastName = last
		self.avatar = avatar
	}
}

