import os
import pickle
import time

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
        # print("Cache for {} was not available, running the function instead..".format(name))
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
    distribution = []
    for src_node, min_dist_list in mat:
        for target_node, min_dist in min_dist_list.items():
            distribution.append(min_dist)
    return distribution

def diameter(distribution):
    return np.max(distribution)

def eff_diam(distribution):
    return np.percentile(distribution, 90)

def mean_diam(distribution):
    return np.mean(distribution)

def median_diam(distribution):
    return np.median(distribution)

def get_stats(distribution):
    return [diameter(distribution), eff_diam(distribution), mean_diam(distribution), median_diam(distribution)]

def exact_computation(G, dG, graphname):
    start_time = time.time()

    stats_cc, stats_scc = exact_computation_wrapped(G, dG, graphname)

    end_time = time.time()
    run_time = end_time - start_time
    return stats_cc, stats_scc, run_time

def exact_computation(fh, graphname):
    start_time = time.time()

    dG = nx.read_adjlist(fh, create_using=nx.DiGraph())
    G = dG.to_undirected()

    stats_cc, stats_scc = exact_computation_wrapped(G, dG, graphname)

    end_time = time.time()
    run_time = end_time - start_time

    return stats_cc, stats_scc, run_time

def exact_computation_wrapped(G, dG, graphname):
    cc_lst, _ = load_or_do(graphname + "_cc_list.pkl", True, get_cc, G)
    scc_lst, _ = load_or_do(graphname + "_scc_list.pkl", True, get_scc, dG)

    largest_cc, _ = load_or_do(graphname + "_largest_cc.pkl", True, get_largest_cc, cc_lst)
    largest_scc, _ = load_or_do(graphname + "_largest_scc.pkl", True, get_largest_cc, scc_lst)

    largest_cc_len = len(largest_cc)
    largest_scc_len = len(largest_scc)

    largest_cc_mat = nx.all_pairs_shortest_path_length(largest_cc)
    largest_scc_mat = nx.all_pairs_shortest_path_length(largest_scc)

    largest_cc_distribution = load_or_do(graphname + "_shortestpath_cc.pkl", True, get_distribution_lst, largest_cc_mat)
    largest_cc_stats = get_stats(largest_cc_distribution)

    largest_scc_distribution = load_or_do(graphname + "_shortestpath_scc.pkl", True, get_distribution_lst,
                                          largest_scc_mat)
    largest_scc_stats = get_stats(largest_scc_distribution)    

    return largest_cc_stats, largest_scc_stats