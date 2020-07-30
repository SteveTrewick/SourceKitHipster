
import Foundation



public enum SKKey : String {
    
    case codecompleteopts     = "key.codecomplete.options"
    case compilerargs         = "key.compilerargs"
    case name                 = "key.name"
    case offset               = "key.offset"
    case request              = "key.request"
    case sourcefile           = "key.sourcefile"
    case sourcetext           = "key.sourcetext"
    case usr                  = "key.usr"
}

public enum SKRequestUID : String {
    case editor_open           = "source.request.editor.open"
    case codecomplete          = "source.request.codecomplete"
    case codecomplete_open     = "source.request.codecomplete.open"
    case cursorinfo            = "source.request.cursorinfo"
    case demangle              = "source.request.demangle"
    case mangle_simple_class   = "source.request.mangle_simple_class"
    case docinfo               = "source.request.docinfo"
    case editor_open_interface = "source.request.editor.open.interface"
    case indexsource           = "source.request.indexsource"
    case protocol_version      = "source.request.protocol_version"
    case compiler_version      = "source.request.compiler_version"
}


public class Yaml {
   
    public var string = ""
    
    private func add ( key: SKKey, value: String )  -> Self {
        string += "\(key.rawValue) : \(value)\n"
        return self
    }
    
    
    private func quoted ( _ string: String ) -> String {
        return "\"\(string)\""
    }
    
    
    public func codecompleteOpts ( _ value: [String] ) -> Self {
        add(key: .codecompleteopts, value: "[\(value.map {"\"\($0)\""}.joined(separator: ","))]")
    }
    
    public func compilerArgs ( _ value: [String] ) -> Self {
        add(key: .compilerargs, value: "[\(value.map {"\"\($0)\""}.joined(separator: ","))]")
    }
    
    
    public func name (_ value: String ) -> Self {
        add(key: .name, value: quoted(value))
    }
    
    public func offset ( _ value: Int ) -> Self {
        add(key: .offset, value: String(value))
    }

    
    public func request ( _ value: SKRequestUID ) -> Self {
        add(key: .request, value: value.rawValue)
    }
    
    public func sourceFile ( _ value: String ) -> Self {
        add(key: .sourcefile, value: quoted(value))
    }
    
    
    public func sourceText ( _ value: String ) -> Self {
        add(key: .sourcetext, value: quoted(value))
    }

    
    public func usr ( _ value: String ) -> Self {
        add(key: .usr, value: quoted(value))
    }
}



