//
//  TaskManager.swift
//  todo
//
//  Created by Muli Yulzary on 19/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import ReactiveKit
import ReactiveUIKit
import SQLite

class TaskManager {
    private static let _sharedInstance = TaskManager()
    private var sqlListener: Disposable?
    private var firebaseListener: Disposable?
    var tasks = CollectionProperty<[Todo]>([Todo]())
    
    static func sharedInstance() -> TaskManager {
        return _sharedInstance
    }
    
    private init(){
        FIRAuth.auth()?.addAuthStateDidChangeListener({ (auth, user) -> Void in
            if let user = user {
                debugPrint("User \(user.email!) state changed")
            }
        })
    }
    
    func syncWithFirebase(){
        guard let userid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        sqlListener?.dispose()
        let ref = FIRDatabase.database().reference()
            .child("users")
            .child(userid)
            .child("tasks")
        
        ref.observeEventType(.Value, withBlock: { [weak self] (snapshot) -> Void in
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                self?.tasks.replace([], performDiff: true)
                for snapshot in snapshots {
                    self?.tasks.append(Todo(snapshot: snapshot))
                }
            }
        })
        
        firebaseListener = tasks.observeNext({ e in
            let inserts = e.inserts
            
            //Write changes to Firebase
            for idx in inserts {
                let currentTask = self.tasks[idx]
                
                guard let taskRef = currentTask.fbRef else {
                    ref.childByAutoId().setValue(currentTask.asDictionary)
                    return
                }
                
                taskRef.setValue(currentTask.asDictionary)
            }
        })
    }
    
    func updateTask(todo: Todo) {
        if let fbRef =  todo.fbRef {
            fbRef.setValue(todo.asDictionary)
        } else {
            //Update SQL entry
        }
    }
    
    func syncWithSQLite(){
        firebaseListener?.dispose()
        let path = NSSearchPathForDirectoriesInDomains(
            .DocumentDirectory, .UserDomainMask, true
            ).first!
        let db = try! Connection("\(path)/db.sqlite3")
        let taskTbl = Table("tasks")
        let id = Expression<Int64>("id")
        let name = Expression<String>("name")
        let desc = Expression<String?>("desc")
        let date = Expression<Double>("date")
        let location = Expression<String?>("location") //String containing array in JSON format
        
        try! db.run(taskTbl.create { t in
            t.column(id, primaryKey: true)
            t.column(name)
            t.column(desc)
            t.column(date)
            t.column(location)
        })
        
        //Read data
        for row in try! db.prepare(taskTbl) {
            tasks.append(Todo(sqlRow: row))
        }
        
        //Update database on changes
        sqlListener = tasks.observeNext { e in
            let inserts = e.inserts
            let updates = e.updates
            let deletes = e.deletes
            //Write changes to database
            
            for idx in inserts {
                let currentTask = self.tasks[idx]
                var locationStr: String? = nil
                let taskLoc = currentTask.location
                if taskLoc.count >= 2 {
                    locationStr = "[\(taskLoc[0]),\(taskLoc[1])]"
                }
                let insert = taskTbl.insert(name <- currentTask.name, desc <- currentTask.desc, date <- currentTask.date, location <- locationStr)
                try! db.run(insert)
            }
            
            for idx in updates {
                let currentTask = self.tasks[idx]
                var locationStr: String? = nil
                let taskLoc = currentTask.location
                if taskLoc.count >= 2 {
                    locationStr = "[\(taskLoc[0]),\(taskLoc[1])]"
                }
                let update = taskTbl.update(name <- currentTask.name, desc <- currentTask.desc, date <- currentTask.date, location <- locationStr)
                try! db.run(update)
            }
            
            for _ in deletes {
                let currentTask = taskTbl.filter(id == rowid)
                try! db.run(currentTask.delete())
            }
            
        }

    }
}
