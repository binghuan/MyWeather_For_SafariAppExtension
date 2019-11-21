//
//  SafariExtensionHandler.swift
//  MyWeather Extension
//
//  Created by BH_Lin on 2019/11/12.
//  Copyright © 2019 Studio Bing-Huan. All rights reserved.
//

import SafariServices

class SafariExtensionHandler: SFSafariExtensionHandler {
    
    
    
    // MARK: override func by defaults ---------------------------------------->
    
    override func messageReceived(withName messageName: String, from page: SFSafariPage, userInfo: [String : Any]?) {
        
        // This method will be called when a content script provided by your extension calls safari.extension.dispatchMessage("message").
        page.getPropertiesWithCompletionHandler { properties in
            NSLog("The extension received a message (\(messageName)) from a script injected into (\(String(describing: properties?.url))) with userInfo (\(userInfo ?? [:]))")
            let geolocation = messageName.split{$0 == ","}.map(String.init)
            let latitude = geolocation[0]
            let longitude = geolocation[1]
            
            UserDefaults.standard.set(latitude, forKey: "latitude")
            UserDefaults.standard.set(longitude, forKey: "longitude")
            
            self.requestWeatherData(latitude: latitude, longitude: longitude)
        }
    }
    
    override func toolbarItemClicked(in window: SFSafariWindow) {
        // This method will be called when your toolbar item is clicked.
        if(DBG){NSLog("The extension's toolbar item was clicked")}
        
        guard let myUrl = URL(string: DEF_WEB_APP_FOR_GEOLOCATION) else { return  }
        
        // This grabs the active window.
        SFSafariApplication.getActiveWindow { (activeWindow) in
            
            // Request a new tab on the active window, with the URL we want.
            activeWindow?.openTab(with: myUrl,
                                  makeActiveIfPossible: true, completionHandler: {_ in
                                    // Perform some action here after the page loads if you'd like.
            })
        }
    }
    
    override func validateToolbarItem(in window: SFSafariWindow, validationHandler: @escaping ((Bool, String) -> Void)) {
        NSLog(">> validateToolbarItem")
        // This is called when Safari's state changed in some way that would require the extension's toolbar item to be validated again.
        validationHandler(true, "")
        
        // Restore Last Weather Data first
        restoreWeatherInfo()
        
        // And then, try to get latest weather info.
        let diff = getDiffTimeBetweenLastAndNow()
        if(diff > DEFAULT_DIFF_THRESH_HOLD) {
            
            guard let latitude = UserDefaults.standard.string(forKey: "latitude") else { return}
            guard let longitude = UserDefaults.standard.string(forKey: "longitude") else { return}
            
            requestWeatherData(latitude: latitude, longitude: longitude)
        }
    }
    
    override func popoverViewController() -> SFSafariExtensionViewController {
        if(DBG){NSLog(">> popoverViewController")}
        return SafariExtensionViewController.shared
    }
    // MARK: override func by defaults ----------------------------------------<
    
    let DBG = true
    
    // MARK: functions to extract data from JSON ------------------------------>
    func extractTempCDirectly(data: Data) {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if(DBG) {NSLog("\(json)")}
            
            if let dictionary = json as? [String: Any] {
                if let nestedDictionary = dictionary["data"] as? [String: Any] {
                    if let currentCondition = nestedDictionary["current_condition"] as? [[String: Any]] {
                        if(DBG){NSLog("\(currentCondition)")}
                        let item = currentCondition[0]
                        if(DBG){NSLog("\(item)")}
                        let tempC = item["temp_C"] as! String
                        if(DBG){NSLog("OK> tempC = \(tempC)")}
                        
                        SFSafariApplication.getActiveWindow { (window) in
                            window?.getToolbarItem { $0?.setBadgeText(tempC + " ℃")}
                            UserDefaults.standard.set(tempC + " ℃", forKey: "temp_C")
                        }
                    }
                }
            }
        } catch {
            NSLog("NG> JSON error: \(error.localizedDescription)")
        }
    }
    
    func extractTempCByModel(data: Data) {
        do {
            //here dataResponse received from a network request
            let decoder = JSONDecoder()
            if(DBG){NSLog("[[START to decoder]]")}
            let model = try decoder.decode(WeatherResponse.self, from:data) //Decode JSON Response Data
            if(DBG){NSLog("[[END to decoder]]")}
            if(DBG){NSLog("\(model)")}
            if(DBG){NSLog("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")}
            
            let tempC = model.data.current_condition[0].temp_C
            let description = model.data.current_condition[0].weatherDesc[0].value;
            let iconUrl = URL(string: model.data.current_condition[0].weatherIconUrl[0].value)!
            if(DBG){NSLog("OK> tempC = \(tempC)")}
            
            markLastUpdateTime()// save the timestamp
            
            SFSafariApplication.getActiveWindow { (window) in
                window?.getToolbarItem {
                    $0?.setBadgeText(tempC + " ℃")
                    $0?.setLabel(description)
                    self.downloadImage(toolbarItem: $0!, from: iconUrl);
                }
                UserDefaults.standard.set(tempC + " ℃", forKey: "temp_C")
                UserDefaults.standard.set(description, forKey: "temp_Desc");
            }
            
        } catch {
            if(DBG){NSLog("NG> JSON error: \(error.localizedDescription)")}
        }
    }
    // MARK: functions to extract data from JSON ------------------------------<
    
    // MARK: functions to request network data -------------------------------->
    func getNetworkData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(toolbarItem: SFSafariToolbarItem, from url: URL) {
        if(DBG){NSLog(">> [[ START ]] downloadImage")}
        getNetworkData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            if(self.DBG){NSLog(">> [[ END ]] downloadImage")}
            DispatchQueue.main.async() {
                toolbarItem.setImage(NSImage(data: data))
                UserDefaults.standard.set(data, forKey: "temp_Image")
            }
        }
    }
    
    let API_KEY = "9294b70cef8f4bc4852164446191311";
    
    func requestWeatherData(latitude: String, longitude: String) {
        
        let url2RequestData = "https://api.worldweatheronline.com/premium/v1/weather.ashx?q="
            + latitude + "," + longitude + "&format=json&num_of_days=5&key=" + API_KEY;
        let url = URL(string: url2RequestData)!
        
        if(DBG){NSLog("request data by using URL: \(url2RequestData)")}
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            
            if error != nil || data == nil {
                if(self.DBG){NSLog("NG> Client error!")}
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                if(self.DBG){NSLog("NG> Server error!")}
                return
            }
            
            guard let mime = response.mimeType, mime == "application/json" else {
                if(self.DBG){NSLog("NG> Wrong MIME type!")}
                return
            }
            
            self.extractTempCByModel(data: data!);
            //self.extractTempCDirectly(data: data!);
        }
        task.resume()
    }
    
    func restoreWeatherInfo() {
        let tempC = UserDefaults.standard.string(forKey: "temp_C")
        if(DBG){NSLog(">> Try to restoreWeatherInfo: \(String(describing: tempC))")}
        
        if(tempC != nil && !tempC!.isEmpty) {
            SFSafariApplication.getActiveWindow { (window) in
                window?.getToolbarItem {
                    $0?.setBadgeText(tempC)
                    let imageData = UserDefaults.standard.object(forKey: "temp_Image")
                    if(imageData != nil) {
                        $0?.setImage(NSImage(data: imageData as! Data))
                    }
                    
                    let tempDesc = UserDefaults.standard.string(forKey:"temp_Desc")
                    if(tempDesc != nil) {
                        $0?.setLabel(tempDesc)
                    }
                }
            }
        } else {
            SFSafariApplication.getActiveWindow { (window) in
                window?.getToolbarItem {
                    $0?.setBadgeText(nil)
                    $0?.setImage(NSImage(named: "NSRevealFreestandingTemplate"))
                }
            }
        }
    }
    
    // MARK: functions to request network data --------------------------------<
    
    // MARK: functions to compare timestamps ---------------------------------->
    func getLastUpdateTime() -> NSDate {
        var lastDate = UserDefaults.standard.object(forKey: "timestamp")
        if(lastDate == nil) {
            lastDate = NSDate()
        }
        return lastDate as! NSDate
    }
    
    func markLastUpdateTime() {
        let timestamp = NSDate()
        UserDefaults.standard.set(timestamp, forKey: "timestamp")
    }
    
    func getDiffTimeBetweenLastAndNow() -> Int {
        let lastUpdatedTime = getLastUpdateTime()
        let timestamp = NSDate()
        let diff = Int(timestamp.timeIntervalSince1970 - lastUpdatedTime.timeIntervalSince1970)
        if(DBG) {NSLog("Diff time = \(diff) between \(timestamp.timeIntervalSince1970) and \(lastUpdatedTime.timeIntervalSince1970)")}
        return diff
    }
    
    let DEFAULT_DIFF_THRESH_HOLD = 60*20 // 20 Minutes => 1200 seconds
    //let DEFAULT_DIFF_THRESH_HOLD = 3 // 3 seconds for Testing.
    // MARK: functions to compare timestamps ----------------------------------<
    
    // MARK: Others ----------------------------------------------------------->
    let DEF_WEB_APP_FOR_GEOLOCATION = "https://request-always-authorization.web.app"
    // MARK: Others -----------------------------------------------------------<
}

/*
 // Javascript Code to send message to Safari App Extension
 window.postMessage({
 "command": "message_from_binghuan_webapp_requestlocation",
 "lat": 25.01924,
 "lng": 121.54738
 }, "*");
 */
