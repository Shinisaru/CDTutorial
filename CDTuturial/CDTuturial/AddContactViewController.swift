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
    
    var contextToUse: NSManagedObjectContext?
    var personToEdit: Person?

    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Save, target: self, action: "saveChanges")
        
        if nil == personToEdit {
            title = "Add New Contact"
            navigationItem.rightBarButtonItem?.enabled = false
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelEditing")
        } else {
            title = "Edit Contact"
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if nil == contextToUse {
            contextToUse = CoreDataStack.sharedInstance.createChildContext()
        }
        
        if let person = personToEdit {
            firstNameInput.text = person.firstName
            lastNameInput.text = person.lastName
        }
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
        
        let person: Person

        if nil != personToEdit {
            person = personToEdit!
        } else {
            person = NSEntityDescription
                .insertNewObjectForEntityForName("Person",
                inManagedObjectContext: contextToUse!) as! Person
        }
        
        person.firstName = firstNameInput.text
        person.lastName = lastNameInput.text
        
        firstNameInput.enabled = false
        lastNameInput.enabled = false
        
        navigationItem.leftBarButtonItem?.enabled = false
        navigationItem.rightBarButtonItem?.enabled = false
        
        CoreDataStack.sharedInstance.saveContextAndPropagateChanges(contextToUse!) {[weak self] error in
            print("ssaved person, persisted with error: \(error)")
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
            let message: String
            if nil == personToEdit {
                firstNameInput.text = ""
                lastNameInput.text = ""
                message = "Contact added!"
            } else {
                message = "Contact changed!"
            }
            
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .Alert)
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
