//
//  CoreDataStack+LocalInstance.swift
//  CDTuturial
//
//  Created by shinisaru on 15/01/16.
//  Copyright © 2016 Avast. All rights reserved.
//

import Foundation

private func getApplicationLibraryDirectory() -> NSURL {
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
}

extension CoreDataStack {
    static let sharedInstance = CoreDataStack(
        persistanceStoreURL: getApplicationLibraryDirectory().URLByAppendingPathComponent("CDTuturial.sqlite"),
        managedObjectModelURL: NSBundle.mainBundle().URLForResource("CDTuturial", withExtension: "momd")!)
    
    
}