//
//  CellExpandable.swift
//  Flow
//
//  Created by dan on 03/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class CellExpandable: UITableViewCell, DeclarativeCell {
	public typealias T = ExpandableNode
	
	@IBOutlet public var button: UIButton?
	
	public func configure(_ node: ExpandableNode, path: IndexPath) {

	}
	
}
