# ------------------------------------------------------------------------------
# F R E Q U E N T   P A T T E R N   A N A L Y S I S
#
# Using FP Growth
#
# Watch https://www.youtube.com/watch?v=VB8KWm8MXss for a walk-through of the
# algorithm and https://www.youtube.com/watch?v=ToswH_dA7KU for a walk-through
# of how to mine the rules.
#
# TODO Research which packages exist and still have active support
# TODO Implement minimal memory management where needed by assigning objects to
#      nothing and running the garbage collector – gc().
# TODO Make it possible to select restrictions when building the FP tree - e.g.
#      provide a minimum support level required. This will knock out items
#      early in the process and save subsequent calculations, but also put a
#      limit on the rules that can be mined afterwards.
# ------------------------------------------------------------------------------


# Load packages ----------------------------------------------------------------

using CSV
using DataFrames
using Statistics



# Define structures ------------------------------------------------------------
# Building on the code from:
# https://stackoverflow.com/questions/36593490/tree-data-structure-in-julia

mutable struct TreeNode
    parent::Int
    children::Vector{Int}

    # item_id allows two nodes to represent the same item at different locations
    item_id::Int
    item_label::String
    count::Int
end

struct Tree
    nodes::Vector{TreeNode}
end

Tree() = Tree([TreeNode(0, Vector{Int}())])

function addchild(tree::Tree, id::Int)
    1 <= id <= length(tree.nodes) || throw(BoundsError(tree, id))
    push!(tree.nodes, TreeNode(id, Vector{}()))
    child = length(tree.nodes)
    push!(tree.nodes[id].children, child)
    child
end

children(tree, id) = tree.nodes[id].children

parent(tree,id) = tree.nodes[id].parent


# ------------------------------------------------------------------------------
# T e s t   r u n s
# Using data from the Groceries dataset in the arules package for R
# ------------------------------------------------------------------------------

# Read sample data: groceries
filename = "groceries.tsv"
filepath = joinpath(@__DIR__, filename)
#println(filepath)

groceries = CSV.read(filepath, delim = ",")



# ------------------------------------------------------------------------------
# Step 1  F o r m a t   t h e   d a t a
#
# Organise the data into a tidy format with transaction ID and Item as the two
# variables.
# ------------------------------------------------------------------------------

function tidy_data(df)
    tidy_df = df
    return tidy_df
end



# ------------------------------------------------------------------------------
# Step 2  C a l c u l a t e   s u p p o r t
# ------------------------------------------------------------------------------

function calculate_support(df)
    # Takes as input a dataframe where each row is a transaction and each
    # column an item. Values are assumed boolean.
    map(eachcol(df)) do col
        mean(col)
    end
end

# This code is more concise than the function above :D
mean.(eachcol(groceries))



# ------------------------------------------------------------------------------
# Step 3  R e o r d e r   i t e m s e t s
# ------------------------------------------------------------------------------

function reorder_items(df)
    # Get support for all columns: support
    support = calculate_support(df)
    n_items = length(support)
    item_names = names(groceries)

    # Build dataframe of support and id: df_ordered
    df_ordered = DataFrame()
    df_ordered.support = support
    df_ordered.id = 1:n_items
    df_ordered.label = item_names
    sort!(df_ordered, rev = true)
end

# Test function
# sorted = reorder_items(groceries)
# sorted = nothing



# ------------------------------------------------------------------------------
# Step 4  R e o r d e r   t r a n s a c t i o n s
# ------------------------------------------------------------------------------

#
function reorder_transactions(df)
    # Get dimensions of dataframe
    n_transactions = nrow(df)
    n_items = ncol(df)

    # Get support for all items
    sorted = reorder_items(df)

    # Add transaction id (:tid) to df
    insertcols!(df, 1, tid = 1:n_transactions)

    # Stack the columns of the dataframe to make it tidy
    df_long = stack(df, 2:(n_items + 1))

    filter!(row -> row[:value] == true, df_long)
    rename!(df_long, :variable => :label)
    tidy = join(df_long, sorted, on = :label)
    sort!(tidy, [:tid, order(:support, rev = true)])

    return tidy
end

# Test function
# tidy_df = reorder_transactions(groceries)



# ------------------------------------------------------------------------------
# Step 5  B u i l d   t i d y   F P   t r e e
# ------------------------------------------------------------------------------

connections = DataFrame(parent = Int[],
                        child = Int[])
nodes = DataFrame(id = Int[],
                  item_id = Int[],
                  item_label = String[],
                  count = Int[])

# Function to add sub trees to a node. Takes a vector of items to add which
# allows the same function to be used for adding single nodes.
function add_sub_tree!(tree::Tree, id::Int, itemset::DataFrame)
  # Set active node to id
  current_node = tree.nodes[id]

  # Cycle through all items in itemset
  for item in itemset
      # Append id.children with item
      append!(current_node.children, item)

      # Append new node with item as id
      push!(tree.nodes,
            TreeNode(current_node.item_id, Vector{Int}(), item, "", 1))

      # Make new node the current node
      current_node = tree.nodes[item]
  end
end

# Function to build the FP tree
function build_fp_tree(df)
    # df should be in a tidy format with columns for transaction id, item id,
    # item label and support.

    # Reorder the transactions using reorder_transactions()

    # Initialise the tree (build the root node)
    fp_tree = Tree([TreeNode(0, Vector{Int}(), 0, "root", 0)])

    # Cycle through all transactions
    for transaction in transactions

        # Cycle through all items in transaction
        for item in itemset
            # Start at root node
            # Lookup current item in children
            # If success increase count and move to relevant child node
            # If fail add current and remaining transactions as sub tree
        end
    end # for

    # Return FP tree
end





# ------------------------------------------------------------------------------
# Step 5  B u i l d   F P   t r e e
# ------------------------------------------------------------------------------

# Function to add sub trees to a node. Takes a vector of items to add which
# allows the same function to be used for adding single nodes.
function add_sub_tree!(tree::Tree, id::Int, itemset::Vector{Int})
    # Set active node to id
    current_node = tree.nodes[id]

    # Cycle through all items in itemset
    for item in itemset
        # Append id.children with item
        append!(current_node.children, item)

        # Append new node with item as id
        push!(tree.nodes,
              TreeNode(current_node.item_id, Vector{Int}(), item, "", 1))

        # Make new node the current node
        current_node = tree.nodes[item]
    end
end

# fp_tree.nodes.item_id
#
# current_node = fp_tree.nodes[1]
# append!(current_node.children, 16)
# current_node.children
#
# push!(fp_tree.nodes, TreeNode(1, Vector{Int}(), 16, "inner", 1))
#
# [fp_tree.nodes[i].item_id .== 16 for i = 1:2]
#
# (fp->fp_tree.nodes).(1:2)
#
# getfield.(fp_tree.nodes, item_id)
#
# dump(fp_tree)



# Function to build the FP tree
function build_fp_tree(df)
    # df should be in a tidy format with columns for transaction id, item id,
    # item label and support.

    # Reorder the transactions using reorder_transactions()

    # Initialise the tree (build the root node)
    fp_tree = Tree([TreeNode(0, Vector{Int}(), 0, "root", 0)])

    # Cycle through all transactions
    for transaction in transactions

        # Cycle through all items in transaction
        for item in itemset
            # Start at root node
            # Lookup current item in children
            # If success increase count and move to relevant child node
            # If fail add current and remaining transactions as sub tree
        end
    end # for

    # Return FP tree
end



# ------------------------------------------------------------------------------
# Step 6a  B u i l d   c o n d i t i o n a l   p a t t e r n   b a s e
# ------------------------------------------------------------------------------

function build_conditional_pattern_base(args)
    body
end

# ------------------------------------------------------------------------------
# Step 6b  B u i l d   c o n d i t i o n a l   F P   t r e e
# ------------------------------------------------------------------------------

function build_conditional_fp_tree(args)
    body
end


# ------------------------------------------------------------------------------
# Step 6c  G e n e r a t e   f r e q u e n t   p a t t e r n s
# ------------------------------------------------------------------------------

function generate_frequent_patterns(args)
    body
end



# ------------------------------------------------------------------------------
# Q u e r y   f u n c t i o n s
# ------------------------------------------------------------------------------

function query_rules(df, support, confidence, lift)
    # Filter the dataframe to meet the criterias for support, confidence and
    # lift: rules
    return rules
end
