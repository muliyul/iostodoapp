//
//  TodoListTableViewController.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class TodoListTableViewController: UITableViewController {
    let tasks = TaskManager.sharedInstance().tasks
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsMultipleSelectionDuringEditing = false
        tasks.bindTo(tableView) { (indexPath, tasks, tableView) in
            let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell") as! TaskCell
            let task = tasks[indexPath.row]
            cell.titleLbl.text = task.name
            cell.descLbl.text = task.desc
            let dateformatter = NSDateFormatter()
            dateformatter.dateStyle = NSDateFormatterStyle.ShortStyle
            dateformatter.timeStyle = NSDateFormatterStyle.ShortStyle
            let dateStr = dateformatter.stringFromDate(NSDate(timeIntervalSince1970: task.date))
            cell.dateLbl.text = dateStr
            cell.backgroundColor = task.done ? UIColor.greenColor() : UIColor.clearColor()
            return cell

        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let editVC = storyboard!.instantiateViewControllerWithIdentifier("edit") as! TodoDetailViewController
        editVC.todo = tasks[indexPath.row]
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            TaskManager.sharedInstance().tasks.removeAtIndex(indexPath.row)
        }
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let task = self.tasks[indexPath.row]
        var actions: [UITableViewRowAction] = []
        let done = UITableViewRowAction(style: .Normal, title: "Done") {
            action, index in
            task.markDone()
        }
        
        let undone = UITableViewRowAction(style: .Normal, title: "Undone") {
            action, index in
            task.done = false
            if NSDate().timeIntervalSince1970 < task.date {
                task.setupNotification()
            }
            task.update()
        }
        
        let delete = UITableViewRowAction(style: .Default, title: "Delete") {
            action, index in
            task.remove()
        }
        
        actions.append(delete)
        if task.done {
            actions.append(undone)
        } else {
            actions.append(done)
        }
        
        return actions
    }
}
