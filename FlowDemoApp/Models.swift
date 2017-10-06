//
//  Models.swift
//  Flow-iOS
//
//  Created by dan on 28/09/2017.
//  Copyright © 2017 Flow. All rights reserved.
//

import Foundation
import UIKit

public class LoginCredentialModel {
    var email: String = ""
    var password: String = ""
}

public enum LoginCredentialType {
    case email(_: LoginCredentialModel  )
    case password(_: LoginCredentialModel)
    
    public var placeholder: String {
        switch self {
        case .email(_): return "Your Email"
        case .password(_): return "Your Password"
        }
    }
    
    public var value: String {
        switch self {
        case .email(let credential): return credential.email
        case .password(let credential): return credential.password
        }
    }
    
    public func setValue(_ value: String) {
        switch self {
        case .email(let credential): credential.email = value
        case .password(let credential): credential.password = value
        }
    }
}

public protocol AttributeProtocol {
	var label: String { get set }
	var value: String { get set }
}

public struct UserProfile {
	var firstName: String
	var lastName: String
	var mood: String
}

public protocol ActionableContent {
	var onAction: (() -> (Void))? { get set }
	var title: String { get set }
}

public struct FriendUser {
	var firstName: String
	var lastName: String
	var avatar: UIImage
}

