//
//  Data+Decodable.swift
//  GiraffeKit
//
//  Created by Evgen Dubinin on 7/8/16.
//  Copyright © 2016 Yevhen Dubinin. All rights reserved.
//

import Foundation

private typealias JSON = AnyObject
private typealias JSONDictionary = Dictionary<String, JSON>
private typealias JSONArray = Array<JSON>

// TODO: make it public, when client wants to get something more specific
enum DecodeError: ErrorType {
    case ParsingFailed()
}

extension Response: Decodable {
    public static func decodedFrom(data data: NSData, response: NSURLResponse) -> DecodingResult<Response> {
        do {
            let jsonOptional: JSON! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0))
        
            if let json = jsonOptional as? JSONDictionary {
                if let data = json["data"] as AnyObject? as? JSONArray {
                    var dataItems: [DataItem] = []
                    
                    for item in data {
                        if let id = item["id"] as AnyObject? as? String {
                            let meta = MetaData(id: id)
                            dataItems.append(DataItem(meta: meta))
                        }
                    }
                    return .Value(Response(data: dataItems))
                }
            }
            
            return .Error(DecodeError.ParsingFailed())
        } catch let JSONSerializationError {
            return .Error(JSONSerializationError)
        }
    }
}