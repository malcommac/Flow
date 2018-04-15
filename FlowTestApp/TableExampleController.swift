//
//  TableExampleController.swift
//  FlowTestApp
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public class TableExampleController: UIViewController {
	
	@IBOutlet public var tableView: UITableView?
	
	private var tableDirector: TableDirector?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		self.tableDirector = TableDirector(self.tableView!)
		
		let adapterC = TableAdapter<Article, TableAdaptiveCell> {
			$0.onConfigure = { context in
				context.cell?.labelTitle?.text = context.model.title
				context.cell?.labelSubtitle?.text = context.model.subtitle
			}
		}
		self.tableDirector?.register(adapter: adapterC)
	}
}

public class TableAdaptiveCell: UITableViewCell {
	@IBOutlet public var labelTitle: UILabel?
	@IBOutlet public var labelSubtitle: UILabel?
}
