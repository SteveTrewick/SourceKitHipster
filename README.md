## Be a SourceKit Hipster!

Talk to SourceKit with YAML, get responses in JSON. Just like the cool kids!

SourceKit Hipster dynamically loads ```sourcekitd``` and maps a subset of its API into Swift which is exposed
to the user with a set of convenience APIs that work on a string and with a more fully functional YAML based API. 
It is designed to be a lightweight tool for talking to ```sourcekitd``` from Swift and not as a replacement for
a more complete (and better tested) tool like [SourceKitten](https://github.com/jpsim/SourceKitten).

All of the output from SourceKit Hipster is in JSON basically because we all know by now what to do when we see a JSON
payload.

Import and use it like this for the convenience APIs for small bits of code :

    import SourceKitHipster 
    let skh = SKHipster(source: "let a = 42")


Or like this if you want to work directly with the file system and use only the YAML APIs :

    import SourceKitHipster 
    let skh = SKHipster()


Note that if you do this the convenience APIs will not work.


## Convenience APIs

The convenience APIs are basically designed for feeding a syntax highlighter working on small chunks of code.
In fact SourceKit Hipster is a component of a syntax highlighter that I'm currently building.

**```public func syntaxMap() -> String```**

Executes a ```source.request.editor.open``` query and returns a JSON dictionary in response. 

```key.syntaxmap``` containins a basic list of tokens and their locations in the source code. 
```key.substructure``` contains  more detailed semantic information.


For the short code segment above this yields the following result :

    {
      "key.offset": 0,
      "key.length": 10,
      "key.diagnostic_stage": "source.diagnostic.stage.swift.parse",
      "key.syntaxmap": [
        {
          "key.kind": "source.lang.swift.syntaxtype.keyword",
          "key.offset": 0,
          "key.length": 3
        },
        {
          "key.kind": "source.lang.swift.syntaxtype.identifier",
          "key.offset": 4,
          "key.length": 1
        },
        {
          "key.kind": "source.lang.swift.syntaxtype.number",
          "key.offset": 8,
          "key.length": 2
        }
      ],
      "key.substructure": [
        {
          "key.kind": "source.lang.swift.decl.var.global",
          "key.accessibility": "source.lang.swift.accessibility.internal",
          "key.name": "a",
          "key.offset": 0,
          "key.length": 10,
          "key.nameoffset": 4,
          "key.namelength": 1
        }
      ]
    }

**```public func cursor ( offset: Int ) -> String```**

Executes a ```source.request.cursorinfo``` query and returns the results in JSON.

Cursor info requests return richer semantic data than the ```substrucure``` dictionary from ```syntaxMap```.
For example ```skh.cursor(offset: 4)``` yields the following about our ```a``` variable :

    {
      "key.kind": "source.lang.swift.decl.var.global",
      "key.name": "a",
      "key.usr": "s:4file1aSivp",
      "key.filepath": "/private/var/folders/3p/2ck5zzpn2f5910hgdf_711dr0000gn/T/file.swift",
      "key.offset": 4,
      "key.length": 1,
      "key.typename": "Int",
      "key.annotated_decl": "<Declaration>let a: <Type usr=\"s:Si\">Int</Type></Declaration>",
      "key.fully_annotated_decl": "<decl.var.global><syntaxtype.keyword>let</syntaxtype.keyword> <decl.name>a</decl.name>: <decl.var.type><ref.struct usr=\"s:Si\">Int</ref.struct></decl.var.type></decl.var.global>",
      "key.typeusr": "$sSiD"
    }

Importantly if you are building a highlighter that mimics your XCode styling, ```cursor``` provides one bit of information 
that I haven't noticed showing up anywhere else. If we run it on (e.g.) ```print("hello")``` we get the following from ```cursor(offset: 0)```

    {
      "key.kind": "source.lang.swift.ref.function.free",
      "key.name": "print(_:separator:terminator:)",
      "key.usr": "s:s5print_9separator10terminatoryypd_S2StF",
      "key.doc.full_as_xml": "<Function><Name>print(_:separator:terminator:)</Name><USR>s:s5print_9separator10terminatoryypd_S2StF</USR><Declaration>func print(_ items: Any..., separator: String = &quot; &quot;, terminator: String = &quot;\\n&quot;)</Declaration><CommentParts><Abstract><Para>Writes the textual representations of the given items into the standard output.</Para></Abstract><Parameters><Parameter><Name>items</Name><Direction isExplicit=\"0\">in</Direction><Discussion><Para>Zero or more items to print.</Para></Discussion></Parameter><Parameter><Name>separator</Name><Direction isExplicit=\"0\">in</Direction><Discussion><Para>A string to print between each item. The default is a single space (<codeVoice>&quot; &quot;</codeVoice>).</Para></Discussion></Parameter><Parameter><Name>terminator</Name><Direction isExplicit=\"0\">in</Direction><Discussion><Para>The string to print after all items have been printed. The default is a newline (<codeVoice>&quot;\\n&quot;</codeVoice>).</Para></Discussion></Parameter></Parameters><Discussion><Para>You can pass zero or more items to the <codeVoice>print(_:separator:terminator:)</codeVoice> function. The textual representation for each item is the same as that obtained by calling <codeVoice>String(item)</codeVoice>. The following example prints a string, a closed range of integers, and a group of floating-point values to standard output:</Para><CodeListing language=\"swift\"><zCodeLineNumbered><![CDATA[print(\"One two three four five\")]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[// Prints \"One two three four five\"]]></zCodeLineNumbered><zCodeLineNumbered></zCodeLineNumbered><zCodeLineNumbered><![CDATA[print(1...5)]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[// Prints \"1...5\"]]></zCodeLineNumbered><zCodeLineNumbered></zCodeLineNumbered><zCodeLineNumbered><![CDATA[print(1.0, 2.0, 3.0, 4.0, 5.0)]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[// Prints \"1.0 2.0 3.0 4.0 5.0\"]]></zCodeLineNumbered><zCodeLineNumbered></zCodeLineNumbered></CodeListing><Para>To print the items separated by something other than a space, pass a string as <codeVoice>separator</codeVoice>.</Para><CodeListing language=\"swift\"><zCodeLineNumbered><![CDATA[print(1.0, 2.0, 3.0, 4.0, 5.0, separator: \" ... \")]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[// Prints \"1.0 ... 2.0 ... 3.0 ... 4.0 ... 5.0\"]]></zCodeLineNumbered><zCodeLineNumbered></zCodeLineNumbered></CodeListing><Para>The output from each call to <codeVoice>print(_:separator:terminator:)</codeVoice> includes a newline by default. To print the items without a trailing newline, pass an empty string as <codeVoice>terminator</codeVoice>.</Para><CodeListing language=\"swift\"><zCodeLineNumbered><![CDATA[for n in 1...5 {]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[    print(n, terminator: \"\")]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[}]]></zCodeLineNumbered><zCodeLineNumbered><![CDATA[// Prints \"12345\"]]></zCodeLineNumbered><zCodeLineNumbered></zCodeLineNumbered></CodeListing></Discussion></CommentParts></Function>",
      "key.typename": "(Any..., String, String) -> ()",
      "key.annotated_decl": "<Declaration>func print(_ items: Any..., separator: <Type usr=\"s:SS\">String</Type> = &quot; &quot;, terminator: <Type usr=\"s:SS\">String</Type> = &quot;\\n&quot;)</Declaration>",
      "key.fully_annotated_decl": "<decl.function.free><syntaxtype.keyword>func</syntaxtype.keyword> <decl.name>print</decl.name>(<decl.var.parameter><decl.var.parameter.argument_label>_</decl.var.parameter.argument_label> <decl.var.parameter.name>items</decl.var.parameter.name>: <decl.var.parameter.type><syntaxtype.keyword>Any</syntaxtype.keyword></decl.var.parameter.type>...</decl.var.parameter>, <decl.var.parameter><decl.var.parameter.argument_label>separator</decl.var.parameter.argument_label>: <decl.var.parameter.type><ref.struct usr=\"s:SS\">String</ref.struct></decl.var.parameter.type> = &quot; &quot;</decl.var.parameter>, <decl.var.parameter><decl.var.parameter.argument_label>terminator</decl.var.parameter.argument_label>: <decl.var.parameter.type><ref.struct usr=\"s:SS\">String</ref.struct></decl.var.parameter.type> = &quot;\\n&quot;</decl.var.parameter>)</decl.function.free>",
      
      "key.is_system": 1,
      
      "key.typeusr": "$s_9separator10terminatoryypd_S2StcD",
      "key.groupname": "Misc",
      "key.modulename": "Swift",
      "key.related_decls": [
        {
          "key.annotated_decl": "<RelatedName usr=\"s:s5print_9separator10terminator2toyypd_S2Sxzts16TextOutputStreamRzlF\">print(_:separator:terminator:to:)</RelatedName>"
        }
      ]
    }

Here we have a ```key.is_system``` key which lets us know that a function, method or 
type is one provided by the toolchain. It will be absent otherwsie. In XCode theme parlance this is 'Project' vs 'Other'.


**```public func compilerVersion() -> String```**

**```public func protocolVersion() -> String```**

Do what you'd expect :

    // Compiler from XCode 12
    {
      "key.version_major": 5,
      "key.version_minor": 3,
      "key.version_patch": 0
    }
    
    // sourcekitd protocol version
    {
      "key.version_major": 1,
      "key.version_minor": 0
    }


## YAML APIs


**```public func yamlRequest ( yaml : Yaml ) -> String```**

All of SourceKit Hipster's internals construct YAML, pass this to ```sourcekitd``` and then convert the 
response to JSON. This is *by far* the least painful way of dealing with ```sourcekitd```. The YAML 
construction API is exposed by the ```SourceKitHipster.Yaml``` type. The YAML API knows enough
of SourceKit that it should be able to complete all the examples given in the 
[protocol documentaion](https://github.com/apple/swift/blob/master/tools/SourceKit/docs/Protocol.md)

Construct YAML queries like this :

    let request = Yaml()
                  .request     ( .cursorinfo )
                  .offset      ( offset    )
                  .sourceFile  ( file.path )
                  .compilerArgs( [ "-sdk", sdkpath, file.path ] )


    let json = skh.yamlRequest(yaml: request)


If you want to work on code that lives on your file system initialize ```SKHipster()``` and use exclusively
YAML queries. Note that if you need to supply an SDK path it  **must** be the same as your currently selected
toolchain.

## Errors

One of *two things* is going to happen. If SourceKit Hipster fails to locate and link an installed toolchain it will ```fatalError```

If you get something wrong in your YAML queries you *should* get an error response from ```sourcekitd``` in your JSON like :

    {"error" : "missing 'key.name'"}



## To Do

* Frankly I'm not married to the way I'm locating the toolchain.
* Or particularly happy with the singleton pattern there, a *true* hipster would use dependency injection for this.
* There are currently no unit tests (although most of them would be integration tests anyway)


## License

MIT

