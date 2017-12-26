import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os


import pickle
import time
import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os


import pickle
import time

workdir = "/home/michele/aalto/dm/DMproject/dmproject/approximate"
if(os.curdir != workdir):
    os.chdir("/home/michele/aalto/dm/DMproject/dmproject/approximate")

import sys
sys.path.insert(0, '/home/michele/aalto/dm/DMproject/dmproject/utils')

import utils


# In[17]:

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



