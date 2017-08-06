//
//  MultilineTextCell.swift
//  Flow
//
//  Created by dan on 06/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class MultilineTextCell: UITableViewCell, DeclarativeCell {
	
	@IBOutlet public var titleLabel: UILabel?
	@IBOutlet public var subtitleLabel: UILabel?
	
	public typealias T = TeamModel
	
	public func configure(_ team: TeamModel, path: IndexPath) {
		self.titleLabel?.text = "Biography"
		self.subtitleLabel?.text = team.bio ?? "No biography available"
	}
	
	public static var defaultHeight: CGFloat? {
		return UITableViewAutomaticDimension
	}
	
}
