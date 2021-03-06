
import Foundation
import CSourceKitD


public class SKHipster {
    
    
    let sdkpath = PlatformConfig.shared.sdk
    
    let file       : URL
    let sourcekitd : SourceKitD
    
    
    private init (file: URL) {
        self.file        = file
        self.sourcekitd  = SourceKitHipster.SourceKitD()
        sourcekitd.initialize()
    }
    
    
    public convenience init ( source: String ) {
        let tmp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("file.swift")
        do { try source.data(using: .utf8)!.write(to: tmp) }
        catch {
            print("error writing file '\(tmp.path)' : \(error)")
        }
        self.init(file: tmp)
    }
    
    public convenience init () {
        self.init( file: URL(fileURLWithPath: "ONLY_VALID_IF_YOU_INIT_WITH_SOURCE"))
    }
    
    deinit {
        // the only reason ths is a class is so we can do this ...
        sourcekitd.shutdown()
        try? FileManager.default.removeItem(at: file)
    }
    
    
    private func error ( _ value: String ) -> String {
        "{\"error\" : \"\(value)\"}"
    }
    
    // can't say I'm in love with that TBH, we get no error response
    func send ( request: sourcekitd_object_t?)  -> String {
        
        guard let request  = request
        else {
            return error("bad request construction")
        }
        
        guard let response = sourcekitd.send_request_sync(request)
        else {
            return error("empty response")
        }
        
        if true == sourcekitd.response_is_error(response), let description = sourcekitd.response_error_get_description(response) {
            return error(String(cString: description))
        }
        
        guard let json = sourcekitd.variant_json_description_copy(sourcekitd.response_get_value(response))
        else {
            return error("json cnstruction failed")
        }
        return String(cString: json)
    }

    
    
    public func syntaxMap() -> String {

        let request = sourcekitd.request_create_from_yaml(
            Yaml()
                .request( .editor_open )
                  .name      ( file.path )
                  .sourceFile( file.path )
                .string,
            nil
        )
        return send(request: request)
    }
    
    
    
    public func cursor ( offset: Int ) -> String {
        send( request : sourcekitd.request_create_from_yaml (
            Yaml()
                .request (.cursorinfo )
                  .offset      ( offset    )
                  .sourceFile  ( file.path )
                  .compilerArgs( [ "-sdk", sdkpath, file.path ] )
                .string,
            nil
        ))
    }
    
    
    public func yamlRequest ( yaml : Yaml ) -> String {
        send (
            request: sourcekitd.request_create_from_yaml(yaml.string, nil)
        )
    }
    
    public func yamlrequest ( yaml: String ) -> String {
        send(
            request : sourcekitd.request_create_from_yaml(yaml, nil)
        )
    }
    
    public func compilerVersion() -> String {
        send( request: sourcekitd.request_create_from_yaml (
            Yaml()
                .request(.compiler_version)
                .string,
            nil
        ))
    }
    
    
    public func protocolVersion() -> String {
        send( request: sourcekitd.request_create_from_yaml (
            Yaml()
                .request(.protocol_version)
                .string,
            nil
        ))
    }
    
}



