import os
import sys
import subprocess


models = {}
models['besluit'] = {
    'stakeholders_csv': 'stakeholders_lblod.csv',
    'stakeholders_csv_column': 'Besluit',
    'source_voc': 'besluit.ttl',
    'source_ap': 'Besluit Publicatie AP.tsv',
    'template_voc': 'vocabularynlv2.j2',
	'title_ap': 'Besluit Publicatie AP',
    'target_ap': 'besluit-publicatie'
}
models['mandaat'] = {
    'stakeholders_csv': 'stakeholders_lblod.csv',
    'stakeholders_csv_column': 'Mandaat',
    'source_voc': 'mandaat.ttl',
    'source_ap': 'Mandatendatabank AP.tsv',
    'template_voc': 'vocabularynlv2.j2',
	'title_ap': 'Mandatendatabank AP',
    'target_ap': 'mandatendatabank'
}
models['dienst'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Dienst',
    'source_voc': 'dienst.ttl',
    'source_ap': 'Dienstencataloog AP.tsv',
    'template_voc': 'vocabularynlv2.j2',
	'title_ap': 'Dienstencataloog AP',
    'target_ap': 'dienstencataloog'
}

if len(sys.argv) == 1 or sys.argv[1] not in models.keys():
    valid_names = list(models.keys())
    valid_names.sort()
    print('Usage: %s <name>' % sys.argv[0])
    print('With name one of: ', valid_names)
    exit(0)

script = './specgen/OSLO-SpecificationGenerator/specgen/generate_vocabulary.py'
if not os.path.isfile(script):
    print('This file expects the OSLO-SpecificationGenerator to be installed in this directory.')
    print('Could not find file: ' + script)
    exit(1)


model_name = sys.argv[1]
print('Processing ' + model_name)
model = models[model_name]


# Convert CSV of contributors to RDF for merging
print('Converting CSV of contributors to RDF for merging.')
stakeholders_rdf = './../src/temp-%s-%s.rdf' % (model['stakeholders_csv'], model_name)
subprocess.run(['python', script,
                '--contributors',
                '--csv', './../src/' + model['stakeholders_csv'],
                '--csv_contributor_role_column', model['stakeholders_csv_column'],
                '--output', stakeholders_rdf
                ])

# Merge contributors RDF with vocabulary TTL
print('Merging contributors RDF with vocabulary RDF.')
subprocess.run(['python', script,
                '--merge',
                '--rdf', './../src/' + model['source_voc'],
                '--rdf_contributor', stakeholders_rdf,
                '--output', './../ns/' + model['source_voc']
                ])

# Generate documentation for vocabulary
print('Generating vocabulary documentation.')
subprocess.run(['python', script,
                '--rdf', './../ns/' + model['source_voc'],
				'--schema', model['template_voc'],
                '--output', './../ns/%s.html' % model_name
                ])

# Generate documentation for AP
print('Generating AP documentation.')
subprocess.run(['python', script,
                '--ap',
				'--title', model['title_ap'],
                '--csv', './../src/' + model['source_ap'],
                '--csv_contributor', './../src/' + model['stakeholders_csv'],
				'--csv_contributor_role_column', model['stakeholders_csv_column'],
                '--output', './../doc/ap/%s/index.html' % model['target_ap']
                ])

print('Done!')