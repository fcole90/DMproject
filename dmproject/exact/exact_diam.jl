using LightGraphs
using GraphIO
# using StaticGraphs

# --- Settings ---
I_feel_epic = false  # Do you feel epic?
use_cache = true


# --- Paths ---
# base workdir
base_workdir = "/home/fabio/Dropbox/Aalto Macadamia/I period/AMDM - Algorithmic Methods of Data Mining/assignments/DMproject/dmproject"
#base_workdir = "/home/michele/aalto/dm/DMproject/dmproject"

# Star is used for string concatenation
workdir = joinpath(base_workdir, "exact")


# --- Utilities ---

# Make a DiGraph from the largest cc
# Adaprted from https://github.com/JuliaGraphs/GraphIO.jl/blob/master/src/edgelist.jl
function get_largest_cc_as_graph(cc_list, original_graph, use_undirected)
    
    srcs = Vector{Int64}()
    dsts = Vector{Int64}()
    vxdict = Dict{Int,Int}()
    if use_undirected == true
        g = Graph()
    else
        g = DiGraph()
    end
    
    print("\tReading neighbours and creating dictionary..")
    for (v, src) in enumerate(cc_list)
        # Make a conversion dictionary
        vxdict[src] = v
        # Add vertices to the Graph
        add_vertex!(g)
        for dst in out_neighbors(original_graph, src)
            # Add only nodes belonging to the CC
            if dst in cc_list
                push!(srcs, src)
                push!(dsts, dst)
            end
        end
    end
    println(" done!")
    
    # Create a new graph out of the connected components
    print("\tAdding edges..")
    for (u, v) in zip(srcs, dsts)
        try add_edge!(g, vxdict[u], vxdict[v])
        catch y
            if isa(y, KeyError)
                continue
            end
        end
    end
    println(" done!")
    return g
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


# Graph distribution: populates a list with shortest path distances
function get_distribution_lst(mat, cc_list)
    distribution = Vector{Int64}()
    for src_node_paths_list in enumerate_paths(mat)
        for path in src_node_paths_list
            push!(distribution, length(path))
        end
    end
    return distribution 
end


function diameter(distribution)
    return maximum(distribution)
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


# --- Files ---
graph_files = []

push!(graph_files, joinpath(base_workdir, "dataset", "wiki_vote", "Wiki-Vote.txt"))
push!(graph_files, joinpath(base_workdir, "dataset", "epinions", "soc-Epinions1.txt"))
push!(graph_files, joinpath(base_workdir, "dataset", "gplus", "gplus_combined.txt"))

graph_names = ["wikivote", 
    "epinions", 
    "gplus"]

if I_feel_epic
    println("Raising epicness..")
    push!(graph_files, joinpath(base_workdir, "dataset", "soc_pokec", "soc-pokec-relationships.txt"))
    push!(graph_names, "pokec")
end


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



# --- Loop ---

for (filename, graphname) in zip(graph_files, graph_names)
    println("Working on ", graphname)
    
    # Count the time from here
    tic()
    
    # Defining cache name format
    cache_graph_name_prefix = "jl_adj_list_"
    cache_cc_name = cache_graph_name_prefix * graphname * "_cc.txt"
    cache_scc_name = cache_graph_name_prefix * graphname * "_scc.txt"
    
    # Check availability of edge list for largest CC or compute it
    if use_cache == true && isfile(joinpath(workdir, cache_cc_name))
        println("Using cached version!")
        largest_cc = Graph(loadgraph(cache_cc_name, "", EdgeListFormat()))
    else
        println("Generating largest CC graph..")
        # Load graph
        G = Graph(loadgraph(filename, "", EdgeListFormat()))
        cc_lst = connected_components(G)
        # Get the largest connected component (as a list of nodes)
        (largest_cc_as_list, largest_cc_len) = get_largest_cc(cc_lst)
        println("largest cc len completed")
        println("Largest CC len: ", largest_cc_len)
        # Convert the graph for cc to undirected
        largest_cc = get_largest_cc_as_graph(largest_cc_as_list, G, true)
        println("Graph creation completed!")
        savegraph(cache_cc_name, largest_cc, "", EdgeListFormat())
    end
    
    # Check availability of edge list for largest SCC or compute it
    if use_cache == true && isfile(joinpath(workdir, cache_scc_name))
        largest_scc = loadgraph(cache_scc_name, "", EdgeListFormat())
    else
        println("Generating largest SCC graph..")
        # Load graph
        dG = loadgraph(filename, "", EdgeListFormat())
        scc_lst = strongly_connected_components(dG)
        # Get the largest connected component (as a list of nodes)
        (largest_scc_as_list, largest_scc_len) = get_largest_cc(scc_lst)
        println("largest scc len completed")
        println("Largest SCC len: ", largest_scc_len)
        largest_scc = get_largest_cc_as_graph(largest_scc_as_list, dG, false)
        println("Graph creation completed!")
        savegraph(cache_scc_name, largest_scc, "", EdgeListFormat())
    end
    
    
#     # Compute the all pairs shortest path
#     println("All pairs shortest path length")
    
#     largest_cc_mat = floyd_warshall_shortest_paths(largest_cc)
#     println("Completed cc!")
    
#     largest_scc_mat = floyd_warshall_shortest_paths(largest_scc)
#     println("Completed scc!")
        
    
#     # Compute largest SCC distribution
#     println("Distribution of largest scc")
#     largest_scc_distribution = get_distribution_lst(largest_scc_mat, vertices(largest_scc))
#     largest_scc_stats = get_stats(largest_scc_distribution)
#     println(graphname, " - SCC stats: ", largest_scc_stats)
    
#     # Compute largest CC distribution
#     println("Distribution of largest cc")
#     largest_cc_distribution = get_distribution_lst(largest_cc_mat, vertices(largest_cc))
#     largest_cc_stats = get_stats(largest_cc_distribution)
#     println(graphname, " - CC stats: ", largest_cc_stats)
    
    toc()  # print time from tic()
    println("\n")
#     break
end
