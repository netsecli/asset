#!/usr/bin/python
# -*- coding: UTF-8 -*-
from elasticsearch import Elasticsearch
import sys
import re
import json
import time
import getopt
import xml.etree.ElementTree as xml


class NmapES:

	def __init__(self, input_file,es_ip,es_port,index_name,es_user,es_pass):
		self.input_file = input_file
		self.tree = self.__importXML()
		self.root = self.tree.getroot()
		self.es = Elasticsearch([{'host':es_ip,'port':es_port}],http_auth=(es_user,es_pass))
		self.index_name = index_name

	def displayInputFileName(self):
		print self.input_file

	def __importXML(self):
		return xml.parse(self.input_file)

	def toES(self):

		for h in self.root.iter('host'):

			dict_item = {}
			dict_item['scanner'] = 'nmap'
			if h.tag == 'host':
				if 'endtime' in h.attrib and h.attrib['endtime']:
					dict_item['time'] = time.strftime('%Y/%m/%d %H:%M:%S', time.gmtime(float(h.attrib['endtime'])))
			
			for c in h:
				if c.tag == 'address' and c.attrib['addrtype'] == 'ipv4':
					if c.attrib['addr']:
						dict_item['ip'] = c.attrib['addr']

				elif c.tag == 'hostnames':
					for names in c.getchildren():
						if names.attrib['name']:
							dict_item['hostname'] = names.attrib['name']

				elif c.tag == 'ports':
					for port in c.getchildren():
						dict_item_ports = {}
						if port.tag == 'port':
							# print(port.tag, port.attrib)
							dict_item_ports['port'] = port.attrib['portid']
							dict_item_ports['protocol'] = port.attrib['protocol']
							for p in port.getchildren():
								if p.tag == 'state':
									dict_item_ports['state'] = p.attrib['state']
								elif p.tag == 'service':
									dict_item_ports['service'] = p.attrib['name']
									if 'product' in p.attrib and p.attrib['product']:
										dict_item_ports['product_name'] = p.attrib['product']
										if 'version' in p.attrib and p.attrib['version']:
											dict_item_ports['product_version'] = p.attrib['version']
									if 'banner' in p.attrib and p.attrib['banner']:
										dict_item_ports['banner'] = p.attrib['banner']
								elif p.tag == 'script':
									if p.attrib['id']:
										if p.attrib['output']:
											# dict_item_ports[p.attrib['id']] = p.attrib['output']
											if 'scripts' in dict_item_ports:
												dict_item_ports['scripts'][p.attrib['id']] = p.attrib['output']
											else:
												dict_item_ports['scripts'] = dict()
												dict_item_ports['scripts'][p.attrib['id']] = p.attrib['output']
													
							to_upload = merge_two_dicts(dict_item, dict_item_ports)	
							if to_upload['state'] == 'open':
								self.es.index(index=self.index_name,doc_type="vuln", body=json.dumps(to_upload))


def merge_two_dicts(x, y):
    z = x.copy()   # start with x's keys and values
    z.update(y)    # modifies z with y's keys and values & returns None
    return z


def usage():
	print "Usage: nmap_es.py [-i input_file ] [-e elasticsearch_ip ] [-p elasticsearch_port ] [-I index_name] [-r report_type | --report_type=type] [-s name=value]  [-u username=value] [-P password=value] [-h | --help]"


def main():
	letters = 'i:I:e:p:r:s:u:P:h' #input_file, index_name es_ip_address, report_type, create_sql, create_xml, help
	keywords = ['input-file=', 'index_name=', 'es_ip=','es_port=','report_type=', 'static=', 'es_user=', 'es_pass=', 'help' ]
	try:
		opts, extraparams = getopt.getopt(sys.argv[1:], letters, keywords)
	except getopt.GetoptError, err:
		print str(err)
		usage()
		sys.exit()
	
	in_file = ''
	es_ip = ''
	es_port = 9200
	report_type = ''
	index_name = ''
        es_user = ''
        es_pass = ''
        static_fields = dict()

	for o,p in opts:
		if o in ['-i','--input-file=']:
			in_file = p
		elif o in ['-r', '--report_type=']:
			report_type = p
		elif o in ['-e', '--es_ip=']:
			es_ip=p
		elif o in ['-p', '--es_port=']:
			es_port=p
		elif o in ['-I', '--index_name=']:
			index_name=p
		elif o in ['-s', '--static']:
			name, value = p.split("=", 1)
			static_fields[name] = value
                elif o in ['-u', '--es_user=']:
			es_user=p
		elif o in ['-P', '--es_pass=']:
			es_pass=p
		elif o in ['-h', '--help']:
			usage()
			sys.exit()

	if (len(sys.argv) < 1):
		usage()
		sys.exit()

	try:
		with open(in_file) as f: pass
	except IOError as e:
		print "Input file does not exist. Exiting."
		sys.exit()

	if report_type.lower() == 'nmap':
    
		np = NmapES(in_file,es_ip,es_port,index_name,es_user,es_pass)
		np.toES()
		print "数据导入完毕！"

	else:
		print "类型输入错误！类型为：nmap" 
		sys.exit()

if __name__ == "__main__":
	main()
