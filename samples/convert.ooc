use yaml
import yaml/[Parser, Document, Convert]
import io/File
import structs/[HashBag, Bag]

main: func {
    parser := YAMLParser new(File new("bottle.yml"))
    doc := parser parseDocument()
    root := doc getRootNode()

    m := Convert fromMapping(root as MappingNode)

    name := m get("name", String)
    "name: #{name}" println()

    // Extract a Long
    year := m get("year", Long)
    "year: #{year}, type: #{year class name}" println()

    // Extract a Double
    price := m get("price", Double)
    "price: #{price}, type: #{price class name}" println()

    // Extract null
    ignore := m get("ignore", Pointer)
    "ignore: #{ignore}, type #{ignore class name}" println()

    // Extract true, false
    is_true := m get("is_true", Bool)
    "is_true: #{is_true}, type #{is_true class name}" println()
    is_false := m get("is_false", Bool)
    "is_false: #{is_false}, type #{is_false class name}" println()

    // Extract from HashBag and Bag
    platforms := m get("platforms", Bag)
    lin := platforms get(0, HashBag)
    linName := lin get("os", String)
    "os #{linName}" println()
    linDist := lin get("distribution", String)
    "distribution: #{linDist}" println()
    linSetup := lin get("setup", Bag) get(0, String)
    "setup: #{linSetup}" println()
}
