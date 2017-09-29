import Foundation

public struct RHOrderResponse: Codable {
    public var results: [Order]?
    public var previous: String?
    public var cursorUrl: String?
    public var next: String? {
        didSet {
            //print("Did set next url")
            self.cursorUrl = self.extractCursorFromURL(self.next!)
        }
    }
    
    public func extractCursorFromURL(_ nextUrl: String) -> String {
        let indexOfCursor = nextUrl.characters.split(separator: "=").map(String.init)
        if indexOfCursor.count > 1 {
            let withInstrument = indexOfCursor[1]
            let cursorUrl = withInstrument.characters.split(separator: "&").map(String.init)
            return cursorUrl[0]
        } else {
            return ""
        }
    }
}
