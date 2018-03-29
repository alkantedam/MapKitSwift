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
        
        let blur = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = self.view.bounds
        table.backgroundView = blurView
        return table
    }()
    
    
    private var places: [MKPointAnnotation] = []
    
    func setNavigationBar() {
        let sbHeight = UIApplication.shared.statusBarFrame.height
        let screenSize: CGRect = UIScreen.main.bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: sbHeight, width: screenSize.width, height: 80))
        let navItem = UINavigationItem(title: "Map")
        let locationsItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.organize, target: nil, action: #selector(tableViewContent(_:)))
        navItem.rightBarButtonItem = locationsItem
        navBar.setItems([navItem], animated: false)
        self.view.addSubview(navBar)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let longPressed = UILongPressGestureRecognizer(target: self, action: #selector(setLocation(_:)))
        
        segment.addTarget(nil, action: #selector(segmentStyle(_:)), for: .valueChanged)
        
        view.isUserInteractionEnabled = true
        view.addSubview(myMap)
        view.addSubview(tableView)
        view.addSubview(viewBlurred)
        view.addSubview(segment)
        view.addGestureRecognizer(longPressed)
        
        self.setNavigationBar()
        setupConstraints()
        
        
    }
    
    func setupConstraints() -> Void {
        constrain(myMap,tableView,segment,viewBlurred){ map,table,segment,viewblurred in
            map.width == view.bounds.width
            map.height == view.bounds.height
            map.top == (map.superview?.top)!
            
            table.height == map.height
            table.width == map.width
            table.top == map.top+54
            
            viewblurred.width == map.width
            viewblurred.height == map.height/10
            viewblurred.bottom == map.bottom
            
            segment.width == self.view.bounds.width/1.5
            segment.height == self.view.bounds.width/12
            segment.center == viewblurred.center
            
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

}

