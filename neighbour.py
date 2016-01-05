#!/usr/bin/env python
# coding:utf8
from __future__ import print_function
import sys

try:
	lineno = int(sys.argv[1])
	file_path = sys.argv[2]
except:
	try:
		lineno = int(sys.argv[2])
		file_path = sys.argv[1]
	except:	
		print("usage:{0} lineno file_path".format(sys.argv[0]))
		print("usage:{0} file_path lineno".format(sys.argv[0]))
		exit(-1)

line_min = min(abs(lineno - 3),lineno)
line_max = lineno+7

with open(file_path) as f:
	for n,l in enumerate(f):
		if n >= line_min and n <= line_max:print("{}:{}".format(n,l),end="")
