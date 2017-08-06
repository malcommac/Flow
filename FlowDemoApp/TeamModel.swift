//
//  TeamModel.swift
//  Flow
//
//  Created by dan on 05/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation

public struct TeamModel {
	
	public var name: String
	public var shieldURL: URL?
	public var coach: PlayerModel? = nil
	public var chairman: String? = nil
	public var members: [PlayerModel] = []
	public var subtitle: String?
	public var bio: String?
	
	public init(name: String, shield: URL?, subtitle: String?, bio: String?) {
		self.name = name
		self.shieldURL = shield
		self.subtitle = subtitle
		self.bio = bio
	}
	
}
