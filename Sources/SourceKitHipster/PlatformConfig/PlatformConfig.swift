


import Foundation

internal struct PlatformConfig {
    
    
    static let shared = PlatformConfig()
    
    let sdk        : String
    let sourcekitd : String
    
    private init() {
        sdk        = PlatformConfig.locateSDK()
        sourcekitd = sdk.replacingOccurrences (
            of  : "Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk",
            with: "Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/Versions/A/sourcekitd"
        )
    }
    
    private static func locateSDK() -> String {
        let xcrun = Process()
        let pipe  = Pipe()
        
        xcrun.executableURL  = URL(fileURLWithPath: "/usr/bin/env")
        xcrun.arguments      = ["xcrun", "--show-sdk-path"]
        xcrun.standardOutput = pipe
        
        do {
            try xcrun.run()
        }
        catch {
            fatalError("error locating developer SDK \(error)")
        }
        xcrun.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: String.Encoding.utf8) {
            return output.last! == "\n" ? String(output.dropLast()) : output
        }
        fatalError("unitelligible output from xcrun command, cannot locate developer SDK")
    }
}
