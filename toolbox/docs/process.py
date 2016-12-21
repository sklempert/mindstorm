#!/usr/bin/python3

import os
from os import close, remove
from tempfile import mkstemp
from shutil import move

def preprocess():
    """Preprocesses data for building documentation

    The MATLAB Sphinx extension takes veeery (or even infinitely?) long
    to build the documentation if a class contains an enumeration.
    """

    code_dir = os.path.abspath('../source')
    files = _matlab_files(os.listdir(code_dir))
    
    n_files = len(files)
    for n, file_name in enumerate(files):
        # print("Preprocessing file {0} [{1}|{2}]".format(file_name, n+1, n_files))
        try:
            fh, abs_path = mkstemp()
            with open(code_dir + "/" + file_name, 'r') as f:
                with open(abs_path, 'w') as ftemp: 
                    content = f.readlines()
                    if content[0] == '%TEMP-FILE FOR BUILDING DOCUMENTATION\n':
                        raise RuntimeError('Found already preprocessed file.')

                    try:
                        for i, line in enumerate(content):  # Worst runtime ever 
                            if _ignore_line(line) is False and 'enumeration' in line:
                                ftemp.write('%TEMP-FILE FOR BUILDING DOCUMENTATION\n')
                                _write_lines(content[:i], ftemp)
                                for j, enum_line in enumerate(content[i:]):
                                   ftemp.write(" %"+enum_line)
                                   if " end" in enum_line or "end\n" == enum_line:		
                                        _write_lines(content[i+1+j:], ftemp)
                                        close(fh)
                                        remove(code_dir + "/" + file_name)
                                        move(abs_path, code_dir + "/" + file_name)
                                        # At this point, entire file has been processed: continue outer loop
                                        # Hackily implemented by raising an exception
                                        raise StopIteration  
                    except StopIteration:
                        continue
        except IOError:
            pass

def postprocess():
    code_dir = os.path.abspath('../source')
    files = _matlab_files(os.listdir(code_dir))
    
    n_files = len(files)
    for n, file_name in enumerate(files):
        # print("Postprocessing file {0} [{1}|{2}]".format(file_name, n+1, n_files))
        try:
            fh, abs_path = mkstemp()
            with open(code_dir + "/" + file_name, 'r') as f:
                with open(abs_path, 'w') as ftemp: 
                    content = f.readlines()
                    if content[0] != '%TEMP-FILE FOR BUILDING DOCUMENTATION\n':
                        continue
                    try:
                        for i, line in enumerate(content):  # Worst runtime ever
                            if 'enumeration' in line:
                                _write_lines(content[1:i], ftemp)
                                for j, enum_line in enumerate(content[i:]):
                                   ftemp.write(enum_line.replace(' %', '', 1))
                                   if " end" in enum_line or "end\n" == enum_line:
                                        _write_lines(content[i+1+j:], ftemp)
                                        close(fh)
                                        remove(code_dir + "/" + file_name)
                                        move(abs_path, code_dir + "/" + file_name)
                                        # At this point, entire file has been processed: continue outer loop
                                        # Hackily implemented by raising an exception
                                        raise StopIteration 
                    except StopIteration:
                        continue
        except IOError:
            pass
         
def _ignore_line(line) -> bool:
    return (line.startswith('%') or line == '\n' or line == '')

def _write_lines(lines, f):
    for line in lines:
        f.write(line)

def _matlab_files(files) -> list:
    return [f for f in files if (f.endswith(".m") and "_" not in f and "proto" not in f)]	
