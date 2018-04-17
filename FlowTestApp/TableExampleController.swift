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
		
		let adapterC = TableAdapter<Article, TableAdaptiveCell>()
		adapterC.on(.dequeue { context in
			context.cell?.labelTitle?.text = context.model.title
			context.cell?.labelSubtitle?.text = context.model.subtitle
		})
		
	
		
		self.tableDirector?.register(adapter: adapterC)
		
		adapterC.on(.dequeue { context in
			print("ciao")
		})
		
		
		var l: [Article] = []
		for i in 0..<100 {
			l.append(Article("Titolo #\(i)", "sottotitolo \(i)"))
		}
		self.tableDirector?.add(items: l)
		
		self.tableDirector?.reload()
	}
}

public class TableAdaptiveCell: UITableViewCell {
	@IBOutlet public var labelTitle: UILabel?
	@IBOutlet public var labelSubtitle: UILabel?
}
