import networkx as nx
import numpy as np
import matplotlib.pyplot as plt
from networkx.algorithms.components import strongly_connected_components

fh = open("Wiki-Vote.txt", 'rb')
G = nx.read_adjlist(fh)
scc = strongly_connected_components(G)
print(scc)

