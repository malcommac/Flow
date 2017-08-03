//
//  CellMultilineText.swift
//  Flow
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class CellMultilineText: UITableViewCell, DeclarativeCell {
	public typealias T = TextNode

	@IBOutlet public var labelTitle: UILabel?
	@IBOutlet public var labelSubtitle: UILabel?
	
	public func configure(_ node: TextNode, path: IndexPath) {
		self.labelTitle?.text = node.title
		self.labelSubtitle?.text = node.subtitle
		self.labelTitle?.highlightedTextColor = UIColor.white
		self.labelSubtitle?.highlightedTextColor = UIColor.white
		self.accessoryType = .disclosureIndicator
		
		self.selectedBackgroundView = UIView()
		self.selectedBackgroundView?.backgroundColor = (path.row % 2 == 0 ? UIColor.red : UIColor.green)
	}
	
	public static var defaultHeight: CGFloat? {
		return UITableViewAutomaticDimension
	}

}
