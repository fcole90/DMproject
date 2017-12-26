import os
import pickle
import time
import sys

CACHE_DIR = os.path.join("dmproject", "cache")


def save_to_cache(name, object):
    print("Caching {}...".format(name))
    with open(name, "wb") as cache_file:
        pickle.dump(object, cache_file)
    print("Data for {} cached with success.".format(name))


def load_from_cache(name):
    print("Loading {} from cache..")
    file_name = "{}.cache".format(name)
    file_path = os.path.join(CACHE_DIR, file_name)
    with open(file_path, "rb") as cache_file:
        obj = pickle.load(cache_file)
    print("Data for {} loaded with success.".format(name))
    return obj


def load_or_do(name, save_if_not_found, f, *args):
    try:
        obj = pickle.load(open(name, "rb"))
        run_time = 0
    except FileNotFoundError as e:
        print("Cache for {} was not available, running the function instead..".format(name))
        start_time = time.time()
        obj = f(*args)
        end_time = time.time()
        run_time = end_time-start_time

        if save_if_not_found:
            save_to_cache(name, obj)

    return obj, run_time


import networkx as nx
import numpy as np
from networkx.algorithms.components import strongly_connected_component_subgraphs
from networkx.algorithms.components import connected_component_subgraphs


def get_cc(G):
    cc = connected_component_subgraphs(G)
    cc_list = list(cc)
    print("cc completed")
    return cc_list


def get_scc(G):
    scc = strongly_connected_component_subgraphs(G)
    scc_list = list(scc)
    print("scc completed")
    return scc_list


def get_largest_cc(cc):
    cc_sizes = np.argsort([g.size() for g in cc])
    largset_cc_pos = cc_sizes[-1]
    largest_cc = cc[largset_cc_pos]
    print("largest cc completed")
    return largest_cc

def get_distribution(mat):
    distribution = dict()
    for src_node, min_dist_list in mat:
        for target_node, min_dist in min_dist_list.items():
            if min_dist in distribution:
                distribution[min_dist] +=1
            else:
                distribution[min_dist] =1
    return distribution

def get_distribution_lst(mat):
    mat = mat[0]
    distribution = []
    for i in range(len(mat)):
        min_dist_dict = mat[i][1]
        for target_node, min_dist in min_dist_dict.items():
            distribution.append(min_dist)

    return distribution


class Stats:
    diam = 0.0
    mean_diam = 0.0
    median_diam = 0.0
    eff_diam = 0.0

    def set_diam(self, diam):
        self.diam = diam

    def set_mean_diam(self, diam):
        self.mean_diam = diam

    def set_median_diam(self, diam):
        self.median_diam = diam

    def set_eff_diam(self, diam):
        self.eff_diam = diam

    def __init__(self, diam, mean_diam, median_diam, eff_diam):
        self.diam = diam
        self.mean_diam = diam
        self.median_diam = diam
        self.eff_diam = diam


def diameter(distribution):
    return np.max(distribution)

def eff_diam(distribution):
    return np.percentile(distribution, 90)

def mean_diam(distribution):
    return np.mean(distribution)

def median_diam(distribution):
    return np.median(distribution)

def get_stats(mat):
    distribution = get_distribution_lst(mat)
    return [diameter(distribution), eff_diam(distribution), mean_diam(distribution), median_diam(distribution)]

def aggregate_stats(stats_n):
    diam = np.max(stats_n[:, 0])
    mean_diam = np.mean(stats_n[:, 2])
    median_diam = np.median(stats_n[:, 3])
    eff_diam = np.mean(stats_n[:, 1])
    return [diam, mean_diam, median_diam, eff_diam]

def exact_computation_g(G, graphname):
    start_time = time.time()
    stats = exact_computation_wrapped(G, graphname)

    end_time = time.time()
    run_time = end_time - start_time
    return stats, run_time

def exact_computation(fh, graphname):
    start_time = time.time()

    dG = nx.read_adjlist(fh, create_using=nx.DiGraph())
    G = dG.to_undirected()

    stats_cc = exact_computation_wrapped(G, graphname)
    stats_scc = exact_computation_wrapped(dG, graphname)

    end_time = time.time()
    run_time = end_time - start_time

    return stats_cc, stats_scc, run_time

def get_apspl_mat(obj):
    return list(obj)

def exact_computation_wrapped(G, graphname):
    if isinstance(G, nx.DiGraph):
        gtype = "scc"
        scc_lst, _ = load_or_do(graphname + "_" + gtype + "_list.pkl", True, get_scc, G)
        largest_scc, _ = load_or_do(graphname + "_largest_" + gtype + ".pkl", True, get_largest_cc, scc_lst)
        largest_scc_len = len(largest_scc)
        largest_scc_mat = load_or_do(graphname + "_shortestpath_" + gtype + ".pkl", True, get_apspl_mat,
                                    nx.all_pairs_shortest_path_length(largest_scc))
        stats = get_stats(largest_scc_mat)
    else:
        gtype = "cc"
        cc_lst, _ = load_or_do(graphname + "_" + gtype + "_list.pkl", True, get_cc, G)
        largest_cc, _ = load_or_do(graphname + "_largest_" + gtype + ".pkl", True, get_largest_cc, cc_lst)
        largest_cc_len = len(largest_cc)

        largest_cc_mat = load_or_do(graphname + "_shortestpath_" + gtype + ".pkl", True, get_apspl_mat,
                                    nx.all_pairs_shortest_path_length(largest_cc))
        stats = get_stats(largest_cc_mat, directed=False)

    return stats

def reservoir_sampling_edges(G, dim, n_repetitions, p_samples, directed):
    samples_mat_p = []
    for p in p_samples:
        samples_count = int(dim*p)
        #print(samples_count)
        samples_mat = []
        for n in n_repetitions:
            sampled_sub_graphs = []
            for i in range(n):
                subG = create_empty_graph(directed)

                counter = 0
                for t, edge in enumerate(G.edges):
                    prob = np.random.uniform()
                    threshold = min(float(samples_count)/(t+1), 1)

                    if prob <= threshold:
                        subG.add_edge(edge[0], edge[1])
                        counter +=1
                    if counter == samples_count:
                        break
                sampled_sub_graphs.append(subG)
            samples_mat.append(sampled_sub_graphs)
        samples_mat_p.append(samples_mat)
    return samples_mat_p


def reservoir_sampling_nodes(G, dim, n_repetitions, p_samples, directed):
    samples_mat_p = []
    for p in p_samples:
        samples_count = int(dim*p)
        #print(samples_count)
        samples_mat = []
        for n in n_repetitions:
            sampled_sub_graphs = []
            for i in range(n):
                subset = []

                counter = 0
                for t, node in enumerate(G.nodes):
                    prob = np.random.uniform()
                    threshold = min(float(samples_count)/(t+1), 1)

                    if prob <= threshold:
                        subset.append(node)
                        counter +=1
                    if counter == samples_count:
                        break
                sampled_sub_graphs.append(subset)
            samples_mat.append(sampled_sub_graphs)
        samples_mat_p.append(samples_mat)
    return samples_mat_p

def create_empty_graph(directed):
    if directed:
        G = nx.DiGraph()
    else:
        G = nx.Graph()
    return  G