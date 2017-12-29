# Please run `jupyter notebook` from the folder in which is this file (it uses getcwd()!)
%reload_ext autoreload
%autoreload 2

import networkx as nx
import numpy as np
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os

workdir = os.getcwd()
utildir = os.path.join(workdir, os.path.pardir, "utils")

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


gtype = "cc"
graph_file = graph_files[1]
graph_name = graph_names[1]
G = utils.load_or_do(graph_name + "_" + gtype + "_graph.pkl", True, nx.read_adjlist, graph_files[3])
start_time = time.time()
cc_lst, _ = utils.load_or_do(graph_name + "_" + gtype + "_list.pkl", True, utils.get_cc, G)
largest_cc, _ = utils.load_or_do(graph_name + "_largest_" + gtype + ".pkl", True, utils.get_largest_cc, cc_lst)
largest_cc_len = len(largest_cc)
print(largest_cc_len)
end_time = time.time()
print(end_time-start_time)



