from hashlib import md5
import json
import os
import pickle


CACHE_DIR = "dmproject/dataset"


def save_to_cache(name, object):
    print("Caching {}...".format(name))
    file_name = "{}.cache".format(name)
    file_path = os.path.join(CACHE_DIR, file_name)
    with open(file_path, "wb") as cache_file:
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


def load_or_do(name, f, save_if_not_found=False, *args, **kwargs):
    try:
        obj = load_from_cache(name)
    except FileNotFoundError as e:
        print("Cache for {} was not available, running the function instead..".format(name))
        obj = f(*args, **kwargs)

        if save_if_not_found:
            save_to_cache(name, obj)

    return obj
