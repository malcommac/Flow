//
//  PlayerCell.swift
//  Flow
//
//  Created by dan on 05/08/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class PlayerCell: UITableViewCell, DeclarativeCell {

	public typealias T = PlayerModel

	@IBOutlet public var fullNameLabel: UILabel?
	@IBOutlet public var avatarImageView: UIImageView?
	@IBOutlet public var roleLabel: UILabel?
	@IBOutlet public var shirtNumberLabel: UILabel?
	@IBOutlet public var shirtNumberBack: UIView?
	
	/// Configure a cell instance just after the dequeue from table instance
	///
	/// - Parameters:
	///   - _: item to render
	///   - path: index path
	public func configure(_ player: PlayerModel, path: IndexPath) {
		self.fullNameLabel?.text = player.fullName
		self.roleLabel?.text = player.role.rawValue.uppercased()
		self.avatarImageView?.downloadedFrom(url: player.avatarURL, contentMode: .scaleAspectFill)
		self.shirtNumberLabel?.text = player.shirtNumber != nil ? "\(player.shirtNumber!)" : ""
		self.shirtNumberBack?.backgroundColor = player.role.color
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		self.fullNameLabel?.text = ""
		self.avatarImageView?.image = nil
		self.roleLabel?.text = ""
	}
	
	public static var defaultHeight: CGFloat? {
		return 120
	}
}
