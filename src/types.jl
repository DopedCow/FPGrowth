module types

export Node

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


end # module