#! /usr/bin/python3

from shutil import copyfile
from argparse import ArgumentParser

from stat import S_IXUSR, S_IXGRP, S_IXOTH
import re

from os import scandir, chmod, stat, environ
from os.path import join, isdir, isfile

from hashlib import sha512


def get_files():
    regex = re.compile(r'^(?!_)\w+\.zsh')
    files = filter(lambda x: x.is_file(), scandir())
    for file in files:
        match = regex.match(file.name)
        if match:
            out = file.name
            yield out


def get_path():
    dirs = environ['PATH']
    return dirs.split(':')

def get_dir():
    tmp = get_path()
    return tmp[0]

def get_file_hash(file_name):
    sha = sha512()
    with open(file_name, 'rb') as file:
        sha.update(file.read())
    return sha.digest()

def check_update(file_a, file_b):
    sha_a = get_file_hash(file_a)
    sha_b = get_file_hash(file_b)
    return sha_a != sha_b

def copy_files(dest, clean):
    for file in get_files():
        if clean:
            i = file.index('.')
            name = file[:i]
            tmp = join(dest, name)
        else:
            tmp = join(dest, file)

        if not isfile(tmp) or check_update(file, tmp):
            copyfile(file, tmp)
            curr = stat(tmp)
            chmod(tmp, curr.st_mode | S_IXUSR | S_IXGRP | S_IXOTH)
        else:
            msg = f'{file} is already update'
            print(msg)


def check_dir(path):
    if isdir(path):
        return path
    print(f'{path} is not a directory')
    exit(1)
    return None


def conf_args():
    out = ArgumentParser()

    def_dest = get_dir()

    root_help = f'set install directory, default:[{def_dest}] depends on your PATH variable'
    out.add_argument('-r', '--root',
                     help=root_help,
                     default=def_dest,
                     type=check_dir)

    out.add_argument('-c', '--clean', help='remove file extension once installed',
                     default=False, action='store_true')

    return out

def main():
    parse = conf_args()
    args = parse.parse_args()

    copy_files(args.root, args.clean)



if __name__ == '__main__':
    main()
