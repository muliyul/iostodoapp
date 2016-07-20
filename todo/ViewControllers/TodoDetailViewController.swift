//
//  AddTodoViewController.swift
//  todo
//
//  Created by Muli Yulzary on 16/07/2016.
//  Copyright © 2016 Muli Yulzary. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import ReactiveKit
import ReactiveUIKit

class TodoDetailViewController: UITableViewController, UITextViewDelegate,
                            CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate {
    @IBOutlet weak var pageTitleLbl: UINavigationItem!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var descTF: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var gmap: GMSMapView!
    var todo: Todo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        todo?.rName.map({ name in
            if name == "" {
                return "Add Task"
            }
            return name
        }).bindTo(pageTitleLbl.rTitle)
        
        todo?.rName.bindTo(nameTF.rText)
        todo?.rDesc.bindTo(descTF.rText)
        
        todo?.rDate.map({ (timeStamp) -> NSDate in
            return NSDate(timeIntervalSince1970: timeStamp)
        }).bindTo(datePicker.rDate)
        
        if todo?.location.count >= 2 {
            if let latitude = todo?.location[0], let longitude = todo?.location[1] {
                let coords =  CLLocationCoordinate2D(latitude: latitude,longitude: longitude)
                gmap.camera = GMSCameraPosition.cameraWithTarget(coords, zoom: 17)
                let marker = GMSMarker(position: coords)
                marker.map = gmap
                reverseGeocodeCoordinate(coords)
            }
        }
        
        datePicker.minimumDate = NSDate()
        descTF.delegate = self
        gmap.myLocationEnabled = true
        let lm = CLLocationManager()
        lm.delegate = self
        lm.requestLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        gmap.myLocationEnabled = (status == .AuthorizedAlways)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        debugPrint(error.localizedDescription)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        if todo?.desc == "" {
            textView.text = ""
        }
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        gmap.clear()
        let address = place.formattedAddress
        locationTF.text = address
        let marker = GMSMarker(position: place.coordinate)
        gmap.camera = GMSCameraPosition.cameraWithTarget(place.coordinate, zoom: 17)
        marker.map = gmap
        let coord = place.coordinate
        todo?.location = [coord.latitude, coord.longitude]
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        locationTF.text = nil
        gmap.clear()
        debugPrint(error.localizedDescription)
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didSelectPrediction prediction: GMSAutocompletePrediction) -> Bool {
        return true
    }
    
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        locationTF.text = nil
        gmap.clear()
        viewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] response, error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                self?.locationTF.text = lines.joinWithSeparator(", ") 
            }
        }
    }
    
    
    @IBAction func autocompleteTapped(sender: UITextField) {
        let acVC = GMSAutocompleteViewController()
        acVC.delegate = self
        presentViewController(acVC, animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(sender: UIBarButtonItem) {
        let tm = TaskManager.sharedInstance()
        if let todo = todo {
            todo.name = nameTF.text!
            todo.desc = descTF.text
            todo.date = datePicker.date.timeIntervalSince1970
            todo.update()
        } else {
            tm.tasks.append(Todo(name: nameTF.text!, desc: descTF.text, date: datePicker.date))
        }
        navigationController?.popViewControllerAnimated(true)
    }

}
