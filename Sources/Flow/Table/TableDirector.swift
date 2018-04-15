//
//  TableDirector.swift
//  Flow
//
//  Created by Daniele Margutti on 15/04/2018.
//  Copyright © 2018 y. All rights reserved.
//

import Foundation
import UIKit

public class TableDirector: NSObject, UITableViewDelegate, UITableViewDataSource {
	
	public private(set) weak var tableView: UITableView?
	
	public private(set) var sections: [TableSection] = []

	public private(set) var adapters: [String: AbstractAdapterProtocol] = [:]

	public private(set) var reusableRegister: TableDirector.ReusableRegister

	public init(_ table: UITableView) {
		self.reusableRegister = TableDirector.ReusableRegister(table)
		super.init()
		self.tableView = table
		self.tableView?.delegate = self
		self.tableView?.dataSource = self
	}
	
	public func register(adapter: AbstractAdapterProtocol) {
		let modelID = String(describing: adapter.modelType)
		self.adapters[modelID] = adapter // register adapter
		self.reusableRegister.registerCell(forAdapter: adapter) // register associated cell types into the collection
	}
	
	public func reload(after task: (() -> (Void))? = nil, onEnd: (() -> (Void))? = nil) {
		guard let t = task else {
			self.tableView?.reloadData()
			return
		}
	}
	
	@discardableResult
	public func add(items: [ModelProtocol]) -> TableSection {
		let section = TableSection(items)
		self.sections.append(section)
		return section
	}
	
	public func add(_ section: TableSection, at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(section)
			return
		}
		self.sections.insert(section, at: i)
	}
	
	public func add(_ sections: [TableSection], at index: Int? = nil) {
		guard let i = index, i < self.sections.count else {
			self.sections.append(contentsOf: sections)
			return
		}
		self.sections.insert(contentsOf: sections, at: i)
	}
	
	@discardableResult
	public func removeAll(keepingCapacity kp: Bool = false) -> Int {
		let count = self.sections.count
		self.sections.removeAll(keepingCapacity: kp)
		return count
	}
	
	@discardableResult
	public func remove(at index: Int) -> TableSection? {
		guard index < self.sections.count else { return nil }
		return self.sections.remove(at: index)
	}
	
	@discardableResult
	public func remove(at indexes: IndexSet) -> [TableSection] {
		var removed: [TableSection] = []
		indexes.reversed().forEach {
			if $0 < self.sections.count {
				removed.append(self.sections.remove(at: $0))
			}
		}
		return removed
	}
	
	//MARK: Internal Functions
	
	internal func context(forItemAt index: IndexPath) -> (ModelProtocol, TableAdaterProtocolFunctions) {
		let item: ModelProtocol = self.sections[index.section].items[index.row]
		let modelID = String(describing: type(of: item.self))
		guard let adapter = self.adapters[modelID] else {
			fatalError("Failed to found an adapter for model: \(modelID)")
		}
		return (item,adapter as! TableAdaterProtocolFunctions)
	}
	
	//MARK: UITableViewDataSource
	
	public func numberOfSections(in tableView: UITableView) -> Int {
		return self.sections.count
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.sections[section].items.count
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let (model,adapter) = self.context(forItemAt: indexPath)
		let cell = adapter._instanceCell(in: tableView, at: indexPath)
		adapter._onDequeue(model: model, cell: cell, path: indexPath, table: tableView)
		return cell
	}
}
