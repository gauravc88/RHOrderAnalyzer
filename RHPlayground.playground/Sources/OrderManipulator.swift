import Foundation

public class OrderManipulator {
    private var allOrders: [Order]
    var buySideOrders: [Order]?
    var sellSideOrders: [Order]?
    public var sellSideQuantity: Double = 0.0
    public var buySideQuantity: Double = 0.0
    
    public init(orders: [Order]) {
        self.allOrders = orders
        self.buySideOrders = self.allOrders.filter({ (order: Order) -> Bool in
            if (order.side == "buy") {
                return true
            } else {
                return false
            }
        })
        self.sellSideOrders = self.allOrders.filter({ (order: Order) -> Bool in
            if (order.side == "sell") {
                return true
            } else {
                return false
            }
        })
        
    }
    
    public func calculateBuyPrices() -> Double {
        var buyPrice = 0.0
        if let buySideOrders = self.buySideOrders {
            for order in buySideOrders {
                let price = order.average_price ?? order.price!
                if let price = Double(price), let quantity = Double(order.cumulative_quantity) {
                    let pricePaid = price * quantity
                    buySideQuantity = buySideQuantity + quantity
                    buyPrice = buyPrice + pricePaid
                }
            }
        }
        return buyPrice
    }
    
    public func calculateSellPrices() -> Double {
        var sellPrice = 0.0
        if let sellSideOrders = self.sellSideOrders {
            for order in sellSideOrders {
                let price = order.average_price ?? order.price
                if let price = price, let doublePrice = Double(price), let quantity = Double(order.cumulative_quantity) {
                    let pricePaid = doublePrice * quantity
                    sellSideQuantity = sellSideQuantity + quantity
                    sellPrice = sellPrice + pricePaid
                }
            }
        }
        return sellPrice
    }
    
    public func calculateProfitOrLoss() -> Double {
        return self.calculateSellPrices() - self.calculateBuyPrices()
    }
}
