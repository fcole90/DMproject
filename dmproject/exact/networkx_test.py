import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs
import timeit
import os
import utils as utils
import pickle

graph_files = []
graph_files.append(os.path.join('dataset', 'wiki_vote', 'Wiki-Vote.txt'))
graph_files.append(os.path.join('dataset', 'epinions', 'soc-Epinions1.txt'))
graph_files.append(os.path.join('dataset', 'gplus', 'gplus_combined.txt'))
graph_files.append(os.path.join('dataset', 'soc_pokec', 'soc-pokec-relationships.txt'))


allfiles_cc_lst = []
allfiles_scc_lst = []
allfiles_largest_cc_lst = []
allfiles_largest_scc_lst = []
allfiles_largest_cc_len_lst = []
allfiles_largest_scc_len_lst = []
allfiles_largest_cc_diam_lst = []
allfiles_largest_scc_diam_lst = []
allfiles_timing

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
		pickle.dump(cc_list, open("cc_list.pkl", "wb"))
		
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
		pickle.dump(largest_cc_ecc, open("ecc_cc.pkl", "wb"))
		largest_scc_ecc = nx.eccentricity(largest_scc)
		pickle.dump(largest_cc_ecc, open("ecc_scc.pkl", "wb"))

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

'''
largest_cc_ecc = pickle.load(open("ecc_cc.pkl", "rb"))
largest_scc_ecc = pickle.load(open("ecc_scc.pkl", "rb"))

distances_cc = list(largest_cc_ecc.values())

diameter = np.max(distances)
mean = np.mean(distances)
median = np.median(distances)
eff_diam = np.percentile(distances, 90)

print(diameter)
print(mean)
print(median)
print(eff_diam)
'''


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
