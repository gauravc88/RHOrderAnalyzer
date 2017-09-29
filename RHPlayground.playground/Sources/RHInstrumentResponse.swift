import Foundation

public struct RHInstrumentResponse: Codable {
    public var previous: String?
    public var next: String?
    public var results: [Instrument]
    
    public func getInstrumentObject() -> Instrument {
        return results.first!
    }
}
