"""script to run closest unit tests"""
import os
from subprocess import call

query_dir = os.getcwd()
files = os.listdir(query_dir)
if 'tests.py' in files and '__init__.py' in files:
    module_name = os.path.basename(query_dir)

root_dir = ''
while query_dir is not '/':
    query_dir = os.path.dirname(query_dir)
    if 'manage.py' in os.listdir(query_dir):
        root_dir = query_dir
        break

if root_dir:
    call("python {}/manage.py test".format(root_dir), shell=True)
