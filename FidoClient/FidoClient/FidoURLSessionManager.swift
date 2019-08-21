import Foundation
import os.log
import SwiftyJSON

class FidoURLSessionManager {
    
    static func doRequest(with request: URLRequest) throws -> JSON {
        var result: JSON? = nil
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: request, completionHandler: {(data, response, error) in
            if error == nil {
                result = JSON(data as Any)
               
            } else {
                let errorString = "Error: " + error.debugDescription
                NSLog(errorString)
                
            }
             semaphore.signal()
        }).resume()
        
        semaphore.wait()
        
        if let requestResult = result{
            return requestResult
        }
        
        throw FidoError.networkRequestError
    }
}
