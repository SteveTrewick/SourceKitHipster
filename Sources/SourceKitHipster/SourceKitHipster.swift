
import Foundation
import CSourceKitD


public struct SouceKitHipster {
    
    
    let sdkpath = PlatformConfig.shared.sdk
    
    let file    : URL
    let source  : String
    let dylib   : SourceKit
    
    public init ( source: String ) {
        
        self.source  = source
        self.file    = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent("file.swift")
        self.dylib   = SourceKitHipster.SourceKit()!
        
        do { try source.data(using: .utf8)!.write(to: file) }
        catch {
            print("error writing file '\(file.path)' : \(error)")
        }
        dylib.sourcekitd_initialize()
    }
    
    
    public func shutdown() {
        dylib.sourcekitd_shutdown()
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
        
        guard let response = dylib.sourcekitd_send_request_sync(request)
        else {
            return error("empty response")
        }
        
        if true == dylib.sourcekitd_response_is_error(response), let description = dylib.sourcekitd_response_error_get_description(response) {
            return error(String(cString: description))
        }
        
        guard let json = dylib.sourcekitd_variant_json_description_copy(dylib.sourcekitd_response_get_value(response))
        else {
            return error("json cnstruction failed")
        }
        return String(cString: json)
    }

    
    
    public func syntaxMap() -> String {

        let request = dylib.sourcekitd_request_create_from_yaml(
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
        send( request : dylib.sourcekitd_request_create_from_yaml (
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
            request: dylib.sourcekitd_request_create_from_yaml(yaml.string, nil)
        )
    }
    
    public func yamlrequest ( yaml: String ) -> String {
        send(
            request : dylib.sourcekitd_request_create_from_yaml(yaml, nil)
        )
    }
    
    public func compilerVersion() -> String {
        send( request: dylib.sourcekitd_request_create_from_yaml (
            Yaml()
                .request(.compiler_version)
                .string,
            nil
        ))
    }
    
    
    public func protocolVersion() -> String {
        send( request: dylib.sourcekitd_request_create_from_yaml (
            Yaml()
                .request(.protocol_version)
                .string,
            nil
        ))
    }
    
}



