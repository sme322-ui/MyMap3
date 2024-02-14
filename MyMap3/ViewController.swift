//
//  ViewController.swift
//  MyMap4
//
//  Created by Mongyan on 2023/4/27.
//
import CoreLocation
import UIKit
import MapKit
import WebKit
import AVFoundation
import CoreBluetooth
import CoreMotion
import GoogleSignIn
import nodejs_ios
import UserNotifications
import OpenAI
import SwiftUI
import OpenAISwift
class ViewController: UIViewController, CLLocationManagerDelegate,WKUIDelegate, MKMapViewDelegate,NSURLConnectionDataDelegate,UITableViewDataSource,AVSpeechSynthesizerDelegate, UITableViewDelegate, UNUserNotificationCenterDelegate,CBCentralManagerDelegate,CBPeripheralDelegate,BLEManagerDelegate{
    var userLocation: CLLocation?
    var currentRoute:MKRoute?
    let places = Places.getPlaces()
    var currentTransportType = MKDirectionsTransportType.automobile
    var routeSteps = [MKRoute.Step]()
    let channels = ["awesomeChannel"]
    let Station = [""]
    var restaurant:Restaurant!
    let myDataQueue = DispatchQueue(label: "DataQueue",
                                    qos: .userInitiated,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let content = UNMutableNotificationContent()
    func bleManagerDidConnect(_ manager: BLEManagable) {
        self.temperature.textColor = UIColor.blue
    }
    
    func bleManagerDidConnect(_ manager: BLEManagable,receivedDataString dataString: String) {
        self.temperature.textColor = UIColor.blue
        self.temperature.text = dataString+"℃"
    }
    
    func bleManagerDidDisconnect(_ manager: BLEManagable) {
        self.temperature.textColor = UIColor.red
        
    }
    
    func bleManager(_ manager: BLEManagable, receivedDataString dataString: String) {
        self.temperature.textColor = UIColor.blue
        self.temperature.text = dataString + "℃"
        temperature.font = UIFont(name:"Zapfino", size:20)
        print("temp:"+dataString + "℃")
    }
    
    @IBOutlet weak var temperature: UILabel!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for:indexPath)
        tableView.dataSource=self
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.imageView?.image = UIImage(named:"Americano")
        
        return cell
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
            //startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
            print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
            print("Error")
        }
    }
    var restaurantNames = ["teaha","CaffeLatte","Espresso","Americano"]
    var locationManager: CLLocationManager!
    var manager = CLLocationManager()
    @IBOutlet weak var myMapView: MKMapView!
    let newPin = MKPointAnnotation()
    var centralManager:CBCentralManager!
    public func getUserLocation(completion:@escaping ((CLLocation)-> Void)){
        
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    func startScanning() -> Void {
        // Start Scanning
        centralManager?.scanForPeripherals(withServices: [CBUUIDs.BLEService_UUID])
    }
    func determineMyCurrentLocation(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation],newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        print("定位到了")
        let newLocation = locations.last! as CLLocation
        print("current position: \(newLocation.coordinate.longitude) , \(newLocation.coordinate.latitude)")
        let message = "{\"lat\":\(newLocation.coordinate.latitude),\"lng\":\(newLocation.coordinate.longitude), \"alt\": \(newLocation.altitude)}"
        
    }
    private func mapView(mapView:MKMapView!,
                         renderForOverlay overlay:MKOverlay!)->MKOverlayRenderer!{
        let renderer = MKPolylineRenderer(overlay:overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer;
    }
    
    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let myLocation: CLLocation = locations[0] as CLLocation
        let myLatitude: String = String(format: "%f", myLocation.coordinate.latitude)
        let myLongitude: String = String(format:"%f", myLocation.coordinate.longitude)
        
        
        
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        newPin.coordinate = userLocation.coordinate
        myMapView.addAnnotation(newPin)
        //於當前位置加入標記->Thread
        myDataQueue.async(flags: .barrier) { [self] in
            var nSize = 10000
            while nSize > 1 {
                // loop body
                nSize = (nSize + 1) / 2
                DispatchQueue.main.async { [self] in
                    for index in 1...nSize {
                        
                        print("\(index)：\(index)")
                        myMapView.addAnnotation(newPin)
                        let myLocation: CLLocation = locations[0] as CLLocation
                        let myLatitude: String = String(format: "%f", myLocation.coordinate.latitude)
                        let myLongitude: String = String(format:"%f", myLocation.coordinate.longitude)
                        Timer.scheduledTimer(withTimeInterval: TimeInterval(0.5), repeats: true,block: {(timer:Timer)-> Void in
                            self.view.showToast(text: myLatitude+myLongitude)
                            
                        })
                        
                    }
                    
                    self.view.showToast(text: myLongitude)
                }
                
                myMapView.addAnnotation(self.newPin)
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            DispatchQueue.main.async { [self] in
                self.myMapView.addAnnotation(newPin)
        
            }
        }
        
        let request2 = MKLocalSearch.Request()
        request2.naturalLanguageQuery = "牧場"
        request2.region = myMapView.region
        let search = MKLocalSearch(request:request2)
        search.start{(response,error) in
            guard error == nil else{
                return
            }
            guard response != nil else{
                return
            }
            for item in (response?.mapItems)!{
                self.myMapView.addAnnotation(item.placemark)
                
            }
        }
    }
    
    func addAnnotations() {
        myMapView?.delegate = self
        myMapView?.addAnnotations(places)

        let overlays = places.map { MKCircle(center: $0.coordinate, radius: 100) }
        myMapView?.addOverlays(overlays)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        manager.delegate = self
               manager.requestWhenInUseAuthorization()
               manager.desiredAccuracy = kCLLocationAccuracyBest   //user位置追蹤精確程度，設置成最精確位置
               manager.activityType = .automotiveNavigation        //設定使用者的位置模式，手機會去依照不同設定做不同的電力控制
               manager.startUpdatingLocation()
        
       
                myMapView.showsUserLocation = true
                myMapView.delegate = self
                myMapView.mapType = .mutedStandard
                myMapView.isPitchEnabled = true
                myMapView.userTrackingMode = .follow//效果:不带方向的追踪,显示用户的位置,并且会跟随用户移动
                myMapView.showsUserLocation = true
                myMapView.userTrackingMode = .follow
                myMapView.isZoomEnabled = true
        let text = "雲端農業路徑送貨溫度感測系統"
               if let language = NSLinguisticTagger.dominantLanguage(for: text) {
                   let utterance = AVSpeechUtterance(string: text)
                   utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language
                   let synth = AVSpeechSynthesizer()
                   synth.speak(utterance)
               } else {
                   print("Unknown language")
               }
        addAnnotations()
        getDirections()
        getDirectionsl()
        if let path = Bundle.main.path(forResource: "stations", ofType: "plist"), var tempDict = NSDictionary(contentsOfFile: path) as? [String: String] {
              print("tempDict = \(tempDict)")
        }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.692055, longitude: 120.531663), addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.68805, longitude: 120.862010), addressDictionary: nil))
                request.requestsAlternateRoutes = true
                request.transportType = .automobile
        
                let directions = MKDirections(request: request)
        request.transportType = MKDirectionsTransportType.automobile
        directions.calculate { ( routeResponse, routeError )->Void in
            if routeError != nil{
                print("");
            }else{
                let route = routeResponse!.routes[0] as! MKRoute
             
                self.currentRoute = route
                self.myMapView.removeOverlays(self.myMapView.overlays)
                self.myMapView.addOverlay(route.polyline,level:MKOverlayLevel.aboveLabels)
                let rect = route.polyline.boundingMapRect
                self.myMapView.setRegion(MKCoordinateRegion(rect), animated: true)
                
            }}
     
        //---------------------
        let request2 = MKDirections.Request()
        request2.source = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.849524, longitude: 120.932849), addressDictionary: nil))
        request2.destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.69196, longitude: 120.531792), addressDictionary: nil))
                request2.requestsAlternateRoutes = true
                request2.transportType = .automobile
        
        let directions2 = MKDirections(request: request2)
        request2.transportType = MKDirectionsTransportType.automobile
        directions2.calculate { ( routeResponse2, routeError )->Void in
            if routeError != nil{
                print("");
            }else{
                let route2 = routeResponse2!.routes[0] as! MKRoute
             
                self.currentRoute = route2
                self.myMapView.removeOverlays(self.myMapView.overlays)
                self.myMapView.addOverlay(route2.polyline,level:MKOverlayLevel.aboveLabels)
                let rect2 = route2.polyline.boundingMapRect
                self.myMapView.setRegion(MKCoordinateRegion(rect2), animated: true)
                
            }}
        getDirections2()
        //---------------------
        content.title = "Restaurant Recommandation"
        content.subtitle = "雲端農業送貨系統，試試新的餐點吧！"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)
        let requestT = UNNotificationRequest(identifier: "foodpin.restuantSuggetion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(requestT,withCompletionHandler: nil)
        // 使用URLSession發送POST請求
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var requestA = URLRequest(url: url)
        requestA.httpMethod = "POST"
        requestA.addValue("Bearer YOUR_API_KEY", forHTTPHeaderField: "Authorization")
        requestA.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let parameters: [String: Any] = [
            "messages": [
                ["role": "system", "content": "You are a chatbot."],
                ["role": "user", "content": "Hello, how are you?"]
            ]
        ]

        requestA.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: requestA){ data, response, error in
            
        }.resume()
        
    
        
        

                }
    private func prepareNotification(){
        if restaurantNames.count <= 0{
            return
        }
        let randomNum = Int.random(in: 0..<restaurantNames.count)
        let suggestedRestaurant = restaurantNames[randomNum]
        
        content.title = "Restaurant Recommandation"
        content.subtitle = "Try new food today"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: true)
        let requestT = UNNotificationRequest(identifier: "foodpin.restuantSuggetion", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(requestT,withCompletionHandler: nil)
    }
    func getDirectionsl() {
            let request = MKDirections.Request()
            // Source
            let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 120.932849, longitude: 23.849524))
            request.source = MKMapItem(placemark: sourcePlaceMark)
            // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 121.021287, longitude: 23.655465))
            request.destination = MKMapItem(placemark: destPlaceMark)
            // Transport Types
            request.transportType = [.automobile, .walking]

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "No error specified").")
                    return
                }

                let route = response.routes[0]
                self.myMapView.addOverlay(route.polyline)

                // …
            }
        }
    func getDirections() {
        let request = MKDirections.Request()
            // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.6921, longitude: 120.5315))
            request.source = MKMapItem(placemark: sourcePlaceMark)
            // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.814511, longitude: 120.854461))//23.513134,120.808964 阿里山23.07759,120.535492玉井甲仙那瑪夏;23.897785,121.047400
            request.destination = MKMapItem(placemark: destPlaceMark)
            // Transport Types
            request.transportType = [.automobile, .walking]

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "No error specified").")
                    return
                }

                let route = response.routes[0]
                self.myMapView.addOverlay(route.polyline)

                // …
            }
        }
    
    func getDirections2() {
        let request = MKDirections.Request()
            // Source
        let sourcePlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.814511, longitude: 120.854461))
            request.source = MKMapItem(placemark: sourcePlaceMark)
            // Destination
        let destPlaceMark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 23.688317, longitude: 120.862524 ))//23.513134,120.808964 阿里山23.07759,120.535492玉井甲仙那瑪夏;23.897785,121.047400;23.849524,120.932849日月潭
            request.destination = MKMapItem(placemark: destPlaceMark)
            // Transport Types
            request.transportType = [.automobile, .walking]

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let response = response else {
                    print("Error: \(error?.localizedDescription ?? "No error specified").")
                    return
                }

                let route = response.routes[0]
                self.myMapView.addOverlay(route.polyline)

                // …
            }
        }


    }

extension ViewController {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        // Set the color for the line
        renderer.strokeColor = .red
        return renderer
    }
}

struct CBUUIDs{

    static let kBLEService_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Tx = "6e400002-b5a3-f393-e0a9-e50e24dcca9e"
    static let kBLE_Characteristic_uuid_Rx = "6e400003-b5a3-f393-e0a9-e50e24dcca9e"

    static let BLEService_UUID = CBUUID(string: kBLEService_UUID)
    static let BLE_Characteristic_uuid_Tx = CBUUID(string: kBLE_Characteristic_uuid_Tx)//(Property = Write without response)
    static let BLE_Characteristic_uuid_Rx = CBUUID(string: kBLE_Characteristic_uuid_Rx)// (Property = Read/Notify)
}
extension UIView{
    func showToast(text: String){
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.tintColor = .orange
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 40 - 20, width: expectedSize.width + 20, height: expectedSize.height + 20)
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1.5, delay: 1.5, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
            
        else {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView") ?? MKAnnotationView()
            annotationView.image = UIImage(named: "place icon")
            return annotationView
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.black.withAlphaComponent(0.5)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
}
final class ViewModel: ObservableObject {
    init() {}
    
    private var client: OpenAISwift?
    
    func setup() {
        client = OpenAISwift(authToken: "erpowgkvrekaebkapo")
        
    }
    
    func send(text: String,
              completion: @escaping (String) -> Void) {
        client?.sendCompletion(with: text,
                               maxTokens: 200,
                               completionHandler: { result in
            switch result {
            case .success(let model):
                let output = model.choices?.first?.text ?? ""
                completion(output)
            case .failure:
                break
            }
        })
    }
}
