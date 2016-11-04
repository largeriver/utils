#!/usr/bin/env python3
import pip
from subprocess import call
for dist in pip.get_installed_distributions():
    print("updating ",dist.project_name)
    call("pip3 install --upgrade " + dist.project_name, shell=True)



