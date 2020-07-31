import Foundation
import CSourceKitD

internal struct SourceKitD {
    
    let path   = PlatformConfig.shared.sourcekitd
    let handle : UnsafeMutableRawPointer

    
    let initialize                    : @convention(c) () -> ()
    let shutdown                      : @convention(c) () -> ()
    let send_request_sync             : @convention(c) (sourcekitd_object_t) -> (sourcekitd_response_t?)
    let request_create_from_yaml      : @convention(c) (UnsafePointer<Int8>, UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>?) -> (sourcekitd_object_t?)
    let response_get_value            : @convention(c) (sourcekitd_response_t) -> (sourcekitd_variant_t)
    let variant_json_description_copy : @convention(c) (sourcekitd_variant_t) -> (UnsafeMutablePointer<Int8>?)
    let response_is_error             : @convention(c) (sourcekitd_response_t) -> (Bool)
    let response_error_get_kind       : @convention(c) (sourcekitd_response_t) -> (sourcekitd_error_t)
    let response_error_get_description: @convention(c) (sourcekitd_response_t) -> (UnsafePointer<Int8>?)
    let response_dispose              : @convention(c) (sourcekitd_response_t) -> ()
    let response_description_dump     : @convention(c) (sourcekitd_response_t) -> ()
    let request_description_dump      : @convention(c) (sourcekitd_object_t) -> ()
    
    init() {
        
        guard let handle = dlopen(path, RTLD_LAZY) else { fatalError("dlopen can't load : \(PlatformConfig.shared.sourcekitd)") }
        self.handle      = handle
    
        func load<T>(_ symbol: String) -> T {
            guard let imported = dlsym(handle, symbol) else { fatalError("dlsym: cant't link symbol: \(symbol)") }
            return unsafeBitCast(imported, to: T.self)
        }
        
        initialize                     = load("sourcekitd_initialize")
        shutdown                       = load("sourcekitd_shutdown")
        send_request_sync              = load("sourcekitd_send_request_sync")
        request_create_from_yaml       = load("sourcekitd_request_create_from_yaml")
        response_get_value             = load("sourcekitd_response_get_value")
        variant_json_description_copy  = load("sourcekitd_variant_json_description_copy")
        response_is_error              = load("sourcekitd_response_is_error")
        response_error_get_kind        = load("sourcekitd_response_error_get_kind")
        response_error_get_description = load("sourcekitd_response_error_get_description")
        response_dispose               = load("sourcekitd_response_dispose")
        response_description_dump      = load("sourcekitd_response_description_dump")
        request_description_dump       = load("sourcekitd_request_description_dump")
    }
    
}
