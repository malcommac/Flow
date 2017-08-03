//
//  CellButton.swift
//  Flow
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class CellButton: UITableViewCell, DeclarativeCell {
	public typealias T = String
	
	@IBOutlet public var button: UIButton?
	
	public func configure(_ title: String, path: IndexPath) {
		self.button?.setTitle(title, for: .normal)
	}
	
	public static var defaultHeight: CGFloat? {
		return 77.0
	}
	
}
