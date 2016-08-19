#!/usr/bin/python

import sys
import re
import json
import io

def yamlHtml(n):

    print '<div class="node">'
    print '<div class="text">' + n['text'] + '</div>'

    cc = 'children'
    if 'direction' in n:
        if n['direction'] == 'left':
            cc = cc + ' directionLeft'

    if 'framed' in n:
        print n['framed']
        cc = cc + ' framed'

    if 'nodes' in n:
        print '<div class="' + cc + '">'
        for c in n['nodes']:
            yamlHtml(c)
        print '</div>'
    print '</div>'


# dumps the structure back to yaml format
def yamlDump(n, l=0):

    ret = ''

    tabs = '    '
    s = ''
    for i in range(l):
        s = s + tabs

    attribs = [ 'text' , 'name', 'style', 'direction', 'childrenDirection', 'framed', 'collapsed' ]
    for nn in attribs:
        if nn in n:
            t = n[nn].replace("\n", "\\n")
            if nn != 'text':
                t = tabs + nn + ': ' + t
            ret = ret + s + t + "\n"

    if 'nodes' in n:
        ret = ret + "\n"
        for c in n['nodes']:
            ret = ret + yamlDump(c, l+1)
        ret = ret + "\n"

    if 'edges' in n:
        ret = ret + tabs + 'edges:' + "\n"
        for e in n['edges']:
            n1 = e['n1']
            n2 = e['n2']
            ret = ret + tabs + tabs + n1 + ', ' + n2 + "\n"

    return ret

# cleans the parsed yaml file
def walkClean(n):

    n.pop('_level')
    if '_text' in n:
        n['text'] = n['_text']
        n.pop('_text')

    if len(n['nodes']) == 0:
        n.pop('nodes', 0)
        return

    edges = None
    for c in n['nodes']:

        if c['_text'] == 'edges':
            edges = c
            continue

        walkClean(c)

    if edges != None:
        n['nodes'].remove(edges)
        n['edges'] = []
        for e in edges['nodes']:
            m = e['_text'].split(',')
            if len(m) > 1:
                n['edges'].append( { 'n1': m[0].strip() , 'n2': m[1].strip() })
            # print e

def applyStyle(css, n):

    if css == None:
        return

    if 'nodes' not in n:
        return

    classes = []
    if '_class' in n:
        cc = [ c.strip() for c in n['_class'].split(' ') ]
        for cname in cc:
            for cs in css['nodes']:
                if cs['text'] == cname:
                    classes.append(cs)

    style = [ c for c in n['nodes']  if c['text'] == '_style' ]
    if len(style) > 0:
        style = style[0]
        classes.append(style)
    else:
        style = { 'text': '_style' }
        n['nodes'].append(style)

    nn = {}
    for cc in classes:
        for a in cc:
            nn[a] = cc[a]

    for a in nn:
        style[a] = nn[a]

    style['text'] = '_'

    for c in n['nodes']:
        applyStyle(css, c)

def newNode(t, l, p):

    n = '_text'
    v = t
    v = v.replace("\\n", "\n")

    m = re.search('(.*):(.*)', t)
    if m != None:
        nn = m.group(1).strip()
        vv = m.group(2).strip()
        if len(nn) > 0 and len(vv) > 0:
            p[nn] = vv
            return None

    v = v.replace(':','').strip()

    child = {
        '_level': l,
        n: v,
        'nodes': []
    }

    if p != None:
        p['nodes'].append(child)

    return child

def getLevel(line):
    level = 0
    m = re.search('^ *', line)
    if m != None:
        level = len(m.group(0))
    return level

list = []
lines = []

def parse(filepath):

    root = None

    fo = open(filepath, 'r')
    for line in fo:

        obj = None

        # print line
        # print '----'

        if len(list) > 0 :
            obj = list[ len(list) - 1 ]

        if len(line.strip()) == 0:
            continue

        text = line.strip()

        if obj == None:
            root = newNode(text, 0, None)
            list.append(root)
            continue

        line = line.replace('\t',' ')

        # get level
        level = getLevel(line)
        # print level

        while(level <= obj['_level']):
            if len(list) == 1:
                break
            list.pop()
            obj = list[ len(list) - 1 ]

        child = newNode(text, level, obj)
        if child != None:
            list.append(child)
            obj = child

    walkClean(root)

    # find css
    css = None
    if 'nodes' in root:
        cc = [ c for c in root['nodes']  if c['text'] == '_css' ]
        if len(cc) > 0:
            css = cc[0]

    applyStyle(css, root)
    return root

if sys.argv[0] == __file__:

    source = ''
    toHtml = '-html' in sys.argv
    toJson = '-yaml' not in sys.argv and not toHtml

    if len(sys.argv) > 1:
        source = sys.argv[len(sys.argv) - 1]

    if 'yaml' in source:
        root = parse(source)

        if toJson:
            target = source.replace('yaml','json')
            with io.open(target, 'w', encoding='utf-8') as f:
                  f.write(unicode(json.dumps(root, indent=1, sort_keys=True)))
            # print json.dumps(root, indent=1, sort_keys=True)

            # print css

        elif toHtml:

            print ' \
            <style> \
            .node { } \
            .text { } \
            .directionLeft { align:right } \
            .framed { border:1px solid red; } \
            .children { padding-left: 20px } \
            </style> \
            '

            yamlHtml(root)
        else:
            print yamlDump(root)
