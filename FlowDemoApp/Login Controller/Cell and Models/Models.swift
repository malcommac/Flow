//
//  Models.swift
//  Flow-iOS
//
//  Created by Daniele Margutti on 28/09/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit

/// This model is used to represent the login data credentials
public class LoginCredentialsModel {
	var email: String = ""
	var password: String = ""
}

/// This model represent a single user
public class UserProfile {
	var firstName: String
	var lastName: String
	var mood: String
	var friends: [FriendUser] = []
	var attributes: [UserProfileAttribute] = []

	
	/// Just create a fake logged user
	///
	/// - Returns: user instance
	public static func loggedUser() -> UserProfile {
		let user = UserProfile(first: "Mark", last: "Zuckerbergo", mood: "I share hard!")
		user.friends = [
			FriendUser("Tim","Cook", UIImage(named: "cook")!),
			FriendUser("Steve","Jobs", UIImage(named: "jobs")!),
			FriendUser("Jeff","Bezos", UIImage(named: "bezos")!),
			FriendUser("Sundar","Pichai", UIImage(named: "pichai")!),
			FriendUser("Bill","Gates", UIImage(named: "gates")!)
		]
		user.attributes = [
			UserProfileAttribute("Job", value: "Facebook Inc"),
			UserProfileAttribute("Position", value: "CEO"),
			UserProfileAttribute("Birthdate", value: "11/06/2017 - 24yrs"),
			UserProfileAttribute("Debugger Level", value: "Top ★★★")
		]
		return user
	}
	
	init(first: String, last: String, mood: String) {
		self.firstName = first
		self.lastName = last
		self.mood = mood
	}
}

/// Represent a single profile's attribute of the user
public struct UserProfileAttribute {
	var label: String
	var value: String
	
	init(_ label: String, value: String) {
		self.label = label
		self.value = value
	}
}

/// Represent a single friend of the profile
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

