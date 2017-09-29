import Foundation

public struct RHApiConstants {
    public static let rhApiBaseUrl = "https://api.robinhood.com"
    public static let rhApiOrdersOffset = "/orders"
    public static let rhApiUpdatedAtParameter = "/?updated_at=%@"
    public static let rhApiInstrumentUrlParameter = "&instrument=%@"
    public static let rhApiCursorUrlParameter = "&cursor=%@"
    public static let rhApiInstrumentsBySymbolOffset = "/instruments/?symbol=%@"
    public static let rhApiAuthOffset = "/api-token-auth/"
    
    public static func getRHOrdersByInstrument(_ date: String, instrument: String, cursor: String? = nil) -> String {
        if let cursorURL = cursor {
            return String(format: rhApiBaseUrl + rhApiOrdersOffset + rhApiUpdatedAtParameter + rhApiInstrumentUrlParameter + rhApiCursorUrlParameter, date, instrument, cursorURL)
        } else {
            return String(format: rhApiBaseUrl + rhApiOrdersOffset + rhApiUpdatedAtParameter + rhApiInstrumentUrlParameter, date, instrument)
        }
    }
    
    public static func getRHInstrumentBySymbolUrl(symbol: String) -> String {
        return String(format: rhApiBaseUrl + rhApiInstrumentsBySymbolOffset, symbol)
    }
    
    public static func getRHAuthUrl() -> String {
        return rhApiBaseUrl + rhApiAuthOffset
    }
}
