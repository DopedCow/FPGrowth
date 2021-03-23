module types

export Tree, Node, insert_node, update_node!

#=
    Node
=#
"""
"""
mutable struct Node
    id::Int
    label::String
    parent::Int
    children::Vector{Int}
    siblings::Vector{Int}
    support::Int

    function Node(; id = 0,
                    label = "",
                    parent = 0,
                    children = Int[],
                    siblings = Int[],
                    support = 0)

        new(id, label, parent, children, siblings, support)
    end

    Node(id, label, parent, children, siblings, support) = new(id, label, parent, children, siblings, support)

end


#=
    Tree
=#
"""
"""
mutable struct Tree
    nodes::Vector{Node}
    ids::Vector{Int}
    labels::Vector{String}
    size::Int


    function Tree(; nodes = Node[],
        ids = Int[],
        labels = String[],
        size = 0)

        new(nodes, ids, labels, size)
    end

    Tree(nodes, ids, labels, size) = new(nodes, ids, labels, size)

end


#=
    Pretty print functions
=#
"""
"""
function Base.show(io::IO, tree::Tree)
    @info "FP Growth Tree"
    @info "Nodes..."
    foreach(x -> println("--", x), tree.nodes)
end


#=
    Manipulating nodes
=#
"""
"""
function insert_node(tree::Tree, label::String, parent::Int)
    tree.size += 1
    id = tree.size
    push!(tree.nodes, Node(id = id, label = label, parent = parent))
    push!(tree.labels, label)
    @info "Added node number $id with the label $label" "Updated .labels on tree"
end


"""
    update_node!(node)

Increases the support count of the supplied node by 1.
"""
update_node!(node::Node) = node.support += 1

"""
    test_functionality()

TODO: Move to dedicated test script
"""
function test_functionality()
    test_tree = Tree()
    insert_node(test_tree, "æbler", 0)
    insert_node(test_tree, "gulerødder", 0)
    test_tree
    test_tree.labels
end

using CSV, DataFrames, StatsBase

function test_data()
    input_data = CSV.File("./src/groceries.tsv", delim = ",") |> DataFrame
    labels = names(input_data)
    transaction = findall.(Vector.(eachrow(input_data)))
    content = map(x -> labels[x[1]], eachrow(transaction))
    df = DataFrame(transaction = transaction, content = content)
    return df
end


function test_build()
    df = test_data()

    ξ = 0.2
    min_count = ξ * size(df)[1]

    tree = Tree()
    
    # Calculate support using countmap from StatsBase
    support_count = countmap(vcat(df.transaction...))
    support_count = countmap(vcat(df.content...))

    # sort() defaults to sort by keys
    test = sort(support_count, byvalue = true, rev = true)

    support_df = DataFrame(key = vcat(keys(test)...), support = vcat(values(test)...))
    @info "Calculating support"

end

function teste(x)
    @info "x = $x"
end

with_logger(logger) do
    teste(1)
    teste([1,2])
end

end # module