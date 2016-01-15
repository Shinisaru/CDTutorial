//
//  AddContactViewController.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//

import UIKit
import CoreData

class AddContactViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add New Contact"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveChanges")
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
        
        navigationItem.rightBarButtonItem?.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        firstNameInput.becomeFirstResponder()
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if firstNameInput.text?.characters.count >= 3 &&
            lastNameInput.text?.characters.count >= 3 {
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
        return true
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == firstNameInput {
            lastNameInput.becomeFirstResponder()
        } else {
            saveChanges()
        }
        return true
    }
    
    func saveChanges() {
        firstNameInput.resignFirstResponder()
        lastNameInput.resignFirstResponder()
        
        let context = CoreDataStack.sharedInstance.createChildContext()
        
        let newContact: Person = NSEntityDescription
            .insertNewObjectForEntityForName("Person",
                inManagedObjectContext: context) as! Person
        
        newContact.firstName = firstNameInput.text
        newContact.lastName = lastNameInput.text
        
        firstNameInput.enabled = false
        lastNameInput.enabled = false
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        
        CoreDataStack.sharedInstance.saveContextAndPropagateChanges(context) {[weak self] error in
            print("provideHotspotsWithCoordinate persisted error: \(error)")
            dispatch_async(dispatch_get_main_queue()) {
                self?.handleErrorOrSucces(error)
            }
        }
    }
    
    private func handleErrorOrSucces(error: NSError?) {
        firstNameInput.enabled = true
        lastNameInput.enabled = true
        navigationItem.leftBarButtonItem?.enabled = true
        
        let defaultAction = UIAlertAction(title: "Ok", style: .Default) {[weak self] _ -> Void in
            self?.firstNameInput.becomeFirstResponder()
        }
        
        guard let error = error else {
            firstNameInput.text = ""
            lastNameInput.text = ""
            
            let alert = UIAlertController(title: "Success", message: "Contact added!", preferredStyle: .Alert)
            alert.addAction(defaultAction)
            presentViewController(alert, animated: true, completion:  nil)
            return
        }
        
        navigationItem.rightBarButtonItem?.enabled = true
        
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion:  nil)
    }
    
    func cancelEditing() {
        firstNameInput.resignFirstResponder()
        lastNameInput.resignFirstResponder()
        firstNameInput.text = ""
        lastNameInput.text = ""
    }
    
}
