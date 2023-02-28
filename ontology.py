import os
import sys
import shutil
from lxml import etree

XML_TOP = """<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:pithia="https://metadata.pithia.eu/ontology/2.2/"
    xmlns:owlxml="http://www.w3.org/2006/12/owl2-xml#"
>"""

def build():
    # capturing xml file name and creating its folder if not exists
    root_path = os.path.normpath('/var/www/pithia.eu/html/ontology/2.2/')
    home_folder = sys.argv[1].split('.')[0]
    home_path = os.path.normpath(os.path.join(root_path,home_folder))
    if not os.path.exists(home_path):
        os.mkdir(home_path)
    shutil.copyfile(f'/home/metadata/ontology/2.2/{sys.argv[1]}', home_path + '/index.xml')
    # read text files with members coming from xmllint and extract members' content
    with open('/home/ubuntu/ontology_temp.txt') as f:
        text = f.read()
    members = text.split('\n\n')
    count = 0
    for member in members:
        count += 1
        if '<skos:Concept' in member:
               # build xml temp file for one member
            try:
                member_text = XML_TOP + member + "\n</rdf:RDF>"
                member_tmp_path = os.path.join(home_path, f'temp-{count}.xml')
                with open(member_tmp_path,"w") as w:
                    w.write(member_text)
                # build xml final file for one member
                print('PARSE TMP:', member_tmp_path)
                xml_file_parsed = etree.parse(member_tmp_path)
                xml_root = xml_file_parsed.getroot()
                # alt_label = xml_root.xpath("//*[local-name()='altLabel']/text()")
                # member_folder = os.path.join(home_path, f'{alt_label[0]}')
                for child in xml_root:
                    member_name = child.xpath("//@*")[0].rsplit('/', 1)[-1]
                member_folder = os.path.join(home_path, member_name)
                if not os.path.exists(member_folder):
                    os.mkdir(member_folder)
                member_path = os.path.join(member_folder, 'index.xml')
                with open(member_path,"w") as w:
                    w.write(member_text)
                os.remove(member_tmp_path)
                print('WRITE XML:', member_path)
            except Exception as e:
                print('ERROR:', e)
    os.remove('/home/ubuntu/ontology_temp.txt')

if __name__ == '__main__':
    build()
