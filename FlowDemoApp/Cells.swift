//
//  Cells.swift
//  Flow-iOS
//
//  Created by dan on 28/09/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit
import Flow

public class CellLogo: UITableViewCell, DeclarativeCell {
	
	public func configure(_: Void, path: IndexPath) {
		
	}
	
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.removeMargins()
    }
    
	public typealias T = Void
	
}

public class CellAutosizeText: UITableViewCell, DeclarativeCell {
	public typealias T = String
	
	@IBOutlet public var contentLabel: UILabel?
	
	public func configure(_ text: String, path: IndexPath) {
		self.contentLabel?.text = text
	}
	
}

public class CellLoginCredential: UITableViewCell, DeclarativeCell, UITextFieldDelegate {
	public typealias T = LoginCredentialType
    
	@IBOutlet public var textField: UITextField?
    
    private var credentials: LoginCredentialType?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.textField?.delegate = self
    }
	
	public func configure(_ item: LoginCredentialType, path: IndexPath) {
        self.credentials = item
		self.textField?.placeholder = self.credentials?.placeholder
        self.textField?.text = self.credentials?.value
	}
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string) as String)
        self.credentials?.setValue(str)
        return true
    }
}

public class CellButton: UITableViewCell, DeclarativeCell {
	public typealias T = String
	
	@IBOutlet public var button: UIButton?
    
    public var onTap: (()->(Void))? = nil
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.button?.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
	
	public func configure(_ title: String, path: IndexPath) {
		self.button?.setTitle(title, for: .normal)
	}
    
    @IBAction func didTapButton() {
        self.onTap?()
    }
	
}

public class CellForgotCredentials: UITableViewCell, DeclarativeCell {
	
	public typealias T = String
	
	@IBOutlet public var messageTitle: UILabel?
	@IBOutlet public var messageSubtitle: UILabel?
	
	public func configure(_: String, path: IndexPath) {
		
	}
}

public class CellProfile: UITableViewCell, DeclarativeCell {
	public typealias T = UserProfile
	
	@IBOutlet public var avatarImage: UIImageView?
	@IBOutlet public var fullNameLabel: UILabel?
	@IBOutlet public var moodLabel: UILabel?
	
	public func configure(_: UserProfile, path: IndexPath) {
		
	}
}

public class CellAttribute: UITableViewCell, DeclarativeCell {
	public typealias T = AttributeProtocol
	
	@IBOutlet public var attributeKeyLabel: UILabel?
	@IBOutlet public var attributeValueLabel: UILabel?
	
	public func configure(_: AttributeProtocol, path: IndexPath) {
		
	}
}

public class CellFriend: UITableViewCell, DeclarativeCell {
	public typealias T = FriendUser
	
	@IBOutlet public var fullNameLabel: UILabel?
	@IBOutlet public var avatarImage: UIImageView?
	
	public func configure(_: FriendUser, path: IndexPath) {
		
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
