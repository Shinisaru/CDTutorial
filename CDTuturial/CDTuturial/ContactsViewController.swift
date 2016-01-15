//
//  ContactsViewControllerTableViewController.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//

import UIKit
import CoreData

class ContactsViewController: UITableViewController {
    
    private var contacts:[AnyObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        reloadContacts()
    }
    
    private func reloadContacts() {
        let request = NSFetchRequest(entityName: "Person")
        request.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        
        do {
            contacts = try CoreDataStack.sharedInstance.mainContext.executeFetchRequest(request)
            tableView.reloadData()
        } catch let error as NSError {
            let alert = UIAlertController(title: "Error fetching objects", message: error.localizedDescription, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
            contacts.removeAll()
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonCell", forIndexPath: indexPath)

        let person = contacts[indexPath.row] as! Person
        
        cell.textLabel?.text = person.lastName
        cell.detailTextLabel?.text = person.firstName
        
        cell.accessoryType = .DisclosureIndicator

        return cell
    }
    
    private var cachedPerson: Person!
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        cachedPerson = contacts[indexPath.row] as! Person
        performSegueWithIdentifier("EditPerson", sender: self)
    }

   
    // Override to support editing the table view.
    override func tableView(
        tableView: UITableView,
        commitEditingStyle editingStyle: UITableViewCellEditingStyle,
        forRowAtIndexPath indexPath: NSIndexPath)
    {
        if editingStyle == .Delete {
            let person = contacts[indexPath.row] as! Person
            
            let context = CoreDataStack.sharedInstance.createChildContext()
            let personInContext = context.objectWithID(person.objectID) as! Person
            context.deleteObject(personInContext)
            
            CoreDataStack.sharedInstance.saveContextAndPropagateChanges(context) {[weak self] error in
                print("deleted person, persisted with error: \(error)")
                self?.handleDeletionError(error)
            }
            
            contacts.removeAtIndex(indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            tableView.endUpdates()
        }
    }
   
    private func handleDeletionError(error: NSError?) {
        guard let error = error else {
            return
        }
        
        let alert = UIAlertController(title: "Error deleting object", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
        
        reloadContacts()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditPerson" {
            let destignation = segue.destinationViewController as! AddContactViewController
            destignation.contextToUse = CoreDataStack.sharedInstance.createChildContext()
            destignation.personToEdit = destignation.contextToUse!.objectWithID(cachedPerson.objectID) as? Person
        }
    }
    

}
