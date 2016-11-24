#!/usr/bin/env python3
# Actually needs at least python 3.5

import re # regex

TEMPLATE = """<?xml version="1.0" encoding="iso-8859-1"?>
<!DOCTYPE workspaceElements PUBLIC "-//CPN//DTD CPNXML 1.0//EN" "http://cpntools.org/DTD/6/cpn.dtd">

<workspaceElements>
  <generator tool="CPN Tools"
             version="4.0.1"
             format="6"/>
  <cpnet>
    <globbox>
      <block id="ID1412310166">
        <id>Standard priorities</id>
        <ml id="ID1412310255">val P_HIGH = 100;
          <layout>val P_HIGH = 100;</layout>
        </ml>
        <ml id="ID1412310292">val P_NORMAL = 1000;
          <layout>val P_NORMAL = 1000;</layout>
        </ml>
        <ml id="ID1412310322">val P_LOW = 10000;
          <layout>val P_LOW = 10000;</layout>
        </ml>
      </block>
      <block id="ID1">
        <id>Standard declarations</id>
        <color id="ID85042">
          <id>UNIT</id>
          <unit/>
          <layout>colset UNIT = unit;</layout>
        </color>
        <color id="ID4">
          <id>BOOL</id>
          <bool/>
        </color>
        <color id="ID3">
          <id>INT</id>
          <int/>
        </color>
        <color id="ID1412312409">
          <id>INTINF</id>
          <intinf/>
          <layout>colset INTINF = intinf;</layout>
        </color>
        <color id="ID1412312425">
          <id>TIME</id>
          <time/>
          <layout>colset TIME = time;</layout>
        </color>
        <color id="ID1412322990">
          <id>REAL</id>
          <real/>
          <layout>colset REAL = real;</layout>
        </color>
        <color id="ID5">
          <id>STRING</id>
          <string/>
        </color>
      </block>
    </globbox>
    <page id="ID6">
      <pageattr name="New Page"/>
      {0}
      <constraints/>
    </page>
    <instances>
      <instance id="ID2149"
                page="ID6"/>
    </instances>
    <binders>
      <cpnbinder id="ID2222"
                 x="257"
                 y="122"
                 width="600"
                 height="400">
        <sheets>
          <cpnsheet id="ID2215"
                    panx="-0.000000"
                    pany="-0.000000"
                    zoom="1.000000"
                    instance="ID2149">
            <zorder>
              <position value="0"/>
            </zorder>
          </cpnsheet>
        </sheets>
        <zorder>
          <position value="0"/>
        </zorder>
      </cpnbinder>
    </binders>
  </cpnet>
</workspaceElements>"""

#
# Generic stuff
#
# int(__import__("time").time()))
UID = ('"ID' + str(i) + '"' for i in __import__("itertools").count(start=7))

def gen_attr(n, x, dx, y):
	result = [{'x': dx*i + x, 'y': y, 'i0': i, 'i1': i + 1}
		for i in range(0, n)]
	# print(result)
	return result

def format_element(tempalte, attr, **kwargs):
	return [tempalte.format(uid=next(UID), **{**el, **kwargs}) for el in attr ]

def find_substring_in_list_of_string(strings, *substrings):
	"""The name explains a lot, but you must know: it only returns the first match"""
	return [next((string for string in strings if substring in string)) for substring in substrings]

def mark_places(elements, positions_to_mark):
	for i in range(0,len(elements)):
		if i in positions_to_mark:
			elements[i] += """<initmark> <text>1`()</text> </initmark>"""
		elements[i] += "</place>"

#
# Specific stuff
#
def gen_places(prefix, suffix, n, x, dx, y, mark):
	template = """<place id={uid}> <text>{prefix}_{i1}{suffix}</text> <ellipse w="60" h="45"/> <posattr x="{x}" y="{y}"/>""" # The <place> tag in closed in the function mark (yuk)
	places = format_element(template, gen_attr(n, x, dx, y), prefix=prefix, suffix=suffix)
	mark_places(places, mark)
	return places

def gen_engager_transition(name, n, x, dx, y):
	template = """<trans id={uid}> <text>Engager_{i1}{name}</text> <box w="100" h="50"/> <posattr x="{x}" y="{y}"/></trans>"""
	return format_element(template, gen_attr(n, x, dx, y), name=name)

def gen_arc(elements, start, end, both_dir_p=False):
	"""Generate ONE arc"""
	# OMG this whole function is so hacky
	# Find the string in "elements" containing "start" or "end"
	text_match = find_substring_in_list_of_string(elements, start, end)
	# Extract the ids from those two strings
	id_re = 'id="(ID\w+)"'
	ids = [re.search(id_re, el).group(1) for el in text_match]
	# Extract the type
	types = [s[1].upper() for s in text_match]
	# Create the ends of the arc
	ends = []
	for i in range(0, 2):
		typename = ('place' if types[i] == 'P' else 'trans')
		ends.append("""<{0}end idref="{1}"/>""".format(typename, ids[i]))
	# return the arc
	return """<arc orientation="{0}">""".format('BOTHDIR' if both_dir_p else 'to'.join(types)) + ' '.join(ends) + "</arc>"

def gen_arcs(elements, n):
	"""Generate EVERY arcs"""
	arc_specs = []
	for name in ['a', 'b']:
		for i in range(0, n):
			index = [str(((i + j) % n) + 1) for j in range(0, n+1)] # Totally overkill
			n_index = [idx + name for idx in index]
			# O_ Places
			arc_specs.append(["O_" + n_index[0], "Engager_" + n_index[1]])
			arc_specs.append(["Engager_" + n_index[0], "O_" + n_index[0]])
			# E_ Places
			arc_specs.append(["E_" + index[0], "Engager_" + n_index[0]])
			arc_specs.append(["Engager_" + n_index[0], "E_" + index[1], True])
			arc_specs.append(["Engager_" + n_index[1], "E_" + index[0]])
	#for arc in arc_specs:
		#print(arc)
	return [gen_arc(elements, *spec) for spec in arc_specs]


def gen_core(n, dx, dy):
	places = sum([gen_places('O', 'a', n, 0, dx, dy, [1]),
	              gen_places('O', 'b', n, 0, dx, 0, [5]),
		      gen_places('E', '', n, -dx/4, dx, dy/2, [i for i in range(0,n) if i not in [1, 5]])],
		      []) # Neat trick / Hack
	transitions = sum([gen_engager_transition('a', n, -dx/2, dx, dy),
			   gen_engager_transition('b', n, -dx/2, dx, 0)], [])
	all = places + transitions
	arcs = gen_arcs(all, n)
	all.extend(arcs)
	return '\n'.join(all)

print(TEMPLATE.format(gen_core(7, 300, 400)))
# print(gen_core(7, 75, 100))




