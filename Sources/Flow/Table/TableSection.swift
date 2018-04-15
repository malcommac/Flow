//
//  TableSection.swift
//  Flow
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public class TableSection {
	
	public private(set) var items: [ModelProtocol] = []
	
	
	public init(_ items: [ModelProtocol]) {
		self.items = items
	}
	
}
