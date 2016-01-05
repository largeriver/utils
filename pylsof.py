#!/usr/bin/env python
# coding:utf8
# 打印手机上指定pid进程的详细信息
from __future__ import print_function

__author__ = 'tianxuefeng'

import os
import sys
import re

adb = "adb -P 15037"

sockets_info = dict()

def getstatusoutput(cmd):
	"""Return (status, output) of executing cmd in a shell."""
	# pipe = os.popen('{ ' + cmd + '; } 2>&1', 'r')
	pipe = os.popen(cmd + ' 2>&1', 'r')
	text = pipe.read()
	sts = pipe.close()
	if sts is None: sts = 0
	if text[-1:] == '\n': text = text[:-1]
	return sts, text


def exec_adb_cmd(*args):
	cmd_args = [adb, 'shell']
	cmd_args.extend(args)
	cmd = ' '.join(cmd_args)
	status, output = getstatusoutput(cmd)
	return status, output

def proc_path(pid,name):
	return '/'.join(('/proc',str(pid),name))

def print_cmdline(pid):
	s, cmdline = exec_adb_cmd("cat",proc_path(pid,'cmdline'))
	print("cmdline:", cmdline)


def print_status(pid):
	s, status = exec_adb_cmd("cat",proc_path(pid,'status'))
	for line in status.split("\n"):
		if 'Name:' in line: print(line)
		if 'Uid:' in line: print(line)
		if 'Gid:' in line: print(line)
		if 'Groups:' in line: print(line)

def print_fdinfo(pid):
	'''
		-wx------ root	   root				 2010-01-02 23:11 1 -> /dev/null
		lrwx------ root		root			  2010-01-02 23:11 10 -> /newplus_temp/SoftSupport/TG3SMEM_X_FontShareCache_48579487
		lrwx------ root		root			  2010-01-02 23:11 11 -> socket:[7502]
	'''

	s, fds = exec_adb_cmd("ls -l",proc_path(pid,'fd') )
	fdinfos=list()

	for line in fds.split("\n"):
		dac_perm,dac_uid,dac_gid,_,_,fd,_,name = line.split()
		fi = dict(perm=dac_perm,uid=dac_uid,gid=dac_gid,fd=fd,name=name)

		#print(fi)
		if name.startswith("socket:"):
			fi['inode'] =re.findall('(\d+)',name)[0]
			try:
				si = sockets_info[fi['inode']]
				print('fd:{fd}\t{uid}:{gid}:{perm}\t{inode} {domain}:{name}'.format(fd=fi['fd'],uid=fi['uid'],gid=fi['gid'],perm=fi['perm'],name=si['desc'],domain=si['domain'],inode=name))
			except:
				print('fd:{fd}\t{uid}:{gid}:{perm}\t{name}'.format(fd=fi['fd'],uid=fi['uid'],gid=fi['gid'],perm=fi['perm'],name=name))
			
		else:
			print('fd:{fd}\t{uid}:{gid}:{perm}\t{name}'.format(fd=fi['fd'],uid=fi['uid'],gid=fi['gid'],perm=fi['perm'],name=name))

		fdinfos.append(fi)
		
def print_maps(pid):
	'''
	7fb6087000-7fb6088000 r-xp 00000000 b3:15 3993							 /system/vendor/lib64/libril-qcril-hook-oem.so
	7fb6088000-7fb6097000 ---p 00000000 00:00 0 
	7fb6097000-7fb6098000 r--p 00000000 b3:15 3993							 /system/vendor/lib64/libril-qcril-hook-oem.so
	7fb6098000-7fb6099000 rw-p 00001000 b3:15 3993							 /system/vendor/lib64/libril-qcril-hook-oem.so
	7fb6099000-7fb609a000 r-xp 00000000 b3:15 4001							 /system/vendor/lib64/libsmemlog.so
	'''
	s, maps = exec_adb_cmd("cat",proc_path(pid,'maps') )
	prev = None
	for line in maps.split('\n'):
		_as = line.split()
		if len(_as) != 6:
			continue
		lib = _as[-1]
		if lib.startswith('['):
			continue
		if prev == lib:
			continue
		#print(prev,lib)
		prev = lib
		print(_as[0],_as[-1])
		
			

def analysis_unix_domain(pid=None):
	'''
		Here  "Num"	 is	 the kernel table slot number, "RefCount" is the number of users of the socket, "Protocol" is currently always 0, "Flags" represent the internal kernel flags holding
		the status of the socket.  Currently, type is always "1" (UNIX domain datagram sockets are not yet supported in the kernel).  "St" is the internal state of the socket	and	 Path  is
		the bound path (if any) of the socket.
	'''
	global	sockets_info
	if pid:
		s,sockets = exec_adb_cmd("cat /proc/net/unix")
	else:
		s,sockets = exec_adb_cmd("cat /proc/{}/net/unix".format(pid))
	for line in sockets.split('\n')[1:]:
		si=dict(zip(['Num','RefCount','Protocol','Flags','Type','St','inode','path'],line.split()))
		si['domain']='unix'
		si['desc']='{}'.format(si['path'] if si.has_key('path') else " ")
		#print("{}:{} {}".format(si['domain'],si['inode'],si['desc']))
		sockets_info[si['inode']] = si

def analysis_tcp_domain(pid=None):
	'''
  sl  local_address rem_address	  st tx_queue rx_queue tr tm->when retrnsmt	  uid  timeout inode
   0: 0100007F:11D7 00000000:0000 0A 00000000:00000000 00:00000000 00000000 21000		 0 11797 1 0000000000000000 100 0 0 10 0
   1: 0100007F:0BB8 00000000:0000 0A 00000000:00000000 00:00000000 00000000		0		 0 7818 1 0000000000000000 100 0 0 10 0
   2: 0100007F:13BA 00000000:0000 0A 00000000:00000000 00:00000000 00000000 21000		 0 49283 1 0000000000000000 100 0 0 10 0
	'''
	global	sockets_info
	if pid:
		s,sockets = exec_adb_cmd("cat /proc/net/tcp")
	else:
		s,sockets = exec_adb_cmd("cat /proc/{}/net/tcp".format(pid))
	for line in sockets.split('\n')[1:]:
		si=dict(zip(['sl','local_address','rem_address','st','tx_queue','rx_queue','tr tm->when retrnsmt','uid','timeout','inode'],line.split()))
		si['domain']='tcp'
		ip,port=si['local_address'].split(':')
		si['desc']='{ip}:{port} {uid}'.format(ip=ip,port=int(port,base=16),uid=si['uid'])
		#print("{}:{} {}".format(si['domain'],si['inode'],si['desc']))
		sockets_info[si['inode']] = si


def analysis_udp_domain(pid=None):
	'''
  sl   local_address rem_address   st tx_queue			rx_queue	tr	  tm->when retrnsmt	  uid  timeout inode ref pointer drops
  118: 0100007F:1A86 00000000:0000 07 00000000:00000000 00:00000000 00000000					0		 0 7088	  2 0000000000000000 0
	'''
	global	sockets_info
	if pid:
		s,sockets = exec_adb_cmd("cat /proc/net/udp")
	else:
		s,sockets = exec_adb_cmd("cat /proc/{}/net/udp".format(pid))
	for line in sockets.split('\n')[1:]:
		si=dict(zip(['sl','local_address','rem_address','st','tx_queue','rx_queue','tr tm->when retrnsmt','uid','timeout','inode','ref','pointer','drops'],line.split()))
		si['domain']='udp'
		ip,port=si['local_address'].split(':')
		si['desc']='{ip}:{port} uid:{uid}'.format(ip=ip,port=int(port,base=16),uid=si['uid'])
		#print("{}:{} {}".format(si['domain'],si['inode'],si['desc']))
		sockets_info[si['inode']] = si

def print_process(pid):
	s, status = exec_adb_cmd("ls /proc/%d".format(pid))
	print_cmdline(pid)
	print_status(pid)
	print_fdinfo(pid)
	print_maps(pid)


if __name__ == "__main__":
	try:
		pid = int(sys.argv[1])
	except:
		print("usage:{} pid".format(sys.argv[0]))
		quit(1)

	analysis_unix_domain(pid)
	analysis_tcp_domain(pid)
	analysis_udp_domain(pid)

	print_process(pid)


