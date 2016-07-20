//
//  Todo.swift
//  todo
//
//  Created by Muli Yulzary on 17/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import ReactiveKit
import SQLite

class Todo : NSObject{
    static let path = NSSearchPathForDirectoriesInDomains(
        .DocumentDirectory, .UserDomainMask, true
        ).first!
    private static var db = try? Connection("\(path)/db.sqlite3")
    private static var table: Table {
        let taskTbl = Table("tasks")
        
        try! db?.run(taskTbl.create { t in
            t.column(Todo.idCol, primaryKey: true)
            t.column(Todo.nameCol)
            t.column(Todo.descCol)
            t.column(Todo.dateCol)
            t.column(Todo.locationCol)
            t.column(Todo.doneCol)
        })
        
        return taskTbl
    }
    private static let idCol = Expression<Int64>("id")
    private static let nameCol = Expression<String>("name")
    private static let descCol = Expression<String?>("desc")
    private static let dateCol = Expression<Double>("date")
    private static let doneCol = Expression<Bool>("done")
    private static let locationCol = Expression<String?>("location") //String containing array in JSON format
    
    var fbRef: FIRDatabaseReference?
    var sqlId: Int64?
    var name: String
    var desc = ""
    var date: Double
    var location: [Double] = []
    var done: Bool = false
    
    var asDictionary: NSDictionary {
        let dict = [
            "name" : name,
            "desc" : desc,
            "date" : date,
            "location": location,
            "done": done
        ]
        return dict
    }
    
    var rName: Property<String> {
        return Property(name)
    }
    var rDesc: Property<String> {
        return Property(desc)
    }
    var rDate: Property<Double> {
        return Property(date)
    }
    var rLocation: CollectionProperty<Array<Double>> {
        return CollectionProperty(location)
    }
    var rDone: Property<Bool> {
        return Property(done)
    }

    init(name: String, desc: String? = nil, date: Double, location: [Double]? = nil){
        self.name = name
        self.desc = desc ?? ""
        self.date = date
        guard let location = location else {
            return
        }
        self.location = location
    }
    
    convenience init(sqlId: Int64, name: String, desc: String? = nil, date: Double, location: [Double]? = nil){
        self.init(name: name, desc: desc, date: date, location: location)
        self.sqlId = sqlId
    }
    
    convenience init(name: String, desc: String? = nil, date: NSDate, location: CLLocationCoordinate2D? = nil){
        var serLoc: [Double]? = nil
        if let location = location {
            serLoc = [location.latitude, location.longitude]
        }
        self.init(name: name, desc: desc, date: date.timeIntervalSince1970, location: serLoc)
    }
    
    convenience init(snapshot: FIRDataSnapshot){
        let dict = snapshot.value as! [String: AnyObject]
        let location = dict["location"] as? [Double]
        self.init(name: dict["name"] as! String, desc: dict["desc"] as? String, date: dict["date"] as! Double, location: location)
        self.done = dict["done"] as? Bool ?? false
        self.fbRef = snapshot.ref
    }
    
    convenience override init(){
        self.init(name: "", date: NSDate())
    }
    
    convenience init(sqlRow: Row){
        let idCol = Expression<Int64>("id")
        let nameCol = Expression<String>("name")
        let descCol = Expression<String?>("desc")
        let dateCol = Expression<Double>("date")
        let locationCol = Expression<String?>("location") //String containing array in JSON format
        
        let id = sqlRow.get(idCol)
        let name = sqlRow.get(nameCol)
        let desc = sqlRow.get(descCol)
        let date = sqlRow.get(dateCol)
        let locationStr = sqlRow.get(locationCol)
        var location: [Double]? = nil
        if let data = locationStr!.dataUsingEncoding(NSUTF8StringEncoding) {
            let parsed = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments);
            if let parsed = parsed {
                location = parsed as? [Double]
            }
        }
        self.init(sqlId: id, name: name, desc: desc, date: date, location: location)
    }
    
    func update(completion: ((NSError?, Todo)->())? = nil) {
        setupNotification()
        if let ref = fbRef {
            //Update firebase ref
            ref.setValue(asDictionary) { e, snapshot in
                completion?(e, self)
            }
        } else {
            //Save in SQL
            var locationStr: String? = nil
            let taskLoc = location
            if taskLoc.count >= 2 {
                locationStr = "[\(taskLoc[0]),\(taskLoc[1])]"
            }
            
            if let id = sqlId {
                let update = Todo.table.update(Todo.idCol <- id, Todo.nameCol <- name, Todo.descCol <- desc, Todo.locationCol <- locationStr, Todo.doneCol <- done)
                try! Todo.db!.run(update)
            }
            completion?(nil, self)
        }
    }
    
    func remove(completion: (NSError?->())? = nil) {
        if let ref = fbRef {
            ref.setValue(nil) { e, snapshot in
                completion?(e)
            }
        } else {
            guard let id = sqlId else {
                return
            }
            let taskRow = Todo.table.filter(id == rowid)
            try! Todo.db?.run(taskRow.delete())
            completion?(nil)
        }
    }
    
    func markDone() {
        removeOldNotification()
        done = true
        update()
    }
    
    func setupNotification() {
        removeOldNotification()
        
        let notification = UILocalNotification()
        notification.alertBody = "\(name) Is Overdue" // text that will be displayed in the notification
        notification.alertAction = "open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = NSDate(timeIntervalSince1970: date) // todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["id": fbRef?.key ?? String(sqlId),"title": name, "desc": desc] // assign a unique identifier to the notification
    }
    
    func removeOldNotification() {
        if let oldNotification = findNotification() {
            UIApplication.sharedApplication().cancelLocalNotification(oldNotification)
        }
    }
    
    private func findNotification() -> UILocalNotification? {
        guard let notifications = UIApplication.sharedApplication().scheduledLocalNotifications else {return nil}
        for notification in notifications {
            var id: String? = nil
            if let fbRef = fbRef {
                id = fbRef.key
            } else {
                id = String(sqlId)
            }
            
            if notification.userInfo?["id"] as? String == id {
                return notification
            }
        }
        return nil
    }
}
