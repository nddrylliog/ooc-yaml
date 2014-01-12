include stdlib
use yaml
import yaml/Document
import structs/[HashBag, Bag]


strtol: extern func(const CString, Char**, Int) -> Long
strtod: extern func(const CString, Char**) -> Double


// Convert is a namespace for methods converting a DocumentNode to a Bag,
// HashBag or String
Convert: class {

    // Converts a ScalarNode to a String
    to: static func ~scalar(s: ScalarNode) -> String {
        return s toString()
    }

    // Walks a SequenceNode, converting it to an Bag
    to: static func ~sequence(s: SequenceNode) -> Bag {
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
                    a add(to(v as ScalarNode))
           }
        )
        return a
    }

    // Walks a MappingNode, converting it to an HashBag
    to: static func ~mapping(m: MappingNode) -> HashBag {
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
                    h put(k, to(v as ScalarNode))
            }
        )
        return h
    }
}
