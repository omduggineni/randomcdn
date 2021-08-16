import hashlib
import os
import glob
from tqdm import tqdm

def f2sym(filename, hash_fname):
    filename_list = filename.split("/")
    filename = filename_list[-1]
    filename_list = [".." for x in filename_list]
    filename_list[-1] = hash_fname
    return "/".join(filename_list)

def hash(filename):
    sha256 = hashlib.sha256()

    with open(filename, 'rb') as f:
        while True:
            data = f.read(1024)
            if not data:
                break
            sha256.update(data)
    return "files/" + sha256.hexdigest() + "." + filename.split(".")[-1]

files = glob.glob("named/**/*.*") + glob.glob("named/*.*")
files = [x for x in files if not os.path.islink(x)]
file_hashes = [hash(x) for x in tqdm(files)]
symlink_paths = [f2sym(x, hash_x) for x, hash_x in zip(tqdm(files), file_hashes)]

for file, file_hash, symlink_path in zip(tqdm(files), file_hashes, symlink_paths):
    print(f"mv '{file}' '{file_hash}'")
    os.system(f"mv '{file}' '{file_hash}'")
    print(f"ln -s '{symlink_path}' '{file}'")
    os.system(f"ln -s '{symlink_path}' '{file}'")
