import Foundation
import CSourceKitD

internal struct SourceKit {
    
    let path   = PlatformConfig.shared.sourcekitd
    let handle : UnsafeMutableRawPointer

    
    let sourcekitd_initialize                    : @convention(c) () -> ()
    let sourcekitd_shutdown                      : @convention(c) () -> ()
    let sourcekitd_send_request_sync             : @convention(c) (sourcekitd_object_t) -> (sourcekitd_response_t?)
    let sourcekitd_request_create_from_yaml      : @convention(c) (UnsafePointer<Int8>, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> (sourcekitd_object_t?)
    let sourcekitd_response_get_value            : @convention(c) (sourcekitd_response_t) -> (sourcekitd_variant_t)
    let sourcekitd_variant_json_description_copy : @convention(c) (sourcekitd_variant_t) -> (UnsafeMutablePointer<Int8>?)
    let sourcekitd_response_is_error             : @convention(c) (sourcekitd_response_t) -> (Bool)
    let sourcekitd_response_error_get_kind       : @convention(c) (sourcekitd_response_t) -> (sourcekitd_error_t)
    let sourcekitd_response_error_get_description: @convention(c) (sourcekitd_response_t) -> (UnsafePointer<Int8>?)
    let sourcekitd_response_dispose              : @convention(c) (sourcekitd_response_t) -> ()
    let sourcekitd_response_description_dump     : @convention(c) (sourcekitd_response_t) -> ()
    let sourcekitd_request_description_dump      : @convention(c) (sourcekitd_object_t) -> ()
    
    init?() {
        
        guard let handle = dlopen(path, RTLD_LAZY) else { return nil }
        self.handle      = handle
    
        func load<T>(_ symbol: String) -> T {
            guard let imported = dlsym(handle, symbol) else { fatalError("dlsym: cant't link symbol: \(symbol)") }
            return unsafeBitCast(imported, to: T.self)
        }
        
        sourcekitd_initialize                     = load("sourcekitd_initialize")
        sourcekitd_shutdown                       = load("sourcekitd_shutdown")
        sourcekitd_send_request_sync              = load("sourcekitd_send_request_sync")
        sourcekitd_request_create_from_yaml       = load("sourcekitd_request_create_from_yaml")
        sourcekitd_response_get_value             = load("sourcekitd_response_get_value")
        sourcekitd_variant_json_description_copy  = load("sourcekitd_variant_json_description_copy")
        sourcekitd_response_is_error              = load("sourcekitd_response_is_error")
        sourcekitd_response_error_get_kind        = load("sourcekitd_response_error_get_kind")
        sourcekitd_response_error_get_description = load("sourcekitd_response_error_get_description")
        sourcekitd_response_dispose               = load("sourcekitd_response_dispose")
        sourcekitd_response_description_dump      = load("sourcekitd_response_description_dump")
        sourcekitd_request_description_dump       = load("sourcekitd_request_description_dump")
    }
    
}
