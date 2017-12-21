import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os

#workdir = "/home/michele/aalto/dm/DMproject/dmproject/exact"
workdir = "/u/08/colellf1/unix/dm/DMproject/dmproject/exact"

# utildir = '/home/michele/aalto/dm/DMproject/dmproject/utils'
utildir = "/u/08/colellf1/unix/dm/DMproject/dmproject/utils"

if(os.curdir != workdir):
    os.chdir(workdir)

import sys
sys.path.insert(0, utildir)

import utils
import pickle
import time



graph_files = []
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'wiki_vote', 'Wiki-Vote.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'epinions', 'soc-Epinions1.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'gplus', 'gplus_combined.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'soc_pokec', 'soc-pokec-relationships.txt'))
graph_names = ["wikivote", "epinions", "gplus", "pokec"]


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

for file, graphname in zip(graph_files, graph_names):
    with open(file, "rb") as fh:
        start_time = time.time()
        # import of directed
        dG = nx.read_adjlist(fh, create_using=nx.DiGraph())
        # conversion to undirected graph
        G = dG.to_undirected()
        
        cc_lst, _ = utils.load_or_do(graphname+"_cc_list.pkl", True, utils.get_cc, G)
        allfiles_cc_lst.append(cc_lst)
        scc_lst, _ = utils.load_or_do(graphname+"_scc_list.pkl", True, utils.get_scc, dG) 
        allfiles_scc_lst.append(scc_lst)
        
        largest_cc, _ = utils.load_or_do(graphname+"_largest_cc.pkl", True, utils.get_largest_cc, cc_lst)
        allfiles_largest_cc_lst.append(largest_cc)
        largest_scc, _ = utils.load_or_do(graphname+"_largest_scc.pkl", True, utils.get_largest_cc, scc_lst)
        allfiles_largest_cc_lst.append(largest_scc)
        
        # largest cc/scc len
        largest_cc_len = len(largest_cc)
        allfiles_largest_cc_len_lst.append(largest_cc_len)
        print("largest cc len completed")
        largest_scc_len = len(largest_scc)
        allfiles_largest_scc_len_lst.append(largest_scc_len)
        print("largest scc len completed")
        
        print("All pairs shortest path length")
        largest_cc_mat = nx.all_pairs_shortest_path_length(largest_cc)
        print("...")
        largest_scc_mat = nx.all_pairs_shortest_path_length(largest_scc)
        print("completed")
        #largest_cc_mat = utils.load_or_do(graphname + "_mat_cc.pkl", "wb", True, utils.)
        #pickle.dump(largest_cc_mat, open(graphname + "_mat_scc.pkl", "wb"))
        
        print("Distribution of largest cc")
        largest_cc_distribution = utils.get_distribution_lst(largest_cc_mat)
        largest_cc_stats = utils.get_stats(largest_cc_distribution)
        print(graphname, " - CC stats: ", largest_cc_stats)
        allfiles_cc_stats.append(largest_cc_stats)
        print("Distribution of largest scc")
        largest_scc_distribution = utils.get_distribution_lst(largest_scc_mat)
        largest_scc_stats = utils.get_stats(largest_scc_distribution)
        print(graphname, " - SCC stats: ", largest_scc_stats)
        allfiles_scc_stats.append(largest_scc_stats)  
        
        end_time = time.time()
        run_time = end_time - start_time
        allfiles_timing_lst.append(run_time)
        print(file, " - ", run_time)
    break
