//
//  Table+Support.swift
//  Flow
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit


public protocol AbstractTableHeaderFooterItem : AbstractCollectionReusableView {

}



extension UITableViewCell: CellProtocol {
	
}

public extension TableDirector {
	
	public class ReusableRegister {
		
		public private(set) weak var table: UITableView?

		public private(set) var cellIDs: Set<String> = []
		
		public private(set) var headersFootersIDs: Set<String> = []
		
		internal init(_ table: UITableView) {
			self.table = table
		}
		
		@discardableResult
		internal func registerCell(forAdapter adapter: AbstractAdapterProtocol) -> Bool {
			let identifier = adapter.cellReuseIdentifier
			guard !cellIDs.contains(identifier) else {
				return false
			}
			let bundle = Bundle.init(for: adapter.cellClass)
			if let _ = bundle.path(forResource: identifier, ofType: "nib") {
				let nib = UINib(nibName: identifier, bundle: bundle)
				table?.register(nib, forCellReuseIdentifier: identifier)
			} else if adapter.registerAsClass {
				table?.register(adapter.cellClass, forCellReuseIdentifier: identifier)
			}
			cellIDs.insert(identifier)
			return true
		}
		
	
	}
	
}
