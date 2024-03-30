//
//  ViewController.swift
//  Lab8_Weather_Ssodha
//
//  Created by user237598 on 3/29/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityNameL: UILabel!
    
    @IBOutlet weak var conditionL: UILabel!
    
    @IBOutlet weak var conditionImg: UIImageView!
    
    @IBOutlet weak var tempL: UILabel!
    
    @IBOutlet weak var humidityL: UILabel!
    
    @IBOutlet weak var windL: UILabel!
    
    private let locationManager = CLLocationManager()
    //my api key for openweaterapi
    private let apiKey = "7a64f892d1228553cf9d34431b8f6c1c"

    enum WeatherCondition: String {
        case rain = "Rain"
        case snow = "Snow"
        case sunny = "Clear"
        case unknown = "Unknown"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            currentWeather()
        }
    
    func currentWeather(){
        if CLLocationManager.locationServicesEnabled() {
                switch locationManager.authorizationStatus {
                case .authorizedWhenInUse, .authorizedAlways:
                    locationManager.requestLocation()
                case .denied, .restricted:
                    print("Allow Location!")
                case .notDetermined:
                    print("Can't determine access")
                    locationManager.requestWhenInUseAuthorization()
                @unknown default:
                    fatalError("Unhandled exception")
                }
            } else {
                print("Enabled Location!")
            }
    }
    
    func weatherData(latitude: Double, longitude: Double){
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=metric&appid=\(apiKey)"

            if let url = URL(string: urlString) {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, error == nil else {
                        print("Error: \(error?.localizedDescription ?? "Unknown error")")
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                if let cityName = json["name"] as? String,
                                   let weatherArray = json["weather"] as? [[String: Any]],
                                   let main = json["main"] as? [String: Any],
                                   let temperature = main["temp"] as? Double,
                                   let humidity = main["humidity"] as? Int,
                                   let wind = json["wind"] as? [String: Any],
                                   let windSpeed = wind["speed"] as? Double {
                                    
                                    // get weather condition
                                    if let weatherMain = weatherArray.first?["main"] as? String {
                                        var weatherIconName: String
                                        var weatherConditionText: String
                                        
                                        // set image and label according to condition of weather
                                        switch weatherMain.lowercased() {
                                        case "rain":
                                            weatherIconName = "rain"
                                            weatherConditionText = "Rainy"
                                        case "snow":
                                            weatherIconName = "snow"
                                            weatherConditionText = "Snowy"
                                        default:
                                            weatherIconName = "sunny"
                                            weatherConditionText = "Sunny"
                                        }
                                        
                                        let tempC = temperature.rounded()
                                        let windKm = (windSpeed * 3.6).rounded()
                                        
                                        DispatchQueue.main.async {
                                            // show values in image and labels
                                            self.conditionImg.image = UIImage(named: weatherIconName)
                                            self.conditionL.text = weatherConditionText
                                            self.cityNameL.text = cityName
                                            self.tempL.text = "\(tempC)°"
                                            self.humidityL.text = "Humidity: \(humidity)%"
                                            self.windL.text = "Wind Speed: \(windKm) km/h"
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error.localizedDescription)")
                        }
                    }
                }
                task.resume()
            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            weatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Can't get location: \(error.localizedDescription)")
    }


}

