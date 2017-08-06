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
	public var members: [PlayerModel] = []
	
	public init(name: String, shield: URL) {
		self.name = name
		self.shieldURL = shield
	}
	
}
