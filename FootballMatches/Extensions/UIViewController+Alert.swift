//
//  UIViewController+Alert.swift
//  FootballMatches
//
//  Created by Hai Pham on 05/03/2023.
//

import UIKit

extension UIViewController {
    
    // MARK: - Alert Style
    /**
     Present a title-only alert controller and an OK button to dissmiss the alert.
     - parameter title: The title of the alert.
     */
    @discardableResult func showAlertWithTitle(_ title: String?) -> UIAlertController {
        return showAlert(title, message: nil, cancelButtonTitle: "OK")
    }
    
    /**
     Present a message-only alert controller and an OK button to dissmiss the alert.
     - parameter message: The message content of the alert.
     */
    @discardableResult func showAlertWithMessage(_ message: String?) -> UIAlertController {
        return showAlert("", message: message, cancelButtonTitle: "OK")
    }
    
    /**
     Present an alert controller with a title, a message and an OK button. Tap the OK button will dissmiss the alert.
     - parameter title: The title of the alert.
     - parameter message: The message content of the alert.
     */
    @discardableResult func showAlert(title: String?,
                                      message: String?) -> UIAlertController {
        return showAlert(title,
                         message: message,
                         cancelButtonTitle: "OK")
    }
    
    /**
     Present an alert controller with a title, a message and a cancel/dismiss button with a title of your choice.
     - parameter title: The title of the alert.
     - parameter message: The message content of the alert.
     - parameter cancelButtonTitle: Title of the cancel button of the alert.
     */
    @discardableResult func showAlert(_ title: String?,
                                      message: String?,
                                      cancelButtonTitle: String) -> UIAlertController {
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: nil)
        return showAlert(title: title, message: message, alertActions: [cancelAction])
    }
    
    /**
     Present an alert controller with a title, a message and an array of handler actions.
     - parameter title: The title of the alert.
     - parameter message: The message content of the alert.
     - parameter alertActions: An array of alert action in UIAlertAction class.
     */
    @discardableResult func showAlert(title: String?,
                                      message: String?,
                                      alertActions: [UIAlertAction]) -> UIAlertController {
        return showAlert(title, message: message, preferredStyle: .alert, alertActions: alertActions)
    }
}
extension UIViewController {
    
    /// Show system alert with title, message, cancel button title.
    @discardableResult public func showAlert(title: String?,
                                             message: String?,
                                             cancelButtonTitle: String,
                                             cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelHandler)
        return showAlert(title: title, message: message, alertActions: [cancelAction])
    }
    
    /// Show system alert with title, message, cancel button title(preferredAction by default), other button title.
    @discardableResult public func showAlert(title: String?,
                                             message: String?,
                                             cancelButtonTitle: String,
                                             cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                                             otherButtonTitle: String,
                                             otherHandler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelHandler)
        let otherAction = UIAlertAction(title: otherButtonTitle, style: .default, handler: otherHandler)
        return showAlert(title: title, message: message, alertActions: [cancelAction, otherAction])
    }
    
    /// Show system alert with title, message, cancel button title, default button title(preferredAction).
    @discardableResult public func showAlert(title: String?,
                          message: String?,
                          cancelButtonTitle: String,
                          cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                          defaultButtonTitle: String,
                          defaultHandler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelHandler)
        let defaultAction = UIAlertAction(title: defaultButtonTitle, style: .default, handler: defaultHandler)
        return showAlert(title,
                         message: message,
                         preferredStyle: .alert,
                         alertActions: [cancelAction, defaultAction],
                         preferredAction: defaultAction)
    }
    
    /// Show system alert with title, message, cancel button title, destructive button title.
    @discardableResult public func showAlert(title: String?,
                                             message: String?,
                                             cancelButtonTitle: String,
                                             cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                                             destructiveButtonTitle: String,
                                             destructiveHandler: ((UIAlertAction) -> Swift.Void)? = nil) -> UIAlertController {
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelHandler)
        let destructiveAction = UIAlertAction(title: destructiveButtonTitle, style: .destructive, handler: destructiveHandler)
        return showAlert(title: title,
                         message: message,
                         alertActions: [cancelAction, destructiveAction])
    }
    
    /**
     Present an alert or action sheet with a title, a message and an array of handler actions.
     - parameter title: The title of the alert/action sheet.
     - parameter message: The message content of the alert/action sheet.
     - parameter alertActions: An array of alert action in UIAlertAction class.
     - parameter preferredAction: The preferred action for the user to take from an alert.
     */
    @discardableResult func showAlert(_ title: String?,
                                      message: String?,
                                      preferredStyle: UIAlertController.Style,
                                      alertActions: [UIAlertAction],
                                      preferredAction: UIAlertAction? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        for alertAction in alertActions {
            alertController.addAction(alertAction)
        }
        
        // Set preferred action if needed
        if let preferredAction = preferredAction {
            alertController.preferredAction = preferredAction
        }

        self.present(alertController, animated: true, completion: nil)
        return alertController
    }
}
