import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os

graph_files = []
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'wiki_vote', 'Wiki-Vote.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'epinions', 'soc-Epinions1.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'gplus', 'gplus_combined.txt'))
graph_files.append(os.path.join(os.path.pardir, 'dataset', 'soc_pokec', 'soc-pokec-relationships.txt'))


allfiles_cc_lst = []
allfiles_scc_lst = []
allfiles_largest_cc_lst = []
allfiles_largest_scc_lst = []
allfiles_largest_cc_len_lst = []
allfiles_largest_scc_len_lst = []
allfiles_largest_cc_diam_lst = []
allfiles_largest_scc_diam_lst = []

for file in graph_files:
	with open(file, "rb") as fh:
		# import of directed
		dG = nx.read_adjlist(fh, create_using=nx.DiGraph())
		# conversion to undirected graph
		G = dG.to_undirected()

		# weakly cc
		cc = connected_component_subgraphs(G)
		cc_list = list(cc)
		allfiles_cc_lst.append(cc)
		print("cc completed")
		
		# strongly cc 
		scc = strongly_connected_component_subgraphs(dG)
		scc_list = list(scc)
		allfiles_scc_lst.append(scc)
		print("scc completed")

		# largest cc/scc
		cc_sizes = np.argsort([g.size() for g in cc_list])
		largset_cc_pos = cc_sizes[-1]		
		largest_cc = cc_list[largset_cc_pos]
		allfiles_largest_cc_lst.append(largest_cc)
		print("largest cc completed")

		scc_sizes = np.argsort([g.size() for g in scc_list])
		largset_scc_pos = scc_sizes[-1]		
		largest_scc = scc_list[largset_scc_pos]
		allfiles_largest_scc_lst.append(largest_scc)
		print("largest scc completed")

		# largest cc/scc len
		largest_cc_len = len(largest_cc)
		allfiles_largest_cc_len_lst.append(largest_cc_len)
		print("largest cc len completed")

		largest_scc_len = len(largest_scc)
		allfiles_largest_scc_len_lst.append(largest_scc_len)
		print("largest scc len completed")

		largest_cc_ecc = nx.eccentricity(largest_cc)
		largest_scc_ecc = nx.eccentricity(largest_scc)
		'''
		# largest cc/scc diameter
		largest_cc_diam = nx.diameter(largest_cc)
		allfiles_largest_cc_diam_lst.append(largest_cc_diam)
		print("largest cc diameter completed - ", largest_cc_diam)

		largest_scc_diam = nx.diameter(largest_scc)
		allfiles_largest_scc_diam_lst.append(largest_scc_diam)
		print("largest scc diameter completed - ", largest_scc_diam)
		'''

print(allfiles_cc_lst)
print(allfiles_scc_lst)
print(allfiles_largest_cc_lst)
print(allfiles_largest_scc_lst)
print(allfiles_largest_cc_len_lst)
print(allfiles_largest_scc_len_lst)
print(allfiles_largest_cc_diam_lst)
print(allfiles_largest_scc_diam_lst)
'''
../dataset/wiki_vote/Wiki-Vote.txt
7066
../dataset/epinions/soc-Epinions1.txt
75877
../dataset/gplus/gplus_combined.txt
107614
../dataset/soc_pokec/soc-pokec-relationships.txt
1632803
'''
