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
	
	public var headerTitle: String?
	
	public var footerTitle: String?
	
	public var headerView: AbstractTableHeaderFooterItem?
	
	public var footerView: AbstractTableHeaderFooterItem?
	
	public var headerHeight: CGFloat?
	
	public var footerHeight: CGFloat?
	
	public var onGetHeaderHeight: (() -> CGFloat)? = nil
	
	public var onGetFooterHeight: (() -> CGFloat)? = nil
	
	public var onWillDisplayHeader: ((UIView) -> (Void))? = nil

	public var onWillDisplayFooter: ((UIView) -> (Void))? = nil

	public var onDidEndDisplayFooter: ((UIView) -> (Void))? = nil
	
	public var onDidEndDisplayHeader: ((UIView) -> (Void))? = nil
	
	public var indexTitle: String?

	public init(_ items: [ModelProtocol]?) {
		self.items = (items ?? [])
	}
	
	public convenience init(headerTitle: String?, footerTitle: String?,
							items: [ModelProtocol]? = nil) {
		self.init(items)
		self.headerTitle = headerTitle
		self.footerTitle = footerTitle
	}
	
	public convenience init(headerView: AbstractTableHeaderFooterItem?, footerView: AbstractTableHeaderFooterItem?,
							items: [ModelProtocol]? = nil) {
		self.init(items)
		self.headerView = headerView
		self.footerView = footerView
	}
	
}
