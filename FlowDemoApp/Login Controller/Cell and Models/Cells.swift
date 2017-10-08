//
//  Cells.swift
//  Flow-iOS
//
//  Created by Daniele Margutti on 28/09/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow


/// This is the logo
public class CellLogo: UITableViewCell, DeclarativeCell {
	public typealias T = Void

	public static var defaultHeight: CGFloat? = 157.0

	public func configure(_: Void, path: IndexPath) { }
	
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.removeMargins()
    }
	
}

public class CellAutosizeText: UITableViewCell, DeclarativeCell {
	public typealias T = String
	
	@IBOutlet public var contentLabel: UILabel?
	
	public func configure(_ text: String, path: IndexPath) {
		self.contentLabel?.text = text
	}
	
}

public class CellLoginCredential: UITableViewCell, DeclarativeCell, UITextFieldDelegate {
	public typealias T = LoginCredentialsModel
    
	@IBOutlet public var emailField: UITextField?
	@IBOutlet public var passwordField: UITextField?
	@IBOutlet public var buttonLogin: UIButton?

	public static var defaultHeight: CGFloat? = 210.0

    private var credentials: LoginCredentialsModel?
	public var onTapLogin: (() -> (Void))? = nil
    
    public override func awakeFromNib() {
        super.awakeFromNib()
		self.emailField?.delegate = self
		self.passwordField?.delegate = self
		self.buttonLogin?.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
    }
	
	@objc public func didTapLogin() {
		self.onTapLogin?()
	}
	
	public func configure(_ credentials: LoginCredentialsModel, path: IndexPath) {
        self.credentials = credentials
		self.emailField?.text = credentials.email
		self.passwordField?.text = credentials.password
	}
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let value = (((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string) as String)
		if textField == self.emailField {
			self.credentials?.email = value
		} else if textField == self.passwordField {
			self.credentials?.password = value
		}
        return true
    }
}

public class CellRecoverCredentials: UITableViewCell, DeclarativeCell, UITextFieldDelegate {
	public typealias T = Void

	@IBOutlet public var buttonRecover: UIButton?
	@IBOutlet public var emailField: UITextField?

	public var onTapRecover: ((String) -> (Void))? = nil
	
	public func configure(_: Void, path: IndexPath) {
		self.emailField?.delegate = self
	}
	
	public override func awakeFromNib() {
		super.awakeFromNib()
		self.buttonRecover?.addTarget(self, action: #selector(didTapRecover), for: .touchUpInside)
	}
	
	@objc public func didTapRecover() {
		self.onTapRecover?(self.emailField?.text ?? "")
	}
	
}

public class CellProfile: UITableViewCell, DeclarativeCell {
	public typealias T = UserProfile
	
	public static var defaultHeight: CGFloat? = 100.0

	@IBOutlet public var avatarImage: UIImageView?
	@IBOutlet public var fullNameLabel: UILabel?
	@IBOutlet public var moodLabel: UILabel?
	@IBOutlet public var tapToToggleLabel: UILabel?

	public func configure(_: UserProfile, path: IndexPath) {
		
	}
}

public class CellAttribute: UITableViewCell, DeclarativeCell {
	public typealias T = UserProfileAttribute
	
	@IBOutlet public var attributeKeyLabel: UILabel?
	@IBOutlet public var attributeValueLabel: UILabel?
	
	public func configure(_: UserProfileAttribute, path: IndexPath) {
		
	}
}

public class CellFriend: UITableViewCell, DeclarativeCell {
	public typealias T = FriendUser
	
	@IBOutlet public var fullNameLabel: UILabel?
	@IBOutlet public var avatarImage: UIImageView?
	
	public private(set) var friend: FriendUser?
	
	public func configure(_ friend: FriendUser, path: IndexPath) {
		self.friend = friend
		self.fullNameLabel?.text = "\(friend.firstName) \(friend.lastName)"
		self.avatarImage?.image = friend.avatar
	}
}

public class CellLoader: UITableViewCell, DeclarativeCell {
    
    public typealias T = String
    
    @IBOutlet public var container: UIView?
    @IBOutlet public var messageLabel: UILabel?
    private var spinnerView = JTMaterialSpinner()

    public override func awakeFromNib() {
        super.awakeFromNib()
        spinnerView.circleLayer.lineWidth = 2.0
        spinnerView.circleLayer.strokeColor = UIColor(red:0.97, green:0.15, blue:0.46, alpha:1.0).cgColor
        spinnerView.animationDuration = 2.5
    }
    
    public func configure(_ text: String, path: IndexPath) {
        self.messageLabel?.text = "Login as \(text)..."
        spinnerView.frame = self.container!.bounds
        self.container?.addSubview(spinnerView)
        spinnerView.beginRefreshing()
    }
}
