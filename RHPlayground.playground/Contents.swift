//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

var str = "Hello, playground"

let decoder = JSONDecoder()
if let filePath = Bundle.main.path(forResource: "JsonResponse", ofType: "txt") {
    let fileURL = URL.init(fileURLWithPath: filePath)
    do {
        if let rhOrderResponse: RHOrderResponse = try decoder.decode(RHOrderResponse.self, from: Data.init(contentsOf: fileURL)) {
            if let resultsList = rhOrderResponse.results {
                let filteredResults = resultsList.filter({ (order: Order) -> Bool in
                    if (order.state == "filled" || order.isOrderPartiallyFilled()) {
                        return true
                    } else {
                        return false
                    }
                })
            }
//            let orderManipulator = OrderManipulator.init(orders: filteredResults)
//            let profitOrLoss = orderManipulator.calculateProfitOrLoss()
//            print("Buy Side quantity: \(orderManipulator.buySideQuantity)")
//            print("Sell Side quantity: \(orderManipulator.sellSideQuantity)")
//            print(profitOrLoss)
            
//            let encodedResults = JSONEncoder()
//            let jsonConvertedOrders = try encodedResults.encode(filteredResults)
//            let stringOrders = String.init(data: jsonConvertedOrders, encoding: String.Encoding.utf8)
            //print(stringOrders)
            
        }
    } catch {
        print("Error occured while parsing data")
        print(error)
    }
}

let ordersFromSymbol = OrdersFromSymbol()
//ordersFromSymbol.getInstrumentURLForSymbol("VERI", completionHandler: {
//    (instrument, error) in
//    print(instrument?.url)
//    //print(error)
//
//})
ordersFromSymbol.getOrdersBySymbol("BBRY", date: nil, completionHandler: {
    (orders, error) in
    PlaygroundPage.current.finishExecution()
    //print(orders)
})
PlaygroundPage.current.needsIndefiniteExecution = true

