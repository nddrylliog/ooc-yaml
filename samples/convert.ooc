use yaml
import yaml/[Parser, Document, Convert]
import io/File
import structs/[HashBag, Bag]

main: func {
    parser := YAMLParser new(File new("convert.yml"))
    doc := parser parseDocument()
    root := doc getRootNode()

    convert := Converter new()
    m := convert to(root as MappingNode)

    // Extract a String
    name := m get("name", String)
    "name: #{name}" println()

    // Extract a Bool
    yes := m get("yes", Bool)
    "yes: #{yes}" println()

    // Extract a Long
    num := m get("num", Long)
    "num: #{num}" println()

    // Extract a Double
    percent := m get("percent", Double)
    "percent: #{percent}" println()

    // Extract null
    nothing := m get("empty", Pointer)
    "empty: #{nothing}" println()

    // Extract from HashBag
    distribution := m getPath("os/distribution", String)
    "distribution: #{distribution}" println()

    // Extract from Bag
    categories := m getPath("os/categories", Bag)
    "categories: %s, %s" printfln(categories get(0, String),
                                  categories get(1, String))
}
