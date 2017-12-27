# Do you feel epic?
I_feel_epic = false

using LightGraphs
using GraphIO
# using StaticGraphs

# --- Utilities ---

# Make a DiGraph from the largest cc
# Adaprted from https://github.com/JuliaGraphs/GraphIO.jl/blob/master/src/edgelist.jl
function get_largest_cc_as_DiGraph(cc_list, original_graph)
    
    srcs = Vector{Int64}()
    dsts = Vector{Int64}()
    
    println("Reading neighbours..")
    for src in cc_list
        for dst in out_neighbors(original_graph, src)
            push!(srcs, src)
            push!(dsts, dst)
#             println(src, "=>", dst)
        end
#         println(src)
    end
    print(" done!")
    # --- Utilities ---

# Make a DiGraph from the largest cc
# Adaprted from https://github.com/JuliaGraphs/GraphIO.jl/blob/master/src/edgelist.jl
function get_largest_cc_as_DiGraph(cc_list, original_graph)
    
    srcs = Vector{Int64}()
    dsts = Vector{Int64}()
    
    println("Reading neighbours..")
    for src in cc_list
        for dst in out_neighbors(original_graph, src)
            push!(srcs, src)
            push!(dsts, dst)
#             println(src, "=>", dst)
        end
#         println(src)
    end
    print(" done!")
    
    vxset = cc_list
    vxdict = Dict{Int,Int}()
    last_item = 0
    
    println("\nCreating dictionary..")
    for (v, k) in enumerate(vxset)
        vxdict[k] = v
#         println("vxdict[", k, "] = ", v)
        last_item = v
    end
    print(" done!")
    
    n_v = length(vxset)
    g = DiGraph(n_v)
    
    println("\nAdding edges..")
    for (u, v) in zip(srcs, dsts)
#         println(u, "=>", v)
#         if haskey(vxdict, u) && haskey(vxdict, v)
        add_edge!(g, vxdict[u], vxdict[v])
#         else
#             println("Key not found! ", u, "=>", v)
#         end
    end
    print(" done!")
    return g
    
    
#     # -----------------------
#     largest_cc_g = DiGraph()
#     # println(cc_list)
#     for edge in edges(original_graph)
#         if edge.src in cc_list || edge.dst in cc_list
#             println("Adding ", edge)
#             if add_edge!(largest_cc_g, edge)
#                 println("Added!")
#             else
#                 println("Failed!")
#             end
#         end
#     end
#     println(largest_cc_g)
#     return largest_cc_g
end


# Returns a couple (largest_cc, len_largest_cc)
function get_largest_cc(cc_list)
    largest_cc = []
    len_largest_cc = 0
    
    for cc in cc_list
        current_cc_len = length(cc)
        if current_cc_len > len_largest_cc
            len_largest_cc = current_cc_len
            largest_cc = cc
        end
    end
    
    return (largest_cc, len_largest_cc)
end


# Graph distribution
function get_distribution_lst(mat)
    distribution = []
    for (src_node, min_dist_list) in mat
        for (target_node, min_dist) in min_dist_list
            push!(distribution, min_dist)
        end
    end
    return distribution 
end


function diameter(distribution)
    return max(distribution)
end


function eff_diam(distribution)
    return quantile(distribution, 0.9)
end


function mean_diam(distribution)
    return mean(distribution)
end


function median_diam(distribution)
    return median(distribution)
end


function get_stats(distribution)
    return (diameter(distribution), 
        eff_diam(distribution), 
        mean_diam(distribution), 
        median_diam(distribution))
end
    vxset = cc_list
    vxdict = Dict{Int,Int}()
    last_item = 0
    
    println("\nCreating dictionary..")
    for (v, k) in enumerate(vxset)
        vxdict[k] = v
#         println("vxdict[", k, "] = ", v)
        last_item = v
    end
    print(" done!")
    
    n_v = length(vxset)
    g = DiGraph(n_v)
    
    println("\nAdding edges..")
    for (u, v) in zip(srcs, dsts)
#         println(u, "=>", v)
#         if haskey(vxdict, u) && haskey(vxdict, v)
        add_edge!(g, vxdict[u], vxdict[v])
#         else
#             println("Key not found! ", u, "=>", v)
#         end
    end
    print(" done!")
    return g
    
    
#     # -----------------------
#     largest_cc_g = DiGraph()
#     # println(cc_list)
#     for edge in edges(original_graph)
#         if edge.src in cc_list || edge.dst in cc_list
#             println("Adding ", edge)
#             if add_edge!(largest_cc_g, edge)
#                 println("Added!")
#             else
#                 println("Failed!")
#             end
#         end
#     end
#     println(largest_cc_g)
#     return largest_cc_g
end


# Returns a couple (largest_cc, len_largest_cc)
function get_largest_cc(cc_list)
    largest_cc = []
    len_largest_cc = 0
    
    for cc in cc_list
        current_cc_len = length(cc)
        if current_cc_len > len_largest_cc
            len_largest_cc = current_cc_len
            largest_cc = cc
        end
    end
    
    return (largest_cc, len_largest_cc)
end


# Graph distribution
function get_distribution_lst(mat)
    distribution = []
    for (src_node, min_dist_list) in mat
        for (target_node, min_dist) in min_dist_list
            push!(distribution, min_dist)
        end
    end
    return distribution 
end


function diameter(distribution)
    return max(distribution)
end


function eff_diam(distribution)
    return quantile(distribution, 0.9)
end


function mean_diam(distribution)
    return mean(distribution)
end


function median_diam(distribution)
    return median(distribution)
end


function get_stats(distribution)
    return (diameter(distribution), 
        eff_diam(distribution), 
        mean_diam(distribution), 
        median_diam(distribution))
end




# base workdir
base_workdir = "/home/fabio/Dropbox/Aalto Macadamia/I period/AMDM - Algorithmic Methods of Data Mining/assignments/DMproject/dmproject"
#base_workdir = "/home/michele/aalto/dm/DMproject/dmproject"

# Star is used for string concatenation
workdir = base_workdir * "/exact"


graph_files = []

push!(graph_files, base_workdir * "/dataset" * "/wiki_vote" * "/Wiki-Vote.txt")
push!(graph_files, base_workdir * "/dataset" * "/epinions" * "/soc-Epinions1.txt")
push!(graph_files, base_workdir * "/dataset" * "/gplus" * "/gplus_combined.txt")

graph_names = ["wikivote", 
    "epinions", 
    "gplus"]

if I_feel_epic
    println("Raising epicness..")
    push!(graph_files, base_workdir * "/dataset" * "/soc_pokec" * "/soc-pokec-relationships.txt")
    push!(graph_names, "pokec")
end

# Warning: Julia starts counting arrays from 1!
graphname = graph_names[1]
current_file = graph_files[1]

allfiles_cc_lst = []
allfiles_scc_lst = []
allfiles_largest_cc_lst = []
allfiles_largest_scc_lst = []
allfiles_largest_cc_len_lst = []
allfiles_largest_scc_len_lst = []
allfiles_largest_cc_diam_lst = []
allfiles_largest_scc_diam_lst = []
allfiles_timing_lst = []
allfiles_timing_cc_lst = []
allfiles_timing_scc_lst = []
allfiles_cc_stats = []
allfiles_scc_stats = []

for (filename, graphname) in zip(graph_files, graph_names)
    
    println(graphname)
    # Count the time from here
    tic()
    
    # Load graph
    base_G = loadgraph(filename, "", EdgeListFormat())
    
    # Convert to static directed graph
    dG = DiGraph(base_G) # StaticDiGraph(base_G)
    
    # Convert to static undirected graph
    G = Graph(base_G) #StaticGraph(dG)
    
    cc_lst = connected_components(G)
    push!(allfiles_cc_lst, cc_lst)
    
    scc_lst = strongly_connected_components(dG)
    push!(allfiles_scc_lst, scc_lst)
    
    # Get the largest connected component (as a list of nodes)
    (largest_cc_as_list, largest_cc_len) = get_largest_cc(cc_lst)
    println("largest cc len completed")
    (largest_scc_as_list, largest_scc_len) = get_largest_cc(scc_lst)
    println("largest scc len completed")
    
    # Convert the graph for cc to undirected
    largest_cc = Graph(get_largest_cc_as_DiGraph(largest_cc_as_list, G))
  
    largest_scc = get_largest_cc_as_DiGraph(largest_scc_as_list, dG)
    
    println(largest_cc)
#     println(largest_scc)
    
    # Store everything into lists
#     push!(allfiles_largest_cc_lst, largest_cc)
#     push!(allfiles_largest_scc_lst, largest_scc)
#     push!(allfiles_largest_cc_len_lst, largest_cc_len)
#     push!(allfiles_largest_scc_len_lst, largest_scc_len)
    
    # Compute the all pairs shortest path
    println("All pairs shortest path length")
    largest_cc_mat = floyd_warshall_shortest_paths(largest_cc)
    println("Completed cc!")
#     largest_scc_mat = floyd_warshall_shortest_paths(largest_scc)
#     println("Completed scc!")
    
    println(largest_cc_mat)
    println(largest_cc_mat.dists)
    for x in largest_cc_mat.dists
        println(x)
    end
    
    break
    
    println("Distribution of largest cc")
    largest_cc_distribution = get_distribution_lst(largest_cc_mat)
    largest_cc_stats = get_stats(largest_cc_distribution)
    println(graphname, " - CC stats: ", largest_cc_stats)
    push!(allfiles_cc_stats, largest_cc_stats)
    println("Distribution of largest scc")
    largest_scc_distribution = get_distribution_lst(largest_scc_mat)
    largest_scc_stats = get_stats(largest_scc_distribution)
    println(graphname, " - SCC stats: ", largest_scc_stats)
    push!(allfiles_scc_stats, largest_scc_stats)  
    
#     println(largest_cc)
#     println("\n")
#     println(largest_scc_len)
    
    toc()  # print time from tic()
    println("\n")
end

