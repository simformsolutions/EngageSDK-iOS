//
//  UserDefault+Extension.swift
//  EngageSDK-iOS-Example
//
//  Created by ProximiPRO on 17/09/19.
//  Copyright © 2019 Poximi PRO. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    func save<T: Codable>(_ object: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let encodedObject = try? encoder.encode(object) {
            UserDefaults.standard.set(encodedObject, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getObject<T: Codable>(forKey key: String) -> T? {
        if let object = UserDefaults.standard.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let decodedObject = try? decoder.decode(T.self, from: object) {
                return decodedObject
            }
        }
        return nil
    }
    
}
