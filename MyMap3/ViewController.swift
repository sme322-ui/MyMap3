import UIKit
import MapKit
import CoreLocation
import CoreImage
import CoreMotion
import SwiftUI
import WebKit
import SQLite3
import CoreBluetooth
import AVFoundation
import Foundation
import CoreData
import iAd
import LocalAuthentication
import AEXML
@objcMembers class ViewController: UIViewController, CLLocationManagerDelegate,WKUIDelegate, MKMapViewDelegate,NSURLConnectionDataDelegate,UITableViewDataSource,AVSpeechSynthesizerDelegate, UITableViewDelegate{
    var annotation: MKPointAnnotation?
    var locationManager: CLLocationManager!
    @IBOutlet weak var locationLabel: UILabel!
    let pizzaPin = UIImage(named: "pizza pin")
       let crossHairs = UIImage(named: "crosshairs")
    let newPin = MKPointAnnotation()
    var timer = Timer()
    let chicagoCoordinate = CLLocationCoordinate2DMake(41.8832301, -87.6278121)
        let initialCoordinate = CLLocationCoordinate2DMake(41.9180474,-87.661767)
   @IBOutlet var outputTextView: UITextView!
    let captureSession = AVCaptureSession()
    let myDataQueue = DispatchQueue(label: "DataQueue",
                                    qos: .userInitiated,
                                    attributes: .concurrent,
                                    autoreleaseFrequency: .workItem,
                                    target: nil)
    let apiKey2 = "ZEJtsYY2yTKTa8tUQ9TfMI1Jl7e6JfD5"
    let soapRequest = AEXMLDocument()
    var restaurantNames = ["teaha","CaffeLatte","Espresso","Americano"]
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var restaurantIsFavorites = Array(repeating: false, count: 21)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    let synth = AVSpeechSynthesizer()
       var myUtterance = AVSpeechUtterance(string: "Hello")
    private static var kivaLoanURL = "https://api.kivaws.org/v1/loans/newest.json"
    var userLocation: CLLocation?
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "datacell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for:indexPath)
        tableView.dataSource=self
        cell.textLabel?.text = restaurantNames[indexPath.row]
        cell.imageView?.image = UIImage(named:"Americano")
        
        return cell
    }
    let url = URL(string: "https://api.kivaws.org/v1/loans/newest.json")!
    var db :OpaquePointer? = nil
    var statement :OpaquePointer? = nil
    var myLocationManager :CLLocationManager!
    @IBOutlet var myMapView :MKMapView!
    private var destination:[MKPointAnnotation] = []
    @IBOutlet var restaurantImageView:UIImageView!
    @IBOutlet var imageView: UIImageView?
    var routeSteps = [MKRoute.Step]()
    private var currentRoute: MKRoute?
    var placemarkLongitude = 120.534
    var placemarkLatitude = 23.15
    private var previousLocation:[MKPointAnnotation] = []
    private var newLocation:[MKPointAnnotation] = []
    var seconds=0.0
    var distance=0.0
    var _locationManager=CLLocationManager()
    let login_url = "https://www.kaleidosblog.com/tutorial/login/api/Login"
        let checksession_url = "https://www.kaleidosblog.com/tutorial/login/api/CheckSession"
    var login_session:String = ""
    private static var kivaLoanURL1 = "https://api.kivaws.org/v1/loans/newest.json"
    let decoder = JSONDecoder()
    let request:MKDirections.Request = MKDirections.Request()
    var bleManager: BLEManagable?
    let lm = CLLocationManager()
    let sessionConfiguration = URLSessionConfiguration.default
    let DBFILE_NAME = "NoteList.sqlite3"
    var periperalManager:CBPeripheralManager!
    let C001_CHARACTZERISZTIC = "C001"
    let checkInAction = UIAlertAction(title:"Check in",style:.default,handler: {
        (action:UIAlertAction!)->Void in
    })
    var db2 :SQLiteConnect? = nil
    let sqliteURL: URL = {
            do {
                return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("db.sqlite")
            } catch {
                fatalError("Error getting file URL from document directory.")
            }
        }()
       @IBOutlet weak var txtPassword: UITextField!
       @IBOutlet weak var txtUserName: UITextField!
       //MARK: Login Action
       @IBOutlet weak var segmentedControl: UISegmentedControl!
       var objects = NSMutableArray()
    @IBAction func myLocation(_ sender:UIButton){
        let location = myMapView.userLocation
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        myMapView.setRegion(region, animated: true)
    }
    var location : CLLocationManager!; //座標管理元件
    var status = CLLocationManager.authorizationStatus()
    var backFacingCamera:AVCaptureDevice?
    var frontFacingCamera:AVCaptureDevice?
    var currentDevice:AVCaptureDevice?
    @IBOutlet weak var username_input: UITextField!
    @IBOutlet weak var password_input: UITextField!
    @IBOutlet weak var login_button: UIButton!
    @IBOutlet weak var weatherLabel: UILabel!
    let manager = CLLocationManager()
    var completion:((CLLocation)->Void)?
    public func getUserLocation(completion:@escaping ((CLLocation)-> Void)){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        var thread1:Thread?
        thread1=Thread(target: self, selector:#selector(ViewController.thread1ToDo), object: nil)
        thread1?.start()
        var locationManager: CLLocationManager!
        let mm = CMMotionManager()
        let device = UIDevice.current
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
        navigationItem.title = "牧場地圖"
        if device.isProximityMonitoringEnabled{
            let nc = NotificationCenter.default
            nc.addObserver(self,
                           selector: #selector(proximityStateChanged(_:)),
                           name:NSNotification.Name.MKAnnotationCalloutInfoDidChange,
                           object:nil)
        }else{
            print("此裝置沒有接近感測器")
        }
        let dst:String = NSHomeDirectory()+"/Documents/Personal.db"
        if sqlite3_open(dst,&db) !=  SQLITE_OK {
            print("can not open db")
        }else{
            let sql = "select * from Contacts"
            sqlite3_prepare_v2(db, (sql as NSString).utf8String, -1, &statement, nil)
            while sqlite3_step(statement)==SQLITE_ROW{
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let age = sqlite3_column_int(statement, 2)
                let address = String(cString: sqlite3_column_text(statement, 3))
                print("contact.id:\(id) name:\(name) age:\(age) address:\(address)")
                self.view.showToast(text:"contact.id:\(id) name:\(name) age:\(age) address:\(address)" )
                UIApplication.shared.keyWindow?.showToast(text:"contact.id:\(id) name:\(name) age:\(age) address:\(address)")
                }
            sqlite3_finalize(statement)
            }
        createTable()
        queryOneData()
        zoomToRegion()
        deliveryOverlay(restaurantName:"Connie's Pizza",radius: 5000)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest   //user位置追蹤精確程度，設置成最精確位置
        manager.activityType = .automotiveNavigation        //設定使用者的位置模式，手機會去依照不同設定做不同的電力控制
        manager.startUpdatingLocation()
        if status == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               manager.requestAlwaysAuthorization()
               manager.requestWhenInUseAuthorization()
           }
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
        let sqlitePath = sqliteURL.path
               print(sqlitePath)
               db2 = SQLiteConnect(path: sqlitePath)
               if let mydb = db2 {
                   // create table
                   let _ = mydb.createTable("students", columnsInfo: [
                       "id integer primary key autoincrement",
                       "name text",
                       "height double"])
                   let _ = mydb.insert("students",
                                       rowInfo: ["name":"'DRAM'","height":"550"])
                   let statement = mydb.fetch("students", cond: "1 == 1", order: nil)
                   while sqlite3_step(statement) == SQLITE_ROW{
                       let id = sqlite3_column_int(statement, 0)
                       let name = String(cString: sqlite3_column_text(statement, 1))
                       let height = sqlite3_column_double(statement, 2)
                       print("\(id). \(name) 價位： \(height)")
                   }
                   sqlite3_finalize(statement)
                   let _ = mydb.update(
                       "students",
                       cond: "id = 2",
                       rowInfo: ["name":"'RAM'","height":"500"])
                   let _ = mydb.delete("students", cond: "id = 5")
        }
        if(UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
          UIApplication.shared.openURL(URL(string:
            "comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic")!)
        } else {
          print("Can't use comgooglemaps://");
        }
        let testURL = URL(string: "comgooglemaps-x-callback://")!
        if UIApplication.shared.canOpenURL(testURL) {
          let directionsRequest = "comgooglemaps-x-callback://" +
            "?daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York" +
            "&x-success=sourceapp://?resume=true&x-source=AirApp"

          let directionsURL = URL(string: directionsRequest)!
        UIApplication.shared.openURL(directionsURL)
        open(scheme: "omgooglemaps://?saddr=Google+Inc,+8th+Avenue,+New+York,+NY&daddr=John+F.+Kennedy+International+Airport,+Van+Wyck+Expressway,+Jamaica,+New+York&directionsmode=transit")
        } else {
          NSLog("Can't use comgooglemaps-x-callback:// on this device.")
        }
        printExampleFromReadme()
        let soapRequest = AEXMLDocument()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let url5 = URL(string: "https://foodprint.ws/j_spring_security_check")!
        var request5 = URLRequest(url: url5)
        request5.httpMethod = "POST"
        request5.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let urlStr = "https://itunes.apple.com/search?term=swift&media=music"
        if let url = URL(string: urlStr) {
            URLSession.shared.dataTask(with: url) { data, response , error in
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                if let data = data {
                    do {
                        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                        print(searchResponse.results)
                    } catch {
                        print(error)
                    }
                } else {
                    print("error")
                }
            }.resume()
        }
        let text = "你好,雲端農業送貨系統"
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language

            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else {
            print("Unknown language")
        }
        let url = URL(string: "https://reqres.in/api/users?page=1")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
        var dataArray = [Int] ()
        let url7 = URL(string: "https://reqres.in/api/users/3")!
        var request4 = URLRequest(url: url7)
        request4.httpMethod = "delete"
        URLSession.shared.dataTask(with: request4) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        }.resume()
        let session = URLSession(configuration: .default)
        let url2 = URL(string: "https://reqres.in/api/users?page=1")!
        let request6 = URLRequest(url: url2)
        URLSession.shared.dataTask(with: request6) { data, response, error in
            if let data = data,
               let content = String(data: data, encoding: .utf8) {
                print(content)
            }
        }.resume()
        let string = "Welcome to cloud logistic System"
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
         myUtterance = AVSpeechUtterance(string: "Hello World")
                myUtterance.rate = 0.3
        synth.speak(myUtterance)
        func zoomToRegion() {
            let location = CLLocationCoordinate2D(latitude: 13.03297, longitude: 80.26518)
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
            myMapView.setRegion(region, animated: true)
        }
        func deliveryOverlay(restaurantName:String, radius:CLLocationDistance){
            let center = CLLocationCoordinate2D(latitude: 23.15, longitude: 120.53)
            let circle = MKCircle(center: center, radius: radius)
            myMapView.addOverlay(circle)
        }
        func open(scheme: String) {
                if let url = URL(string: scheme) {
                   if #available(iOS 10, *) {
                       UIApplication.shared.open(url, options: [:],
                       completionHandler: {
                          (success) in
                          print("Open \(scheme): \(success)")
                        })
                     } else {
                          let success = UIApplication.shared.openURL(url)
                          print("Open \(scheme): \(success)")
                 }
             }
           }
        func readLocalFile(forName name: String) -> Data? {
            do {
                if let bundlePath = Bundle.main.path(forResource: name,
                                                     ofType: "json"),
                    let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                    return jsonData
                }
            } catch {
                print(error)
            }
            return nil
        }
        func createTable() {
            let createTableString = """
                                    CREATE TABLE Contacts(
                                    Id INT PRIMARY KEY NOT NULL,
                                    Name CHAR(255),
                                    age Int,
                                    address CHAR(255));
                                    """
            var createTableStatement: OpaquePointer?
            if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
                if sqlite3_step(createTableStatement) == SQLITE_DONE {
                    print( "成功创建表")
                } else {
                    print( "未成功创建表")
                }
            } else {
                    
            }
           sqlite3_finalize(createTableStatement)
        }
        func getDirection(){
            guard let location = locationManager.location?.coordinate else{
                return
            }
            let request = createDirectionRequest(from: location)
            let direction = MKDirections(request: request)
            
            directions.calculate { response, error in
                guard let response = response else{return}
                for route in response.routes{
                    self.myMapView.addOverlay(route.polyline)
                    self.myMapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                }}}
        func openDatabase() -> OpaquePointer? {
            var dbPath = "/Users/siemonyan/Desktop/GeoCoder3/GeoCoder3"
            var db: OpaquePointer?
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("成功打开数据库，路径：\(dbPath)")
                return db
            } else {
                print( "打开数据库失败")
                return nil
            }
        }
        let urlString2 = URL(string: "https://reqres.in/api/users/3")  // Making the URL
        if let url = urlString2 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 // Checking if error exist.
                 print(error)
              } else {
                 if let usableData = data {
                    // Checking if data exist.
                    print(usableData)
                    // printing Data.
                 }
              }
           }
            task.resume()
        }
        let queue = DispatchQueue.global()
        myLocationManager = CLLocationManager()
        myLocationManager.delegate = self
        myLocationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        myLocationManager.requestAlwaysAuthorization()
        myLocationManager.startUpdatingLocation()
        myLocationManager.startUpdatingHeading()
        let fullSize = UIScreen.main.bounds.size
        let anns = [MKPointAnnotation(),MKPointAnnotation()]
        let url6 = Bundle.main.url(forResource:"test",withExtension: "json")
        myMapView = MKMapView(frame: CGRect(x: 0, y: 20, width: fullSize.width, height: fullSize.height - 20))
        myMapView.showsUserLocation = true
        myMapView.delegate = self
        myMapView.mapType = .standard
        myMapView.isPitchEnabled = true
        myMapView.userTrackingMode = .follow//效果:不带方向的追踪,显示用户的位置,并且会跟随用户移动
        myMapView.showsUserLocation = true
        myMapView.userTrackingMode = .follow
        myMapView.isZoomEnabled = true
        callAPI()
        callWeatherAPI()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        let center = UNUserNotificationCenter.current()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringVisits()
        var restaurantNames = ["teaha","CaffeLatte","Espresso","Americano"]
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return restaurantNames.count
        }
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cellIdentifier = "datacell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier,for:indexPath)
            cell.textLabel?.text = restaurantNames[indexPath.row]
            return cell
        }
        weak var routeMap: MKMapView!
        var currentTransportType = MKDirectionsTransportType.automobile
        var peripheralManager : CBPeripheralManager!
        let latDelta = 0.05
        let longDelta = 0.05
        let currentLocationSpan:MKCoordinateSpan = MKCoordinateSpan.init(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let sourceLocation = CLLocationCoordinate2D(latitude: 25.033493, longitude: 121.564101)
        let destinationLocation = CLLocationCoordinate2D(latitude: 22.817701, longitude: 120.2858)
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        let sourceAnnotation = MKPointAnnotation()
            sourceAnnotation.title = "台北101"
        if let location = sourcePlacemark.location {
                  sourceAnnotation.coordinate = location.coordinate
        }
        let destinationAnnotation = MKPointAnnotation()
              destinationAnnotation.title = "高雄市岡山區"
              
        if let location = destinationPlacemark.location {
              destinationAnnotation.coordinate = location.coordinate
        }
        self.myMapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
               directionRequest.transportType = .automobile
        
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate{
            (response,error)-> Void in
            guard let response = response else {
                            if let error = error {
                                print("Error: \(error)")
                            }
                            
                            return
                        }
            let route = response.routes[0]
            self.myMapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
        }
        let sourceLocation2 = CLLocationCoordinate2D(latitude: 25.033671, longitude: 121.564427)
        let destinationLocation2 = CLLocationCoordinate2D(latitude: 22.42, longitude: 120.21)
   
        let sourcePlacemark2 = MKPlacemark(coordinate: sourceLocation2, addressDictionary: nil)
        let destinationPlacemark2 = MKPlacemark(coordinate: destinationLocation2, addressDictionary: nil)
        
        // 4.
        let sourceMapItem2 = MKMapItem(placemark: sourcePlacemark2)
        let destinationMapItem2 = MKMapItem(placemark: destinationPlacemark2)
        
        // 5.
        let sourceAnnotation2 = MKPointAnnotation()
        sourceAnnotation2.title = "Taipei City"

        if let location = sourcePlacemark2.location {
          sourceAnnotation2.coordinate = location.coordinate
      }
      let destinationAnnotation2 = MKPointAnnotation()
      destinationAnnotation2.title = "Empire State Building"
      
      if let location = destinationPlacemark2.location {
          destinationAnnotation2.coordinate = location.coordinate
      }
   self.myMapView.showAnnotations([sourceAnnotation2,destinationAnnotation2], animated: true )
   let directionRequest2 = MKDirections.Request()
   directionRequest2.source = sourceMapItem2
   directionRequest2.destination = destinationMapItem2
   directionRequest2.transportType = .automobile

   let directions2 = MKDirections(request: directionRequest2)
   directions2.calculate{
    (response2,error)-> Void in
    guard let response2 = response2 else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    
                    return
                }
    let route2 = response2.routes[0]
    self.myMapView.addOverlay((route2.polyline), level: MKOverlayLevel.aboveRoads)
   }
          location = CLLocationManager();
          location.delegate = self;
          location.requestWhenInUseAuthorization();
          location.startUpdatingLocation();
          location.distanceFilter = CLLocationDistance(10);
   let center2:CLLocation = CLLocation(latitude: 25.05, longitude: 121.515)
        let currentRegion = MKCoordinateRegion(center: center2.coordinate, span: currentLocationSpan)
        myMapView.setRegion(currentRegion, animated: true)
        var annView = myMapView.dequeueReusableAnnotationView(withIdentifier: "pin") as? MKPinAnnotationView
        self.view.addSubview(myMapView)
        var points3 = [CLLocationCoordinate2D]()
        var objectAnnotation = MKPointAnnotation()
        var objectAnnotation1 = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: 25.036798, longitude: 121.499962).coordinate
        objectAnnotation.title = "艋舺公園"
        objectAnnotation.subtitle = "艋舺公園位於龍山寺旁邊，原名為「萬華十二號公園」。"
        myMapView.addAnnotation(objectAnnotation)
        var location = CLLocation(latitude:22.999034,longitude:120.212868)
        var region = MKCoordinateRegion(center:location.coordinate,latitudinalMeters:300,longitudinalMeters: 300)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: 24.441304, longitude: 120.74123).coordinate
        objectAnnotation.title = "飛牛牧場"
        objectAnnotation.subtitle = "地址|35750苗栗縣通霄鎮南和里166號"
        myMapView.addAnnotation(objectAnnotation)
        objectAnnotation = MKPointAnnotation()
        objectAnnotation.coordinate = CLLocation(latitude: 23.760679, longitude: 120.365768).coordinate
        objectAnnotation.title = "千巧谷牧場"
        objectAnnotation.subtitle = "地址|637雲林縣崙背鄉東興路182之32號"
        myMapView.bounds = CGRect(x:400,y:400,width: 400,height: 600)
        myMapView.addAnnotation(objectAnnotation)
        if(objectAnnotation.title)!=="飛牛牧場"{
           annView!.pinTintColor = UIColor.green
        }
        lm.delegate = self
        lm.startUpdatingHeading()
        var points2 = [CLLocationCoordinate2D]()
        points2.append(CLLocationCoordinate2D(latitude:23.76 , longitude:120.3657646 ))
        points2.append(CLLocationCoordinate2D(latitude: 23.7606595, longitude: 120.4))
        points2.append(CLLocationCoordinate2D(latitude: 23.755, longitude: 120.43))
        points2.append(CLLocationCoordinate2D(latitude: 23.77, longitude: 120.3))
         let polygon2 = MKPolygon(coordinates: &points2, count: points2.count)
         myMapView.addOverlay(polygon2)
         myMapView.setCenter(points2[0],animated:false)
         myMapView.setCenter(points2[1], animated: false)
        
        points3.append(CLLocationCoordinate2D(latitude:23.76 , longitude:120.3657646 ))
        points3.append(CLLocationCoordinate2D(latitude: 23.7606595, longitude: 120.4))
        myMapView.addOverlay(polygon2)
        myMapView.setCenter(points2[0],animated:false)
        myMapView.showsCompass = true
        myMapView.showsScale = true
        myMapView.showsTraffic = true
        myMapView.showsUserLocation = true
        myMapView.mapType = MKMapType(rawValue: 0)!
        myMapView.userTrackingMode = MKUserTrackingMode(rawValue: 2)!
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
        var status3 = CLLocationManager.authorizationStatus()
        if status3 == .notDetermined || status == .denied || status == .authorizedWhenInUse {
               locationManager.requestAlwaysAuthorization()
               locationManager.requestWhenInUseAuthorization()
           }
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        let request3 = MKLocalSearch.Request()
        request3.naturalLanguageQuery = "牧場"
        request3.region = myMapView.region
        let search2 = MKLocalSearch(request:request3)
        search2.start{(response,error) in
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
        self.myMapView.isPitchEnabled = true
        print("present location : (newLocation.coordinate.latitude), (newLocation.coordinate.longitude)")
        let url4:NSURL! = NSURL(string: "http://www.hangge.com")
        //创建请求对象
        let urlRequest:NSURLRequest = NSURLRequest(url: url4! as URL)
        //响应对象
        var response:URLResponse?
        do{
            //发送请求
            let data:NSData? = try NSURLConnection.sendSynchronousRequest(urlRequest as URLRequest,
                                                                          returning: &response) as NSData
            let str = NSString(data: data! as Data, encoding: String.Encoding.utf8.rawValue)
              print(str)
        }catch let error as NSError{
              //打印错误消息
              print(error.code)
              print(error.description)
        }
        checkLocationService()
        deliveryOverlay(restaurantName: "Connie's Pizza",radius: 2000)
        getDirection()
        //設定座標
        let flycow = CLLocationCoordinate2D(latitude:24.441304,longitude: 120.74123)
        let yuansin = CLLocationCoordinate2D(latitude:24.429672,longitude:120.738737)
        let chien = CLLocationCoordinate2D(latitude:23.45384,longitude:120.21568)
        
        let pA = MKPlacemark(coordinate: flycow, addressDictionary: nil)
        let pB = MKPlacemark(coordinate: yuansin, addressDictionary: nil)
        let pC = MKPlacemark(coordinate: chien, addressDictionary: nil)
        
        let miA = MKMapItem(placemark: pA)
        miA.name = "飛牛牧場"
        let miB = MKMapItem(placemark: pB)
        miB.name = "永興休閒農場"
        let miC = MKMapItem(placemark: pC)
        miC.name = "千巧谷休閒農場"
        let routes = [miA,miC]
        let options = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
       
        let urlString3 = URL(string: "api.openweathermap.org/data/2.5/forecast?id=524901&APPID=1111111111")  // Making the URL
        if let url = urlString3 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 // Checking if error exist.
                print(error!)
                
              } else {
                 if let usableData = data {
                    print(usableData)
                   
                 }
              }
           }
            task.resume()
        }
        MKMapItem.openMaps(with:routes,launchOptions: options)
        let urlString4 = URL(string: "api.openweathermap.org/data/2.5/forecast?id=524901&APPID=1111111111")  // Making the URL
        if let url = urlString4 {
           let task = URLSession.shared.dataTask(with: url) {
              (data, response, error) in // Creating the URL Session.
              if error != nil {
                 print(error)
              } else {
                 if let usableData = data {
                    print(usableData)
                 }
              }
           }
            task.resume()
        }
        let path = Bundle.main.path(forResource: "index", ofType: ".html")
    }
    func render(_ location: CLLocation){
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        myMapView.setRegion(region, animated: true)
    }
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            let string = "Detacted Device shacking"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")

            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
           
            myUtterance = AVSpeechUtterance(string: "Hello World")
                    myUtterance.rate = 0.3
            synth.speak(myUtterance)
        }
    }
    @objc func thread1ToDo(sender:AnyObject?){
        for i in 1...100{
            print("I'm thread1-- \(i)")
            //加入當前標記
            var nSize = 10000
            while nSize > 1 {
                // loop body
             nSize = (nSize + 1) / 2
             DispatchQueue.main.async { [self] in
                  
                 for index in 1...nSize {
                     print("\(index) 偵測搖晃：\(index * 5)")
                     myMapView.addAnnotation(newPin)
                 }
                 myMapView.addAnnotation(newPin)
                 print("add an annotation.")
            }}
        }
    }
    func addAnnotations(coords: [CLLocation]){
            for coord in coords{
                let CLLCoordType = CLLocationCoordinate2D(latitude: coord.coordinate.latitude,
                                                          longitude: coord.coordinate.longitude);
                let anno = MKPointAnnotation();
                anno.coordinate = CLLCoordType;
                myMapView.addAnnotation(anno);
            }
    }
    private func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{
            return nil;
        }else{
            let pinIdent = "Pin";
            var pinView: MKPinAnnotationView;
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: pinIdent) as? MKPinAnnotationView {
                dequeuedView.annotation = annotation;
                pinView = dequeuedView;
            }else{
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdent);
            }
            return pinView;
        }
    }
    func authenticateWithTouchID(){
        let localAuthContext = LAContext()
        let resonText = "Authentication is required to sign in AppCoda"
        var authError:NSError?
        if !localAuthContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthentication, error: &authError){
            print(authError?.localizedDescription)
            return
        }
    }
    private func callWeatherAPI() {
        // 根據網站的 Request tab info 我們拼出請求的網址
        let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/315078?apikey=\(apiKey2)&language=zh-Tw")!
        // 將網址組成一個 URLRequest
        var request = URLRequest(url: url)
        
        // 設置請求的方法為 GET
        request.httpMethod = "GET"
        let session = URLSession.shared
     
        let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            guard let data = data else {
                return
            }
            do {
                // 使用 JSONDecoder 去解開 data
                let weatherModel = try JSONDecoder().decode([WeatherModel].self, from: data)
                print(weatherModel)
                DispatchQueue.main.async {
            
                    let tmp = weatherModel.first?.temperature.metric.value ?? -1
               }
            } catch {
                print(error)
            }
    })
        dataTask.resume()
    }
    func webServiceConnect( nameSpace:String, urlStr:String, method:String){
            //soap的配置
            let soapMsg:String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"+"<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"+"<soap:Body>\n"+"<"+method+" xmlns=\""+nameSpace+"\">\n"+"<byProvinceName>"+"北京"+"</byProvinceName>\n"+"</"+method+">\n"+"</soap:Body>\n"+"</soap:Envelope>\n"
            
            let soapMsg2:NSString = soapMsg as NSString
            //接口的转换为url
            let url:URL = URL.init(string:urlStr)!
            //计算出soap所有的长度，配置头使用
            let msgLength:NSString = NSString.init(format: "%i", soapMsg2.length)
            //创建request请求，把请求需要的参数配置
            var request:URLRequest = NSMutableURLRequest.init() as URLRequest
            //请求的参数配置，不用修改
            request.timeoutInterval = 10
            request.cachePolicy = .reloadIgnoringLocalCacheData
            request.url = url
            request.httpMethod = "POST"
            //请求头的配置
            request.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(msgLength as String, forHTTPHeaderField: "Content-Length")
            request.httpBody = soapMsg.data(using: String.Encoding.utf8)
            //soapAction的配置
            let soapActionStr:String = nameSpace + method
            request.addValue(soapActionStr, forHTTPHeaderField: "SOAPAction")
            let session:URLSession = URLSession.shared
            let task:URLSessionDataTask = session.dataTask(with: request as URLRequest , completionHandler: {( data, respond, error) -> Void in
                
                if (error != nil){
                    
                    print("error is coming")
                }else{
                    //结果输出
                    let result:NSString = NSString.init(data: data!, encoding: String.Encoding.utf8.rawValue)!
                    print("result=\(result),\n adress=\(String(describing: request.url))")
                }
            })
            task.resume()
        }
    private func printExampleFromReadme() {
        guard
            let xmlPath = Bundle.main.path(forResource: "example", ofType: "xml"),
            let data = try? Data(contentsOf: URL(fileURLWithPath: xmlPath))
        else {
            print("resource not found!")
            return
        }
        var options = AEXMLOptions()
        options.parserSettings.shouldProcessNamespaces = false
        options.parserSettings.shouldReportNamespacePrefixes = false
        options.parserSettings.shouldResolveExternalEntities = false
    }
    func peripheralManager(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else{
            print(peripheral.state.rawValue)
            return
        }
        var service:CBMutableService
        var characteristic:CBMutableCharacteristic
        var charArray = [CBCharacteristic]()
        var charDictionary = [String: CBMutableCharacteristic]()
        service = CBMutableService(type: CBUUID(string:"A001_SERVICE"), primary: true)
        characteristic = CBMutableCharacteristic(type: CBUUID(string: "A001_SERVICES"), properties: [.notifyEncryptionRequired,.write,.read], value: nil, permissions: [.writeEncryptionRequired,.readEncryptionRequired])
        charArray.append(characteristic)
        service.characteristics = charArray
        
        periperalManager.add(service)
    }
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake{
            print("裝置搖晃中")
            self.view.showToast(text: "裝置搖晃中\n\n")
            let text = "裝置搖晃中"
            if let language = NSLinguisticTagger.dominantLanguage(for: text) {

                //we now know the language of the text

                let utterance = AVSpeechUtterance(string: text)
                utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language
            let synth = AVSpeechSynthesizer()
                synth.speak(utterance)
            } else {
                print("Unknown language")
            }
            let string = "Detected device shacking"
            let utterance = AVSpeechUtterance(string: string)
            utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
            var nSize = 10000
            while nSize > 1 {
                // loop body
             nSize = (nSize + 1) / 2
             DispatchQueue.main.async { [self] in
                for index in 1...nSize {
                     print("\(index) 偵測搖晃：\(index * 5)")
                     myMapView.addAnnotation(newPin)
                }
                 myMapView.addAnnotation(newPin)
                 print("add an annotation.")
            }}
      }}
      @objc func proximityStateChanged(_ sender:NSNotification){
        let device = UIDevice.current
        if device.proximityState{
            print("物體接近")
     
        }else{
            print("物體遠離")
        }
     }
     func createDirectionRequest(from coordinate:CLLocationCoordinate2D)->MKDirections.Request{
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destinationLocation = MKPlacemark(coordinate: coordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destinationLocation)
        request.transportType = .transit
        request.requestsAlternateRoutes = true
        return request
    }
    func getJSONData(completed: @escaping () -> ()) {
        if let filepath = Bundle.main.path(forResource: "weather", ofType: "json") {
            if let data = try? String(contentsOf: URL(fileURLWithPath: filepath)) {
              

                // I must assign json to weatherData here
                DispatchQueue.main.async {
                    completed()
                }
            }
        } else {
            print("file not found")
        }
    }
   func getDirection(){
        guard let location = locationManager.location?.coordinate else{
            return
        }
        let request = createDirectionRequest(from: location)
        let directions = MKDirections(request:request)
        
        let callActionHandler = {
            (action:UIAlertAction!)->Void in
            let alertMessage = UIAlertController(title:"Service Unavalable",message:"sorry,the call feature is not avalable yet",preferredStyle: .alert)
            alertMessage.addAction(UIAlertAction(title:"ok",style:.default,handler:nil))
            self.present(alertMessage, animated: true, completion: nil)
        }
   }
    func queryOneData() {
        let queryString = "SELECT * FROM Contacts WHERE Id == 1;"
        var queryStatement: OpaquePointer?
        //第一步
        if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
            //第二步
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                //第三步
                let id = sqlite3_column_int(queryStatement, 0)
                
                let queryResultName = sqlite3_column_text(queryStatement, 1)
                let name = String(cString: queryResultName!)
                let age = sqlite3_column_int(queryStatement, 2)
                let address = sqlite3_column_double(queryStatement, 3)
                print( "id: \(id), name: \(name), age: \(age), address: \(address)")
                
                let alertController = UIAlertController(
                    title: "id: \(id), name: \(name), age: \(age), address: \(address)", message: "", preferredStyle: .alert
                )
                let alertAction = UIAlertAction(title: "id: \(id), name: \(name), age: \(age), address: \(address)", style: .default, handler: nil)
                alertController.addAction(alertAction)
                present(alertController, animated: true, completion: nil)
                
                let alert = UIAlertController(title: title, message: "", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "id: \(id), name: \(name), age: \(age), address: \(address)", style: UIAlertAction.Style.default, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                print("error")
            }
            
        }
        //第四步
        sqlite3_finalize(queryStatement)
    }
       func prepareForSeque(seque:UIStoryboardSegue,sender:AnyObject?){
          if seque.identifier == "showSteps"{
            let destinationController = seque.destination as! UINavigationController
            let routeTableViewController = destinationController.childViewControllerForPointerLock?.isFirstResponder as! ViewController
            if let steps = currentRoute?.steps as? [MKRoute.Step]{
                routeTableViewController.routeSteps = steps
            }
        }
    }
        func setup() {
            myMapView.delegate = self
            showCircle(coordinate: initialCoordinate,
                       radius: 1000)
        }
        func showCircle(coordinate: CLLocationCoordinate2D,
                        radius: CLLocationDistance) {
            let circle = MKCircle(center: coordinate,
                                  radius: radius)
            myMapView.addOverlay(circle)
        }
    func fetchLatestLoans(){
        guard let loanUrl = URL(string:Self.kivaLoanURL) else{
            return
        }
        let request = URLRequest(url: loanUrl)
        let task = URLSession.shared.dataTask(with: request,completionHandler: {(data,response,error)->Void in
            if let error = error{
                print(error)
                return
            }
            
            if let data = data{
                DispatchQueue.main.async {
                    self.loans = self.parseJsonData(data:data)
                }
            }
        })
        task.resume()
    }
    @Published var loans:[Loan] = []
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var location = "Paris,France"
        if CLLocationManager.authorizationStatus() == .notDetermined {
            myLocationManager.requestWhenInUseAuthorization()
            myLocationManager.startUpdatingLocation()
            
        }
     
        else if CLLocationManager.authorizationStatus() == .denied {
            let alertController = UIAlertController( title: "定位權限已關閉", message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "確認", style: .default, handler:nil)
            alertController.addAction(okAction)
            self.present( alertController, animated: true, completion: nil)
        }
        else if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // 開始定位自身位置
            myLocationManager.startUpdatingLocation()
        }
}
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // 停止定位自身位置
        myLocationManager.stopUpdatingLocation()
    }
    func parseJsonData(data:Data)->[Loan]{
        let decoder = JSONDecoder()
        
        do{
            let loanStore = try!decoder.decode(LoanStore.self, from: data)
            self.loans = loanStore.loans
        }catch{
            print(error)
        }
        return loans
    }
    func setUpLocationManager(){
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else{}
    }
    func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        switch central.state{
        case CBManagerState.poweredOn:
            print("藍芽開啟")
        case CBManagerState.unauthorized:
            print("沒有藍芽功能")
        case CBManagerState.poweredOff:
            print("藍芽關閉")
        default:
            print("未知狀態")
            
        }
        central.scanForPeripherals(withServices: nil, options: nil)
    }
    func centralManager(_central:CBCentralManager,didDiscover peripheral:CBPeripheral,advertismentData:[String:Any],rssi RSSI:NSNumber){
        if let name = peripheral.name{
            print(name)
        }
   }
        func showAlert(title: String, message: String, buttonTitle: String) {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            })
            alert.addAction(okAction)
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
    private func addAnotation(){
        let appleParkAnnotation = MKPointAnnotation()
        appleParkAnnotation.title = "Apple Park"
        appleParkAnnotation.coordinate = CLLocationCoordinate2D(latitude:37.332072300,longitude:-122.11130300)
        let ortegapartAnnotation = MKPointAnnotation()
        ortegapartAnnotation.title = "Ortega Park"
        ortegapartAnnotation.coordinate = CLLocationCoordinate2D(latitude:37.362226,longitude:-122.023617)
        destination.append(appleParkAnnotation)
        destination.append(ortegapartAnnotation)
        
        myMapView.addAnnotation(appleParkAnnotation)
        myMapView.addAnnotation(ortegapartAnnotation)
    }
    func showRoute(_ response: MKDirections.Response) {
        
        for route in response.routes {
            
            myMapView.addOverlay(route.polyline,
                         level: MKOverlayLevel.aboveRoads)
            
            for step in route.steps {
                print(step.instructions)
            }
        }
        
        if let coordinate = userLocation?.coordinate {
            _ =
                MKCoordinateRegion(center: coordinate,
                                   latitudinalMeters: 2000, longitudinalMeters: 2000)
         }
    }
    func mapView(_ mapView: MKMapView, rendererFor
                    overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
       if overlay.isKind(of: MKCircle.self){
              let circleRenderer = MKCircleRenderer(overlay: overlay)
         
              circleRenderer.strokeColor = UIColor.blue
              circleRenderer.lineWidth = 1
              return circleRenderer
          }
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 5.0
        return renderer
    }
    public func constructRoute(userLocation: CLLocationCoordinate2D){
        let directionsRequest = MKDirections.Request()
        directionsRequest.source = MKMapItem(placemark:MKPlacemark(coordinate: userLocation))
        directionsRequest.destination = MKMapItem(placemark:MKPlacemark(coordinate:destination[0].coordinate))
        directionsRequest.transportType = .automobile
        let directions = MKDirections(request:directionsRequest)
        directions.calculate{[weak self](directionsResponse,error)in
            guard let strongSelf = self else{return}
            if let error = error{
                print(error.localizedDescription)
            }else if let response = directionsResponse,response.routes.count>0{
                strongSelf.currentRoute =  response.routes[0]
                let route = directionsResponse!.routes[0] as! MKRoute
                
                strongSelf.myMapView.removeOverlays((self?.myMapView.overlays)!)
                strongSelf.myMapView.addOverlay(route.polyline,level:MKOverlayLevel.aboveRoads)
                strongSelf.currentRoute = route
                
                strongSelf.myMapView.addOverlay(response.routes[0].polyline)
                strongSelf.myMapView.setVisibleMapRect(response.routes[0].polyline.boundingMapRect, animated: true)
                let rect = route.polyline.boundingMapRect
                self?.myMapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
    }
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            myMapView.showsUserLocation = true
            break
        case .notDetermined:
            myLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            break
        
        @unknown default:
            break
        }
    }
    func getCenterLocation() -> CLLocation{
        let latitude = myMapView.centerCoordinate.latitude
        let longitude = myMapView.centerCoordinate.longitude
        return CLLocation(latitude:latitude,longitude:longitude)
    }
    func checkLocationService(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
        }
    }
    func mapView(_mapView:MKMapView,rendererFor overlay:MKOverlay)->MKOverlayRenderer{
        let renderer = MKPolygonRenderer(overlay:overlay)
        renderer.strokeColor = UIColor.systemBlue
        renderer.lineWidth = 3.0
        if overlay is MKPolygon{
            renderer.fillColor = UIColor.red.withAlphaComponent(0.2)
            renderer.strokeColor = UIColor.red.withAlphaComponent(0.7)
            
            renderer.lineWidth = 3
        }
        return renderer
    }
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
            renderer.lineWidth = 4.0
        
            return renderer
   }
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "MyPin"
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        // 重複使用地圖標註
        var annotationView:MKPinAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        }
        if(annotation.title)! == "行天宮"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "艋舺公園"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "好想工作室"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "飛牛牧場"{
            annotationView!.pinTintColor = UIColor.blue
        }
        if(annotation.title)! == "千巧谷牧場"{
            annotationView!.pinTintColor = UIColor.blue
        }
        let leftIconView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 33, height: 33))
        leftIconView.image = UIImage(named: "image1")
        annotationView?.leftCalloutAccessoryView = leftIconView
        let button = UIButton(type: .detailDisclosure) as UIButton
        annotationView?.rightCalloutAccessoryView = button
        return annotationView
    }
    private func mapView(mapView: MKMapView!, viewForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
           if (overlay is MKPolyline) {
               let pr = MKPolylineRenderer(overlay: overlay)
               pr.strokeColor = UIColor.blue.withAlphaComponent(0.5)
               pr.lineWidth = 4
               return pr
           }
          
           return nil
       }
     func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool,didUpdateLocations locations: [CLLocation]!) {
        print("物流車移動中")
         myMapView.removeAnnotation(newPin)

             let location = locations.last! as CLLocation

             let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
             let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

             //set region on the map
         myMapView.setRegion(region, animated: true)

             newPin.coordinate = location.coordinate
         myMapView.addAnnotation(newPin)
   }
    var dataArray = [Int] ()
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D,didUpdateLocations locations: [CLLocation]!) {
            let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            
            let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
            let destinationItem = MKMapItem(placemark: destinationPlaceMark)
            
            
            let sourceAnotation = MKPointAnnotation()
            sourceAnotation.title = "Delhi"
            sourceAnotation.subtitle = "The Capital of INIDA"
            if let location = sourcePlaceMark.location {
                sourceAnotation.coordinate = location.coordinate
            }
            
            let destinationAnotation = MKPointAnnotation()
            destinationAnotation.title = "Gurugram"
            destinationAnotation.subtitle = "The HUB of IT Industries"
            if let location = destinationPlaceMark.location {
                destinationAnotation.coordinate = location.coordinate
            }
            
            self.myMapView.showAnnotations([sourceAnotation, destinationAnotation], animated: true)
            
            let directionRequest = MKDirections.Request()
            directionRequest.source = sourceMapItem
            directionRequest.destination = destinationItem
            directionRequest.transportType = .automobile
            
            let direction = MKDirections(request: directionRequest)
            direction.calculate { (response, error) in
                guard let response = response else {
                    if let error = error {
                        print("ERROR FOUND : \(error.localizedDescription)")
                    }
                    return
                }
                
                let route = response.routes[0]
                self.myMapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
                
                let rect = route.polyline.boundingMapRect
                
                self.myMapView.setRegion(MKCoordinateRegion(rect), animated: true)
                
            }
        myMapView.addAnnotation(newPin)

                 let location = locations.last! as CLLocation

                 let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                 let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

                 //set region on the map
             myMapView.setRegion(region, animated: true)

                 newPin.coordinate = location.coordinate
             myMapView.addAnnotation(newPin)
        }
     func mapViewDidFinishLoadingMap(_ mapView: MKMapView,didUpdateLocations locations: [CLLocation]!) {
        print("載入地圖完成時")
       
    }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    
        print("點擊大頭針的說明")
        let route = currentRoute?.distance
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
       
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
    //Current location 8:13
    func locationManager(_ manager:CLLocationManager,didUpdateLocations locations:[CLLocation]){
        let userLocation:CLLocation = locations[0] as CLLocation
        print("user latitude = \(userLocation.coordinate.latitude)")
        print("user longitude = \(userLocation.coordinate.longitude)")
        
        let location = locations.last! as CLLocation
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        newPin.coordinate = location.coordinate
          //於當前位置加入標記->Thread
        myDataQueue.async(flags: .barrier) {
                var nSize = 10000
                while nSize > 1 {
                    // loop body
                 nSize = (nSize + 1) / 2
                 DispatchQueue.main.async { [self] in
                    for index in 1...nSize {
                         print("\(index) 乘于 5 为：\(index * 5)")
                         myMapView.addAnnotation(newPin)
                    }
                    myMapView.addAnnotation(newPin)
                    print("add an annotation.")
                    updateViews()
                  }
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
                DispatchQueue.main.async { [self] in
                    self.myMapView.addAnnotation(newPin)
                    print("add an annotation2.")
                }
            }
        }
        func updateViews() {
          let dataForViews = myDataQueue.sync { return dataArray }
        }
        var sp = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentationDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        //迴圈出力取得路徑
                for file in sp {
                    print(file)
                }
        //設定路徑
        var url: NSURL = NSURL(fileURLWithPath: "/Users/siemonyan/Desktop/MyMap3/data.txt")
        //定義可變資料變數
                var data = NSMutableData()
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
        data.append("user latitude = 23.691961990356518 user longitude = 120.53171341184672".data(using: String.Encoding.utf8, allowLossyConversion: true)!)
                //用data寫檔案
        data.write(toFile: url.path!, atomically: true)
        if let readData = NSData(contentsOfFile: url.path!) {
                    //如果內容存在 則用readData建立文字列
                   
                } else {
                    //nil的話，輸出空
                    print("Null")
                }
        let annotations = getMapAnnotations()
        
        var points: [CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        
        for annotation in annotations {
            points.append(annotation.coordinate)
        }
        let polyline = MKPolyline(coordinates: &points, count: points.count)
        
        myMapView.addOverlay(polyline)
        guard let location = locations.first else{
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
           // user location
           let userLatitude = self.manager.location?.coordinate.latitude //THIS RETURNS A VALUE
           let userLongitude = self.manager.location?.coordinate.longitude //THIS RETURNS A VALUE
           print("User Location is ", userLatitude, ", " ,userLongitude)
           let eventLatitude = self.placemarkLatitude // THIS RETURNS 0.0
           let eventLongitude = self.placemarkLongitude // THIS RETURNS 0.0
           print("Event Location is ", eventLatitude, ", " ,eventLongitude)
           let eventLocation = CLLocation(latitude: eventLatitude, longitude: eventLongitude)

           //Measuring my distance to my buddy's (in km)
        let distance = userLocation.distance(from: eventLocation) / 1000

             //Display the result in km
             print("The distance to event is ", distance)

             if (distance > 100) {

                 print("the distance is greater than 100 km")
             }
    }
    //MARK:- Zoom to region
    func zoomToRegion() {
        
        let location = CLLocationCoordinate2D(latitude: 13.03297, longitude: 80.26518)
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 5000.0, longitudinalMeters: 7000.0)
        
        myMapView.setRegion(region, animated: true)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
        {
            print("Error \(error)")
        }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
    
       print("點擊大頭針")
        let text = "選擇牧場"
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {

            //we now know the language of the text

            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: language) //use the detected language

            let synth = AVSpeechSynthesizer()
            synth.speak(utterance)
        } else {
            print("Unknown language")
        }
    }
    let kmlFileName = "Allowed area"
    let kmlFileType="kml"
    
    var polygonView:MKPolygonRenderer!
    var polygonCoordinatePoints:[CLLocationCoordinate2D] = []
    var shopName:[String] = []
    var shopCity:[String] = []
  
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      print("取消點擊大頭針")
    }
    func getMapAnnotations() -> [Station] {
        var annotations:Array = [Station]()
        
        //load plist file
        
        var stations: NSArray?
        if let path = Bundle.main.path(forResource: "stations", ofType: "plist") {
            stations = NSArray(contentsOfFile: path)
        }
        if let items = stations {
            for item in items {
                let lat = (item as AnyObject).value(forKey: "lat") as! Double
                let long = (item as AnyObject).value(forKey: "long")as! Double
                let annotation = Station(latitude: lat, longitude: long)
                annotation.title = (item as AnyObject).value(forKey: "title") as? String
                annotations.append(annotation)
            }
        }
        
        return annotations
    }
    @IBAction func showDirection(_ sender: AnyObject) {
        var currentTransportType = MKDirectionsTransportType.automobile
        if segmentedControl.selectedSegmentIndex == 0{
            currentTransportType = MKDirectionsTransportType.automobile
        }else{
            currentTransportType = MKDirectionsTransportType.walking
        }
        segmentedControl.isHidden = false
        let directionRequest = MKDirections.Request()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation],newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
           print("定位到了")
    }
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
           let conten = UNMutableNotificationContent()
           conten.title = "已進入區域"
           conten.body = "已進入區域"
           conten.sound = .default
           let request = UNNotificationRequest(identifier: "big", content: conten, trigger: nil)
           UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
            let conten = UNMutableNotificationContent()
            conten.title = "已離開"
            conten.body = "已離開"
            conten.sound = .default
            let request = UNNotificationRequest(identifier: "back", content: conten, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    func setupData() {
            // 1. 檢查系統是否能夠監視 region
            if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
                
                // 2.準備 region 會用到的相關屬性
                let title = "Lorrenzillo's"
                let coordinate = CLLocationCoordinate2DMake(23.69,120.53)
                let regionRadius = 10.0
                // 3. 設置 region 的相關屬性
                let region = CLCircularRegion(center: CLLocationCoordinate2D(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude),
                    radius: regionRadius,
                    identifier: title)
                locationManager.startMonitoring(for: region)
            }
        }
  
    func mapView(_mapView:MKMapView,ViewFor annotation:MKAnnotation)->MKAnnotationView?{
        if let temp = annotation as? MyAnnotation{
        var myView = myMapView.dequeueReusableAnnotationView(withIdentifier: "Pins") as?MKMarkerAnnotationView
        if myView == nil{
            myView = MKMarkerAnnotationView(annotation: temp, reuseIdentifier: "Pins")
            myView?.markerTintColor = UIColor.green
            myView?.glyphText = "TEST"
            myView?.glyphTintColor = UIColor.black
            myView?.titleVisibility = .adaptive
            myView?.subtitleVisibility = .visible
        }
            
        return myView
    }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            
            if overlay is MKPolyline {
                polylineRenderer.strokeColor = UIColor.blue
                polylineRenderer.lineWidth = 5

            }
            return polylineRenderer
        }
        func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay.isKind(of: MKCircle.self){
                let circleRenderer = MKCircleRenderer(overlay: overlay)
                circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.1)
                circleRenderer.strokeColor = UIColor.blue
                circleRenderer.lineWidth = 1
                return circleRenderer
            }
                return MKOverlayRenderer(overlay: overlay)
            }

        func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!){
            //drawing path or route covered
            if let oldLocationNew = oldLocation as CLLocation?{
                 let oldCoordinates = oldLocationNew.coordinate
                 let newCoordinates = newLocation.coordinate
                 var area = [oldCoordinates, newCoordinates]
                let polyline = MKPolyline(coordinates: &area, count: area.count)
                myMapView.addOverlay(polyline)
             }
        }
        //function to add annotation to map view
        func createPolyline(mapView: MKMapView) {
            let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
            let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
            let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
            let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
            let point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
            
            let points: [CLLocationCoordinate2D]
            points = [point1, point2, point3, point4, point5]
            
            let geodesic = MKGeodesicPolyline(coordinates: points, count: 5)
            myMapView.addOverlay(geodesic)
            UIView.animate(withDuration: 1.5, animations: { () -> Void in
                let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                let region1 = MKCoordinateRegion(center: point1, span: span)
                self.myMapView.setRegion(region1, animated: true)
            })
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 印出目前所在位置座標
        myMapView.removeAnnotation(newPin)

           let location = locations.last! as CLLocation

           let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
           let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

           //set region on the map
           myMapView.setRegion(region, animated: true)

           newPin.coordinate = location.coordinate
           myMapView.addAnnotation(newPin)
        }
        func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer!{
            if (overlay is MKPolyline) {
                let pr = MKPolylineRenderer(overlay: overlay)
                pr.strokeColor = UIColor.red
                pr.lineWidth = 5
                return pr
            }
            if let circleOverlay = overlay as? MKCircle {
                       let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
                       circleRenderer.fillColor = .black
                       circleRenderer.alpha = 0.1

                       return circleRenderer
                   }
            return nil
        }
        enum SerializationError: Error {
            case missing(String)
        }
        struct Acronym {
            let id: Int
            let short: String
            let long: String
        }
        typealias JSONDictionary = [String : Any]
        return nil

    }
}
    private func callAPI() {
       let apiKey2 = "ZEJtsYY2yTKTa8tUQ9TfMI1Jl7e6JfD5"
       let url = URL(string: "https://dataservice.accuweather.com/currentconditions/v1/315078?apikey=\(apiKey2)&language=zh-Tw")!
       var request = URLRequest(url: url)
       request.httpMethod = "GET"
       let session = URLSession.shared
       let dataTask = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
           guard let data = data else {
               return
           }
           do {
               DispatchQueue.main.async {}
               
           } catch {
               print(error)
           }
       })
       dataTask.resume()
}
struct Resource<Model> {
    let url: URL
    let parse: (Data) throws -> Model
}
struct UpdateUserBody: Encodable {
    let name: String
    let job: String
}
struct UpdateUserResponse: Decodable {
    let name: String
    let job: String
}
extension Resource {
    init(url: URL, parseJSON: @escaping (Any) throws -> Model) {
        self.url = url
        self.parse = { data in
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return try parseJSON(json)
        }
    }
}
struct CreateSCMPBody: Encodable {
    let ArticleNum: String
    let name: String
    let id: String
    let brandName:String
    let number:Int
    let manufacture:String
 
    let unit:String
    let warehouseNumber:Int
}
struct CreateUserResponse: Decodable {
    let name: String
    let job: String
    let id: String
}
struct Meme {
   let id: Int
   let image: URL
   let caption: String
   let category: String
}
struct StoreItem: Codable {
   let artistName: String
   let trackName: String
   let collectionName: String?
   let previewUrl: URL
   let artworkUrl100: URL
   let trackPrice: Double?
   let releaseDate: Date
   let isStreamable: Bool?
}
struct SearchResponse: Codable {
   let resultCount: Int
   let results: [StoreItem]
}
extension Meme: Codable { }
struct Loan:Codable{
    var name:String
    var country:String
    var use:String
    var amount:Int
    
    enum CodingKeys:String,CodingKey{
        case name
        case country = "location"
        case use
        case amount = "loan_amount"
    }
    enum LocationKeys:String,CodingKey{
        case contry
    }
}
struct CoffeeData: Decodable {
     var name: String
     var city: String
 }
struct LoanStore:Codable{
    var loans:[Loan]
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
}
enum Result<Model> {
    case success(Model)
    case failure(Error)
}
 
final class Webservice {
    func load<Model>(resource: Resource<Model>, completion: @escaping (Result<Model>) -> Void) {
        URLSession.shared.dataTask(with: resource.url) { (data, _, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                if let data = data {
                    do {
                        let result = try resource.parse(data)
                        DispatchQueue.main.async {
                            completion(.success(result))
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }.resume()
    }
}
struct City: Codable {
  let name: String
}

struct List: Codable {
  let main: Main
  let weather: [Weather]
  let dtTxt: String

  enum CodingKeys: String, CodingKey {
    case main, weather
    case dtTxt = "dt_txt"
  }
}

 struct Main: Codable {
    let temp: Double
 }

 struct Weather: Codable {
    let main, description: String
 }
struct User2: Codable {
  let id: Int
  let userName: String
  let age: Int?

  // Generated automatically by the compiler if not specified
  private enum CodingKeys: String, CodingKey {
    case id
    case userName = "user_name"
    case age
  }
  
  // Generated automatically by the compiler if not specified
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: . id)
    try container.encode(userName, forKey: . userName)
    try container.encode(age, forKey: . age)
  }

 // Generated automatically by the compiler if not specified
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(Int.self, forKey: .id)
    userName = try container.decode(String.self, forKey: .userName)
    age = try container.decode(Int.self, forKey: .age)
  }
}
struct PLNWaypointCoordinate {
    var latitude: Double = 0.0
    var longitude: Double = 0.0

    init(coordinateString: String) {
        self.latitude = convertCoordinate(string: coordinateString.components(separatedBy: ",")[0])
        self.longitude = convertCoordinate(string: coordinateString.components(separatedBy: ",")[1])
    }
    private func convertCoordinate(string: String) -> Double {
        var separatedCoordinate = string.split(separator: " ").map(String.init)

        let direction = separatedCoordinate[0].components(separatedBy: CharacterSet.letters.inverted).first
        let degrees = Double(separatedCoordinate[0].components(separatedBy: CharacterSet.decimalDigits.inverted)[1])
        let minutes = Double(separatedCoordinate[1].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let seconds = Double(separatedCoordinate[2].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let userLatitude = Double(separatedCoordinate[3].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        let userLongitude = Double(separatedCoordinate[4].components(separatedBy: CharacterSet.decimalDigits.inverted)[0])
        return convert(degrees: degrees!, minutes: minutes!, seconds: seconds!, direction: direction!)
   }
    public class ToastManager {
        // 单例
        public static let shared = ToastManager()
        // 默认样式
        public var style = ToastStyle()
        
        // 是否支持点击消失隐藏toast，默认是true
        public var isTapToDismissEnabled = true
        // 是否按照点击先后展示，还是立即展示出来
        public var isQueueEnabled = false
        // showToast 展示时间
        public var duration: TimeInterval = 3.0
        // 展示位置 ：默认是底部
        public var position: ToastPosition = .bottom
        
    }
    private func convert(degrees: Double, minutes: Double, seconds: Double, direction: String) -> Double {
        let sign = (direction == "W" || direction == "S") ? -1.0 : 1.0
        return (degrees + (minutes + seconds/60.0)/60.0) * sign
    }
}
extension UIView{
   func showToast2(text: String){
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
  }
}
extension UILabel
{
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }}}}
extension AppDelegate: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
    let clLocation = CLLocation(latitude: visit.coordinate.latitude, longitude: visit.coordinate.longitude)
  }
}
extension MKPointAnnotation {
    var mapItem: MKMapItem {
        let placemark = MKPlacemark(coordinate: self.coordinate)
        return MKMapItem(placemark: placemark)
}}
public extension UIView {
    func makeToast(_ message: String?, duration: TimeInterval = ToastManager.shared.duration, position: ToastPosition = ToastManager.shared.position, title: String? = nil, image: UIImage? = nil, style: ToastStyle = ToastManager.shared.style, completion: ((_ didTap: Bool) -> Void)? = nil) {
    }
}
