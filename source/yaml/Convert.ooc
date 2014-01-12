include stdlib
use yaml
import yaml/Document
import structs/[HashBag, Bag]


strtol: extern func(const CString, Char**, Int) -> Long
strtod: extern func(const CString, Char**) -> Double


// Convert is a namespace for methods converting a DocumentNode to a Bag or
// HashBag.  Conversion is recursive.  Integers are stored as Longs, Floats are
// stored as Doubles.  Null and booleans are also handled.
Convert: class {
    // Converts a ScalarNode to a String
    fromScalar: static func(s: ScalarNode) -> String {
        return s toString()
    }

    // Converts an EmptyNode to ""
    fromEmpty: static func(s: EmptyNode) -> String {
        return ""
    }

    // Walks a SequenceNode, converting it to an Bag
    fromSequence: static func(s: SequenceNode) -> Bag {
        a := Bag new()
        s toList() each(|v|
           match (v class) {
               case MappingNode =>
                   a.add(fromMapping(v as MappingNode))
               case SequenceNode =>
                   a.add(fromSequence(v as SequenceNode))
               case EmptyNode =>
                   a.add(fromEmpty(v as EmptyNode))
               case ScalarNode =>
                    coerceScalar(a, fromScalar(v as ScalarNode))
           }
        )
        return a
    }

    // Walks a MappingNode, converting it to an HashBag
    fromMapping: static func(m: MappingNode) -> HashBag {
        h := HashBag new()
        m toHashMap() each(|k, v|
            match (v class) {
                case MappingNode =>
                    h.put(k, fromMapping(v as MappingNode))
                case SequenceNode =>
                    h.put(k, fromSequence(v as SequenceNode))
                case EmptyNode =>
                    h.put(k, fromEmpty(v as EmptyNode))
                case ScalarNode =>
                    coerceScalar(h, k, fromScalar(v as ScalarNode))
            }
        )
        return h
    }

    // Coerces a ScalarNode's String value to its true type, and puts it in a
    // Bag
    coerceScalar: static func ~bag (b: Bag, s: String) {
        // Coerce bool
        if (s == "true") {
            b.add(true)
            return
        }
        if (s == "false") {
            b.add(false)
            return
        }
        // Coerce null
        if (s == "" || s == "~" || s == "null" || s == "Null" || s == "NULL") {
            b.add(null)
            return
        }
        // Coerce Long
        out := gc_malloc(1) as Char*
        x := strtol(s clone() toCString(), out&, 10)
        if (out[0] == '\0' && s[0] != '\0') {
            b.add(x)
            return
        }
        // Coerce Double
        out[0] = '\0'
        y := strtod(s clone() toCString(), out&)
        if (out[0] == '\0' && s[0] != '\0') {
            b.add(y)
            return
        }
        // All coercions failed, must be a string
        b.add(s)
    }

    // Coerces a ScalarNode's String value to its true type, and puts it in a
    // HashBag
    coerceScalar: static func ~hashbag (h: HashBag, key, s: String) {
        // Coerce bool
        if (s == "true") {
            h.put(key, true)
            return
        }
        if (s == "false") {
            h.put(key, false)
            return
        }
        // Coerce null
        if (s == "" || s == "~" || s == "null" || s == "Null" || s == "NULL") {
            h.put(key, null)
            return
        }
        // Coerce Long
        out := gc_malloc(1) as Char*
        x := strtol(s clone() toCString(), out&, 10)
        if (out[0] == '\0' && s[0] != '\0') {
            h.put(key, x)
            return
        }
        // Coerce Double
        out[0] = '\0'
        y := strtod(s clone() toCString(), out&)
        if (out[0] == '\0' && s[0] != '\0') {
            h.put(key, y)
            return
        }
        // All coercions failed, must be a string
        h.put(key, s)
    }
}
