//
//  TeamSectionView.swift
//  Flow
//
//  Created by dan on 06/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class TeamSectionView: UITableViewHeaderFooterView, DeclarativeView {
	
	public typealias T = TeamModel
	
	@IBOutlet public var sectionLabel: UILabel?
	
	public static var defaultHeight: CGFloat? {
		return 56
	}
	
	public func configure(_ item: TeamModel, type: SectionType, section: Int) {
		self.sectionLabel?.text = item.name.uppercased()
	}
}
