//
//  ViewController.swift
//  Map
//
//  Created by Alina on 3/29/18.
//  Copyright © 2018 a2b DesignLabs. All rights reserved.
//

import UIKit
import MapKit
import Cartography

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var checkTableView: Bool = true
    private var places: [MKPointAnnotation] = []
    let sbHeight = UIApplication.shared.statusBarFrame.height
    
    lazy var myMap:MKMapView = {
        return MKMapView.init()
    }()
    
    lazy var segment:UISegmentedControl = {
        let segment = UISegmentedControl.init()
        segment.insertSegment(withTitle: "Standart", at: 0, animated: true)
        segment.insertSegment(withTitle: "Satellite", at: 1, animated: true)
        segment.insertSegment(withTitle: "Hybrid", at: 2, animated: true)
        segment.selectedSegmentIndex = 0
        segment.tintColor = UIColor.black
        myMap.mapType = .standard
        segment.backgroundColor = UIColor(white: 1, alpha: 0)
        return segment
    }()
    
    lazy var forwardButton:UIButton = {
        let forButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        forButton.backgroundColor = UIColor.clear
        return forButton
        
    }()
    lazy var backwardButton:UIButton = {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        backButton.backgroundColor = UIColor.clear
        return backButton
        
    }()
    lazy var viewBlurred:UIVisualEffectView = {
        let viewblurred = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        //viewb.isUserInteractionEnabled = false
        return viewblurred
    }()
    
    lazy var tableView:UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        table.alpha = 0.0
        table.backgroundColor = UIColor.clear
        table.separatorStyle = .none
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        table.backgroundView = blurView
        return table
    }()
    

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar: UINavigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 44))
        self.view.addSubview(navBar);
        let navItem = UINavigationItem(title: "SomeTitle");
        let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.organize, target: nil, action: #selector(tableViewContent(_:)));
        navItem.rightBarButtonItem = doneItem;
        navBar.setItems([navItem], animated: false);
        
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(setLocation(_:)))
        
        segment.addTarget(nil, action: #selector(segmentStyle(_:)), for: .valueChanged)
        forwardButton.addTarget(nil, action: #selector(forward(_:)), for: .touchUpInside)
        backwardButton.addTarget(nil, action: #selector(backward(_:)), for: .touchUpInside)
        
        view.isUserInteractionEnabled = true
        view.addSubview(myMap)
        view.addSubview(tableView)
        view.addSubview(viewBlurred)
        view.addSubview(segment)
        view.addGestureRecognizer(longPressed)
        view.addSubview(navBar)
        view.addSubview(forwardButton)
        view.addSubview(backwardButton)
        
        setupConstraints()
        
        
    }
    
    func setupConstraints() -> Void {
        constrain(myMap,tableView,segment,viewBlurred, forwardButton, backwardButton){ map,table,segment,viewblurred, forBtn, backBtn in
            map.width == view.bounds.width
            map.height == view.bounds.height
            map.top == (map.superview?.top)!
            
            table.height == map.height
            table.width == map.width
            table.top == map.top + sbHeight
            
            viewblurred.width == map.width
            viewblurred.height == map.height/10
            viewblurred.bottom == map.bottom
            
            segment.width == self.view.bounds.width/1.5
            segment.height == self.view.bounds.width/12
            segment.center == viewblurred.center
            
            forBtn.width == 50
            forBtn.height == segment.height
            forBtn.right == (map.superview?.right)!
            forBtn.bottom == map.bottom
            
            backBtn.width == 50
            backBtn.height == segment.height
            backBtn.left == (map.superview?.left)!
            backBtn.bottom == map.bottom
            
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = places[indexPath.row].title
        cell.detailTextLabel?.text = places[indexPath.row].subtitle
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentPlace = places[indexPath.row]
        myMap.setRegion(MKCoordinateRegionMakeWithDistance(currentPlace.coordinate, 1000, 1000), animated: true)
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.tableView.alpha = 0.0
        })
        tableView.deselectRow(at: indexPath, animated: true)
        navigationItem.title = currentPlace.title
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleted")
            self.myMap.removeAnnotation(places[indexPath.row])
            self.places.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            
    }
    }
    
    @objc func segmentStyle(_ segmentControl: UISegmentedControl){
        if segmentControl.selectedSegmentIndex == 0{
            segmentControl.tintColor = UIColor.black
            myMap.mapType = .standard
        }
        else if segmentControl.selectedSegmentIndex == 1{
            segmentControl.tintColor = UIColor.white
            myMap.mapType = .satellite
        }
        else if segmentControl.selectedSegmentIndex == 2{
            segmentControl.tintColor = UIColor.white
            myMap.mapType = .hybrid
        }
    }
    
    @objc func setLocation(_ sender: UILongPressGestureRecognizer){
        
        let location = sender.location(in: myMap)
        let coordinate = myMap.convert(location, toCoordinateFrom: myMap)
        
        //1. Create the alert controller.
        let alert = UIAlertController(title: "Add Place", message: "Fill all the fields", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Subtitle"
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            let title = alert?.textFields![0].text
            let subtitle = alert?.textFields![1].text
            
            let annotation = MKPointAnnotation()
            
            annotation.title = title
            annotation.subtitle = subtitle
            annotation.coordinate = coordinate
            self.myMap.addAnnotation(annotation)
            self.myMap.setRegion(MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000), animated: true)
            self.places.append(annotation)
            self.tableView.reloadData()
            self.navigationItem.title = title
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func tableViewContent(_ sender: UIBarButtonItem){
        if checkTableView{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tableView.alpha = 1.0
            })
            //tableView.alpha = 1.0
            checkTableView = false
        }
        else{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.tableView.alpha = 0.0
            })
            checkTableView = true
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    var currentPin = 0
    @objc func forward(_ sender: UIButton){
        print(currentPin)
        currentPin += 1
        if(currentPin >= places.count){
            currentPin = 0
        }
        self.myMap.setRegion(MKCoordinateRegionMakeWithDistance(places[currentPin].coordinate, 1000, 1000), animated: true)
        print("Forward clicked")
    }
    @objc func backward(_ sender: UIButton){
        print(currentPin)
        currentPin -= 1
        if(currentPin < 0){
            currentPin = places.count-1
        }
        self.myMap.setRegion(MKCoordinateRegionMakeWithDistance(places[currentPin].coordinate, 1000, 1000), animated: true)
        print("Backward clicked")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation)
        -> MKAnnotationView? {
            if annotation is MKUserLocation {
                
            }
            let reuseId = "pin"
            
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier:
                reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.animatesDrop = true
                let calloutButton = UIButton(type: .detailDisclosure)
                pinView!.rightCalloutAccessoryView = calloutButton
                pinView!.sizeToFit()
            }
            else {
                pinView!.annotation = annotation
            }
            
            return pinView
    }
}

