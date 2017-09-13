import os
import sys
import subprocess


models = {}
models['besluit'] = {
    'stakeholders_csv': 'stakeholders_lblod.csv',
    'stakeholders_csv_column': 'Besluit',
    'source_voc': 'besluit.ttl',
    'source_ap': 'Besluit Publicatie AP.tsv',
    'template_voc': 'vocabularynlv2',
    'template_ap': '',
    'target_ap': 'besluit'
}

if len(sys.argv) == 1 or sys.argv[1] not in models.keys():
    valid_names = list(models.keys())
    valid_names.sort()
    print('Usage: %s <name>' % sys.argv[0])
    print('With name one of: ', valid_names)
    exit(0)

script = './specgen/OSLO-SpecificationGenerator/bin/generate_vocabulary.py'
if not os.path.isfile(script):
    print('This file expects the OSLO-SpecificationGenerator to be installed in this directory.')
    print('Could not find file: ' + script)
    exit(1)


model_name = sys.argv[1]
print('Processing ' + model_name)
model = models[model_name]


# Convert CSV of contributors to RDF for merging
stakeholders_rdf = './../src/temp-%s-%s.rdf' % (model['stakeholders_csv'], model_name)
subprocess.run(['python', script,
                '--contributors',
                '--csv', './../src/' + model['stakeholders_csv'],
                '--target', model['stakeholders_csv_column'],
                '--output', stakeholders_rdf
                ])

# Merge stakeholders RDF with vocabulary TTL
subprocess.run(['python', script,
                '--merge',
                '--rdf', './../src/' + model['source_voc'],
                '--rdf_contributor', stakeholders_rdf,
                '--output', './../ns/' + model['source_voc']
                ])

# Generate documentation for vocabulary
subprocess.run(['python', script,
                '--rdf', './../ns/' + model['source_voc'],
				'--schema', model['template_voc'],
                '--output', './../ns/%s.html' % model_name
                ])

# Generate documentation for AP
subprocess.run(['python', script,
                '--ap',
                '--csv', './../src/' + model['source_ap'],
                '--csv_contributor', './../src/' + model['stakeholders_csv'],
                '--output', './../doc/ap/%s/index.html' % model['target_ap']
                ])