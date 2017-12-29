#Pkg.add("LightGraphs")
#Pkg.add("JLD")

using LightGraphs
using JLD
using ParallelAccelerator
using GraphIO
using StaticGraphs

# --- Settings ---
I_feel_epic = true  # Do you feel epic?
use_cache = true


# --- Paths ---
# base workdir
base_workdir = "/home/fabio/Dropbox/Aalto Macadamia/I period/AMDM - Algorithmic Methods of Data Mining/assignments/DMproject/dmproject"
#base_workdir = "/home/michele/aalto/dm/DMproject/dmproject"
#base_workdir = "/home/jovyan/DMproject/dmproject"

# Star is used for string concatenation
workdir = joinpath(base_workdir, "exact")


# --- Utilities ---

# Make a DiGraph from the largest cc
# Adaprted from https://github.com/JuliaGraphs/GraphIO.jl/blob/master/src/edgelist.jl
function get_largest_cc_as_graph(cc_list, original_graph, use_undirected)
    
    srcs = Vector{Int}()
    dsts = Vector{Int}()
    vxdict = Dict{Int,Int}()
    if use_undirected == true
        g = Graph()
    else
        g = DiGraph()
    end
    
    print("\tReading neighbours and creating dictionary..")
    
    @acc begin
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
    end # acc
    println(" done!")
    
    # Create a new graph out of the connected components
    print("\tAdding edges..")
    
    @acc begin
    for (u, v) in zip(srcs, dsts)
        try add_edge!(g, vxdict[u], vxdict[v])
        catch y
            if isa(y, KeyError)
                continue
            end
        end
    end
    end # acc
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


function opt_floyd_warshall_shortest_paths(
    g::AbstractGraph{U},
    distmx::AbstractMatrix{T} = weights(g)
) where T where U
    n_v = nv(g)
    dists = fill(typemax(T), (Int(n_v), Int(n_v)))

    # fws = FloydWarshallState(Matrix{T}(), Matrix{Int}())
    for v in 1:n_v
        dists[v, v] = zero(T)
    end
    undirected = !is_directed(g)
    println("Phase 1")
    
#    @acc begin
    for e in edges(g)
        u = src(e)
        v = dst(e)

        d = distmx[u, v]

        dists[u, v] = min(d, dists[u, v])
        if undirected
            dists[v, u] = min(d, dists[v, u])
        end
    end
 #   end #acc
    
    @acc begin
    println("Phase 2")
    for w in vertices(g), u in vertices(g), v in vertices(g)
        if dists[u, w] == typemax(T) || dists[w, v] == typemax(T)
            ans = typemax(T)
        else
            ans = dists[u, w] + dists[w, v]
        end
        if dists[u, v] > ans
            dists[u, v] = dists[u, w] + dists[w, v]
        end
    end
    end #acc
    return reshape(dists, n_v * n_v)
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

function saveedgelist(io, g)
    g_file = open(io, "w")
    for e in edges(g)   
        write(g_file, string(e.src) * ", " * string(e.dst) * "\n")
    end
    close(g_file)
end

function loadedgelist(io, gname::String)
    srcs = Vector{String}()
    dsts = Vector{String}()
    while !eof(io)
        line = strip(chomp(readline(io)))
        if !startswith(line, "#") && (line != "")
#             println("linelength = $(length(line)), line = $line")
            r = r"(\w+)[\s,]+(\w+)"
            src_s, dst_s = match(r, line).captures
#             println("src_s = $src_s, dst_s = $dst_s")
            push!(srcs, src_s)
            push!(dsts, dst_s)
        end
    end
    vxset = unique(vcat(srcs, dsts))
    vxdict = Dict{String,Int}()
    
    @acc begin
    for (v, k) in enumerate(vxset)
        vxdict[k] = v
    end
    end

    n_v = length(vxset)
    g = LightGraphs.DiGraph(n_v)
    @acc begin
    for (u, v) in zip(srcs, dsts)
        add_edge!(g, vxdict[u], vxdict[v])
    end
    end
    
    return g
end


# --- Files ---
graph_files = []

push!(graph_files, joinpath(base_workdir, "dataset", "wiki_vote", "Wiki-Vote.txt"))
push!(graph_files, joinpath(base_workdir, "dataset", "epinions", "soc-Epinions1.txt"))
push!(graph_files, joinpath(base_workdir, "dataset", "gplus", "gplus_combined.txt"))


graph_names = []

push!(graph_names, "wikivote")
push!(graph_names, "epinions")
push!(graph_names, "gplus")

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
    
    # Defining cache name format
    cache_graph_name_prefix = "jl_adj_list_"
    cache_cc_name = cache_graph_name_prefix * graphname * "_cc.txt"
    cache_scc_name = cache_graph_name_prefix * graphname * "_scc.txt"
    
    gg = 0
    if use_cache == false ||
       !isfile(joinpath(workdir, "readable_" * cache_scc_name)) ||
       !isfile(joinpath(workdir, "readable_" * cache_cc_name))
       println("Loading graph..")
        open(joinpath(workdir, filename), "r") do f
            gg = loadgraph(f, "", EdgeListFormat())
        end
    end
    
    
    # --- SCC ---
   
    # Check availability of edge list for largest SCC or compute it
    if use_cache == true && isfile(joinpath(workdir, "readable_" * cache_scc_name))
        open(joinpath(workdir, "readable_" * cache_scc_name), "r") do f
            #largest_scc = StaticDiGraph(loadedgelist(f, ""))
            largest_scc = DiGraph(loadedgelist(f, ""))
        end
        saveedgelist(joinpath(workdir, "readable_" * cache_scc_name), largest_scc)        
    else
        
        # Load graph
        dG = 0

#       dG = StaticDiGraph(gg)
        dG = DiGraph(gg)

        println("Generating largest SCC graph..")
        tic()
        @acc begin
        scc_lst = strongly_connected_components(dG)
        end
        toc()
        # Get the largest connected component (as a list of nodes)
        (largest_scc_as_list, largest_scc_len) = get_largest_cc(scc_lst)
        scc_lst = 0 #  deallocate
        println("largest scc len completed")
        println("Largest SCC len: ", largest_scc_len)
#         largest_scc = get_largest_cc_as_graph(largest_scc_as_list, dG, false)
#         largest_scc_as_list = 0  # deallocate
#         dG = 0
#         println("Graph creation completed!")
#         saveedgelist(joinpath(workdir, "readable_" * cache_scc_name), largest_scc)
    end
    
#      println("Making graph static..")
#      largest_scc = StaticDiGraph(largest_scc)
#      # Compute the all pairs shortest path
#      println("All pairs shortest path length SCC")
#      tic()
#      largest_scc_distribution = opt_floyd_warshall_shortest_paths(StaticDiGraph(largest_scc))
#      toc()
#      println("Completed scc!")
       
#      # Compute largest SCC distribution
#      println("Distribution of largest scc")
#      save(joinpath(workdir, graphname * "_largest_scc_distribution.jld"), "largest_scc_distribution", largest_scc_distribution)
#      largest_scc_stats = get_stats(largest_scc_distribution)
#      println(graphname, " - SCC stats: ", largest_scc_stats)
#      largest_scc = 0  # deallocate
#      largest_scc_mat = 0  # deallocate
#      gc() # garbage collect
    
    
    # --- CC ---
    
    # Check availability of edge list for largest CC or compute it
    if use_cache == true && isfile(joinpath(workdir, "readable_" * cache_cc_name))
        println("Using cached version!")
        open(joinpath(workdir, "readable_" * cache_cc_name), "r") do f
            #largest_cc = StaticGraph(loadedgelist(f, ""))
            largest_cc = Graph(loadedgelist(f, ""))
        end
        saveedgelist(joinpath(workdir, "readable_" * cache_cc_name), largest_cc)        
    else
        println("Loading graph..")
        # Load graph
        G = 0

#       G = StaticGraph(gg)
        G = Graph(gg)

        println(isdefined(:G))
        println("Generating largest CC graph..")
        tic()
        @acc begin
        cc_lst = connected_components(G)
        end #acc
        toc()
        # Get the largest connected component (as a list of nodes)
        (largest_cc_as_list, largest_cc_len) = get_largest_cc(cc_lst)
        cc_lst = 0 #  deallocate
        println("largest cc len completed")
        println("Largest CC len: ", largest_cc_len)
#         # Convert the graph for cc to undirected
#         largest_cc = get_largest_cc_as_graph(largest_cc_as_list, G, true)
#         largest_cc_as_list = 0  # deallocate
#         G = 0
#         println("Graph creation completed!")
#         saveedgelist(joinpath(workdir, "readable_" * cache_cc_name), largest_cc)
    end
    
#      println("Making graph static...")
#      largest_cc = StaticGraph(largest_cc)
#      # Compute the all pairs shortest path
#      println("All pairs shortest path length CC")
#      tic()
#      largest_cc_distribution = opt_floyd_warshall_shortest_paths(largest_cc)
#      toc()
#      println("Completed cc!")
   
#      # Compute largest CC distribution
#      println("Distribution of largest cc")
#      save(joinpath(workdir, graphname * "_largest_cc_distribution.jld"), "largest_cc_distribution", largest_cc_distribution)
#      largest_cc_stats = get_stats(largest_cc_distribution)
#      println(graphname, " - CC stats: ", largest_cc_stats)
#      largest_cc = 0  # deallocate
#      largest_cc_mat = 0  # deallocate
#      gc() # garbage collect

     # A little of space between iterations
     println("\n")
end
