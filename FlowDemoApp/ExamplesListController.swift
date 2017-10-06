//
//  ExamplesListController.swift
//  Flow-iOS
//
//  Created by danielemargutti on 04/10/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit

public class ExamplesListController : UIViewController {
    
    @IBOutlet public var table: UITableView?
    private var tableManager: TableManager?
    

    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.tableManager = TableManager(table: self.table!)
    }
    
}

public class CellExampleList: UITableViewCell, DeclarativeCell {
    public func configure(_: ExampleItemModel, path: IndexPath) {
        
    }
    
    public typealias T = ExampleItemModel
    
    
}

public class ExampleItemModel {
    public var label: String
    public var icon: UIImageView
    
    public init(_ label: String, icon: UIImageView) {
        self.label = label
        self.icon = icon
    }
}
