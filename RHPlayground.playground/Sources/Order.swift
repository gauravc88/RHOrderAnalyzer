import Foundation

public struct Order: Codable {
    public var instrument: String
    public var state: String
    public var type: String
    public var price: String?
    public var side: String
    public var average_price: String?
    public var quantity: String
    public var cumulative_quantity: String
    
    public func isOrderPartiallyFilled() -> Bool {
        if self.state == "cancelled" && self.average_price != nil {
            return true
        } else {
            return false
        }
    }
}
