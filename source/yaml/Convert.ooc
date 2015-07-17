include stdlib
include errno
use yaml
import yaml/Document
import structs/[HashBag, Bag]


ERANGE: extern Int
strtol: extern func(const CString, Char**, Int) -> Long
strtod: extern func(const CString, Char**) -> Double

// Coerces a String to a Bool, null, Long, Double or String. cb is a generic
// callback that receives the coerced value
coerceString: func (s: String, cb: Func <T> (T)) {
    if (s == "true") {
        cb(true)
        return
    }
    if (s == "false") {
        cb(false)
        return
    }
    if (s == "" || s == "~" || s == "NULL" || s == "Null" || s == "null") {
        cb(null)
        return
    }
    out := gc_malloc(1) as Char*
    x := strtol(s clone() toCString(), out&, 10)
    if (out[0] == '\0' && s[0] != '\0') {
        cb(x)
        return
    }
    out[0] = '\0'
    y := strtod(s clone() toCString(), out&)
    if (out[0] == '\0' && s[0] != '\0' && errno != ERANGE) {
        cb(y)
        return
    }
    cb(s)
}

// Convert is a namespace for methods converting a DocumentNode to a Bag,
// HashBag or String.  Strings are converted to Bool, Long, Double or null
// if they appear to be of that type.  To disable String conversion,
// coerce may be set to false.
Converter: class {
    // Attempt to coerce Strings to intended type
    coerce := true

    init: func ~default() {}
    init: func(=coerce) {}

    // Converts a ScalarNode to a String
    to: func ~scalar(s: ScalarNode) -> String {
        return s toString()
    }

    // Walks a SequenceNode, converting it to an Bag
    to: func ~sequence(s: SequenceNode) -> Bag {
        a := Bag new()
        s toList() each(|v|
           match (v class) {
               case MappingNode =>
                   a add(to(v as MappingNode))
               case SequenceNode =>
                   a add(to(v as SequenceNode))
               case EmptyNode =>
                   a add(null)
               case ScalarNode =>
                    if (coerce) {
                        coerceString(to(v as ScalarNode), |x| a add(x))
                    } else {
                        a add(to(v as ScalarNode))
                    }
           }
        )
        return a
    }

    // Walks a MappingNode, converting it to an HashBag
    to: func ~mapping(m: MappingNode) -> HashBag {
        h := HashBag new()
        m toHashMap() each(|k, v|
            match (v class) {
                case MappingNode =>
                    h put(k, to(v as MappingNode))
                case SequenceNode =>
                    h put(k, to(v as SequenceNode))
                case EmptyNode =>
                    h put(k, null)
                case ScalarNode =>
                    if (coerce) {
                        coerceString(to(v as ScalarNode), |x| h put(k, x))
                    } else {
                        h put(k, to(v as ScalarNode))
                    }
            }
        )
        return h
    }
}
