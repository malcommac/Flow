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
		
		var articlesList: [Article] = []
		for i in 0..<3000 {
			articlesList.append(Article("\(i) A set of cool animated page controls written in Swift to replace boring UIPageControl.", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."))
		}
		
		
		self.tableDirector = TableDirector(self.tableView!)
		self.tableDirector?.rowHeight = .autoLayout(estimated: 80)
		
		let articleAdapter = TableAdapter<Article, TableAdaptiveCell>()
		self.tableDirector?.register(adapter: articleAdapter)
		
		articleAdapter.on.dequeue = { context in
			context.cell?.labelTitle?.text = context.model.title
			context.cell?.labelSubtitle?.text = context.model.subtitle
		}
		
		articleAdapter.on.didSelect = { context in
			print("Tap on \(context.model.title)")
			return .deselectAnimated
		}
		
		
		self.tableDirector?.add(items: articlesList)
		self.tableDirector?.reload()
	}
}

public class TableAdaptiveCell: UITableViewCell {
	@IBOutlet public var labelTitle: UILabel?
	@IBOutlet public var labelSubtitle: UILabel?
}
