use yaml
import yaml/[Parser, Document, Convert]
import io/File
import structs/[HashBag, Bag]

main: func {
    parser := YAMLParser new(File new("convert.yml"))
    doc := parser parseDocument()
    root := doc getRootNode()

    m := Convert to(root as MappingNode)

    name := m get("name", String)
    "name: #{name}" println()

    // Extract from HashBag
    distribution := m getPath("os/distribution", String)
    "distribution: #{distribution}" println()

    // Extract from Bag
    categories := m getPath("os/categories", Bag)
    "categories: %s, %s" printfln(categories get(0, String),
                                  categories get(1, String))
}
