//
//  ViewController.swift
//  Lab3Weather1202507
//
//  Created by Goodwin on 2024-03-10.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchTextLocation: UITextField!
    
    @IBOutlet weak var weatherCondition: UIImageView!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var locationLabel: UILabel!
    
    private let locationManager = CLLocationManager()

    var isFahrenheit = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        displayWeatherImage()
        searchTextLocation.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        weatherSearchLoad(search: searchTextLocation.text)
        return true
    }
    
    private func displayWeatherImage(){
        
        weatherCondition.image = UIImage(systemName: "sun.horizon.fill")
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemGray,.systemYellow
        ])
        weatherCondition.preferredSymbolConfiguration = config
    }
    
    
    
    @IBAction func currentLocation(_ sender: UIButton) {
        locationManager.requestLocation()
        
    }
    
    @IBAction func switchTemperature(_ sender: UISwitch) {
        isFahrenheit.toggle()
        weatherSearchLoad(search: searchTextLocation.text)
        
    }
    
    @IBAction func searchLocation(_ sender: UIButton) {
        weatherSearchLoad(search: searchTextLocation.text)
    }
    
    
    private func weatherSearchLoad(search:String?){
        guard let search = search else{
            return
        }
        //        get URL
        guard let url=getURL(query: search) else{
            print("Could not get url !!")
            return
        }
        
       //    Create url session
        let session=URLSession.shared
//        step 3  creating task for session
        let dataTask=session.dataTask(with: url) { data, response, error in
//        Network call back finished
            print("Network call complete")
            guard error==nil else{
                print("Error occurred")
                return
            }
            guard let data = data else{
                print("Data not found")
                return
            }
            
            if let weatheresponse = self.parseJson(data: data) {
                
                DispatchQueue.main.async {
                    
                    let temperature = self.isFahrenheit ? "\(weatheresponse.current.temp_c)°C" : "\(weatheresponse.current.temp_f)°F"


                     self.temperatureLabel.text = temperature
                    
                       self.locationLabel.text = "\(weatheresponse.location.name)"
                   }
            }
        }
//        step 4 start Task
        dataTask.resume()
    }
    
    private func getURL(query:String)->URL?{
        let baseURL="https://api.weatherapi.com/v1/"
        let currentEndPoint="current.json"
        let apiKey="8c4e72f629ff4b4ab7503638241303"
        let url = "\(baseURL)\(currentEndPoint)?key=\(apiKey)&q=\(query)"
        return URL(string: url)
    }
    private func parseJson(data: Data)->weatherResponse?{
        let decoder=JSONDecoder()
        var weather:weatherResponse?
        do{
            weather = try decoder.decode(weatherResponse.self, from: data)
        }catch{
            print("Error Decoding")
        }
       return weather
    }
    
}

struct weatherResponse: Decodable{
    let location: Location
    let current: Weather
}
struct Location: Decodable {
    let name: String
}
struct Weather: Decodable{
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}
struct WeatherCondition: Decodable{
    let text: String
    let code: Int
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitute = location.coordinate.longitude
            print("My location \(latitude)\(longitute)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error")
    }

}
