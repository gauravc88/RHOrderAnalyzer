import Foundation

public typealias BaseRestResponse = (Data?, URLResponse?, Error?) -> Void
public typealias InstrumentURLResponse = (Instrument?, Error?) -> Void
public typealias OrdersFromSymbolResponse = ([Order]?, Error?) -> Void
private typealias OrdersFromSymbolResponseWithResponseCode = ([Order]?, Error?, URLResponse?) -> Void

public class OrdersFromSymbol {
    
    public func getOrdersBySymbol(_ symbol: String, date: Date?, completionHandler: @escaping OrdersFromSymbolResponse) {
        // Retrieve the instrument url
        var dateString = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = date {
            dateString = dateFormatter.string(from: date)
        } else {
            dateString = dateFormatter.string(from: Date())
        }
        self.getInstrumentURLForSymbol(symbol, completionHandler: {
            (instrument, error) in
            guard error == nil else {
                completionHandler(nil, error!)
                return
            }
            
            if let instrument = instrument {
                //let encodedBody = try? JSONEncoder().encode(httpBody)
                let authorizer = Authorizer()
                if let authToken = Authorizer.authToken {
                    self.handleGetOrdersForSymbol(dateString, instrumentUrl: instrument.url, cursorUrl: nil, authToken: authToken, completionHandler: {
                        (orders, error, response) in
                        if let httpResponse = response as? HTTPURLResponse {
                            // Token expired, reauthorize
                            if httpResponse.statusCode == 401 {
                                authorizer.authorizeUser(completionHandler: {
                                    (token, error) in
                                    guard error == nil else {
                                        print("Error: Authorization for user failed")
                                        completionHandler(nil, error!)
                                        return
                                    }
                                    
                                    self.handleGetOrdersForSymbol(dateString, instrumentUrl: instrument.url, cursorUrl: nil, authToken: authToken, completionHandler: {
                                        (orders, error, response) in
                                        if let orders = orders {
                                            self.printProfitLossForRHOrders(symbol, orders: orders)
                                        }
                                        completionHandler(orders, error)
                                    })
                                })
                            } else {
                                if let orders = orders {
                                    self.printProfitLossForRHOrders(symbol, orders: orders)
                                }
                                completionHandler(orders, error)
                            }
                        }
                    })
                } else {
                    authorizer.authorizeUser(completionHandler: {
                        (token, error) in
                        guard error == nil else {
                            print("Error: Authorization for user failed")
                            completionHandler(nil, error!)
                            return
                        }
                        
                        
                        self.handleGetOrdersForSymbol(dateString, instrumentUrl: instrument.url, cursorUrl: nil, authToken: token!, completionHandler: {
                            (orders, error, response) in
                            if let orders = orders {
                                self.printProfitLossForRHOrders(symbol, orders: orders)
                            }
                            completionHandler(orders, error)
                        })
                    })
                }
                
                
               
            } else {
                completionHandler(nil, nil)
            }
        })
        
    }
    
    private func printProfitLossForRHOrders(_ symbol: String, orders: [Order]) {
        let orderManipulator = OrderManipulator.init(orders: orders)
        //print(orders)
        let profitOrLoss = orderManipulator.calculateProfitOrLoss()
         print("Buy Side quantity for Symbol(\(symbol)): \(orderManipulator.buySideQuantity)")
         print("Sell Side quantity for Symbol(\(symbol)): \(orderManipulator.sellSideQuantity)")
         print(profitOrLoss)
        
//                    let encodedResults = JSONEncoder()
//                    let jsonConvertedOrders = try encodedResults.encode(filteredResults)
//                    let stringOrders = String.init(data: jsonConvertedOrders, encoding: String.Encoding.utf8)
       // print(stringOrders)
    }
    
    private func handleGetOrdersForSymbol(_ dateString: String, instrumentUrl: String, cursorUrl: String? = nil, authToken: String, completionHandler: @escaping OrdersFromSymbolResponseWithResponseCode) {
        let orderURLString = RHApiConstants.getRHOrdersByInstrument(dateString, instrument: instrumentUrl, cursor: cursorUrl)
        let orderURL = URL(string: orderURLString)
        var urlRequest = URLRequest(url: orderURL!)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Token \(authToken)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                completionHandler(nil, error!, response)
                return
            }
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                completionHandler(nil, error, response)
                return
            }
            
            let decoder = JSONDecoder()
            do {
                if let rhOrderResponse: RHOrderResponse = try decoder.decode(RHOrderResponse.self, from: responseData) {
                    if let resultsList = rhOrderResponse.results {
                        //print(resultsList)
                        let filteredResults = resultsList.filter({ (order: Order) -> Bool in
                            if (order.state == "filled" || order.isOrderPartiallyFilled()) {
                               // print(order)
                                return true
                            } else {
                                return false
                            }
                        })
                       // print(filteredResults)
                        if let cursorUrl = rhOrderResponse.next {
                            let url = rhOrderResponse.extractCursorFromURL(cursorUrl)
                            //print(url)
                            self.handleGetOrdersForSymbol(dateString, instrumentUrl: instrumentUrl, cursorUrl: url, authToken: authToken, completionHandler: {
                                (orders, error, response) in
                               // print("Calling recursive call")
                                if let orders = orders {
                                    let addedResults = filteredResults + orders
                                    //print(addedResults)
                                    completionHandler(addedResults, nil, response)
                                } else {
                                    completionHandler(nil, nil, response)
                                }
                            })
                        } else {
                            completionHandler(filteredResults, nil, response)
                        }
                    } else {
                        completionHandler(nil, nil, response)
                    }
                }
            } catch {
                print("Error occured while parsing data")
                print(error)
                completionHandler(nil, error, response)
            }
            
        })
        task.resume()
    }
    
    public init() {
        
    }
    
    public func getInstrumentURLForSymbol(_ symbol: String, completionHandler: @escaping InstrumentURLResponse) {
        self.getInstrumentURLForSymbol(symbol: symbol, date: nil, completionHandler: {
            (instrument, error) in
            
            guard error == nil else {
                completionHandler(nil, error!)
                return
            }
            if let instrument = instrument {
                print(instrument)
            }
            completionHandler(instrument, error)
            return 
            
        })
    }

    private func getInstrumentURLForSymbol(symbol: String, date: Date?, completionHandler: @escaping InstrumentURLResponse) {
        let session = URLSession.shared
        let instrumentBySymbolString = RHApiConstants.getRHInstrumentBySymbolUrl(symbol: symbol)
        var urlRequest = URLRequest(url: URL(string: instrumentBySymbolString)!)
        urlRequest.httpMethod = "GET"
        print(urlRequest)
        let task = session.dataTask(with: urlRequest, completionHandler: {
            (data, response, error) in
            guard error == nil else {
                print("Error: error calling GET")
                completionHandler(nil, error!)
                return
            }
            
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                completionHandler(nil, error)
                return
            }
            
            let jsonDecoder = JSONDecoder()
            do {
                if let instrumentResponse: RHInstrumentResponse = try jsonDecoder.decode(RHInstrumentResponse.self, from: data!) {
                    completionHandler(instrumentResponse.getInstrumentObject(), nil)
                } else {
                    completionHandler(nil, nil)
                }
            } catch {
                completionHandler(nil, error)
            }
            
        })
        task.resume()
    }
}
