//
//  TeamCell.swift
//  Flow
//
//  Created by dan on 06/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class TeamCell: UITableViewCell, DeclarativeCell {

	@IBOutlet public var logoImageView: UIImageView?
	@IBOutlet public var teamNameLabel: UILabel?
	@IBOutlet public var stadiumLabel: UILabel?
	@IBOutlet public var chairmanLabel: UILabel?
	
	public typealias T = TeamModel

	public func configure(_ team: TeamModel, path: IndexPath) {
		self.logoImageView?.downloadedFrom(url: team.shieldURL, contentMode: .scaleAspectFit)
		self.teamNameLabel?.text = team.name
		self.stadiumLabel?.text = team.coach?.fullName.uppercased() ?? "-"
		self.chairmanLabel?.text = team.chairman ?? "-"
	}
	
	public static var defaultHeight: CGFloat? {
		return 105
	}
	
}
