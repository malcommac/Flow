//
//  ProfileHeader.swift
//  FlowDemoApp
//
//  Created by danielemargutti on 08/10/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class ProfileHeader: UITableViewHeaderFooterView, DeclarativeView {
	
	public typealias T = Void
	
	public static var defaultHeight: CGFloat? = 60.0

	public func configure(_: Void, type: SectionType, section: Int) {
		
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		// Set the background view to apply a background color (otherwise we'll get a transparent background)
		self.backgroundView = UIView()
		self.backgroundView?.backgroundColor = APP_TINT_COLOR
	}
}
