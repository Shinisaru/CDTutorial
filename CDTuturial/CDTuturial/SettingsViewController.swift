//
//  SettingsViewController.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    private var selectedColor: String = "white"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let storedColor = NSUserDefaults.standardUserDefaults().stringForKey("StoredBackgroundColor") {
            selectedColor = storedColor
        } else {
            NSUserDefaults.standardUserDefaults().setValue("white", forKey: "StoredBackgroundColor")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        view.backgroundColor = colorByName(selectedColor)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    private func colorByName(colorName: String) -> UIColor {
        if colorName == "white" {
            return UIColor.whiteColor()
        } else if colorName == "yellow" {
            return UIColor.yellowColor()
        } else if colorName == "red" {
            return UIColor.redColor()
        } else if colorName == "gray" {
            return UIColor.lightGrayColor()
        }  else {
            return UIColor.orangeColor()
        }
    }
    
    private func colorTupleForIndexPath(indexPath: NSIndexPath) -> (String, UIColor) {
        switch (indexPath.row) {
        case 0:
            return ("white", colorByName("white"))
        case 1:
            return ("gray", colorByName("gray"))
        case 2:
            return ("yellow", colorByName("yellow"))
        case 3:
            return ("orange", colorByName("orange"))
        default:
            return ("red", colorByName("red"))
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        let (name, color) = colorTupleForIndexPath(indexPath)
        
        
        cell.textLabel?.text = name.capitalizedString
        cell.backgroundColor = color
        
        if selectedColor == color {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        let (name, color) = colorTupleForIndexPath(indexPath)
        
        selectedColor = name
        tableView.reloadData()
        view.backgroundColor = color
        
        NSUserDefaults.standardUserDefaults().setValue(name, forKey: "StoredBackgroundColor")
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}
