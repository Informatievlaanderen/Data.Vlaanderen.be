import os
import sys
import subprocess


models = {}
models['persoon'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Persoon',
    'source_voc': 'persoon.ttl',
    'source_ap': 'Persoon_Basis_AP.tsv',
    'template_voc': 'persoon-voc.j2',
	'template_ap': 'persoon-ap.j2',
	'title_ap': 'Persoon Basis AP',
    'target_ap': 'persoon'
}
models['adres'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Adres',
    'source_voc': 'adres.ttl',
    'source_ap': 'Adresregister_AP.tsv',
    'template_voc': 'adres-voc.j2',
    'template_ap': 'adres-ap.j2',
    'title_ap': 'Adresregister',
    'target_ap': 'adresregister'
}
models['organisatie'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Organisatie',
    'source_voc': 'organisatie.ttl',
    'source_ap': 'Organisatie_Basis_AP.tsv',
    'template_voc': 'organisatie-voc.j2',
    'template_ap': 'organisatie-ap.j2',
    'title_ap': 'Organisatie Basis AP',
    'target_ap': 'organisatie'
}
models['generiek'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Generiek',
    'source_voc': 'generiek.ttl',
    'source_ap': 'Generiek_Basis_AP.tsv',
    'template_voc': 'generiek-voc.j2',
    'template_ap': 'generiek-ap.j2',
    'title_ap': 'Generiek Basis AP',
    'target_ap': 'generiek'
}
models['dienst'] = {
    'stakeholders_csv': 'stakeholders_latest.csv',
    'stakeholders_csv_column': 'Dienst',
    'source_voc': 'dienst.ttl',
    'source_ap': 'Dienstencataloog_AP.tsv',
    'template_voc': 'dienst-voc.j2',
    'template_ap': 'dienst-ap.j2',
    'title_ap': 'Dienstencataloog AP',
    'target_ap': 'dienstencataloog'
}

if len(sys.argv) == 1 or sys.argv[1] not in models.keys():
    valid_names = list(models.keys())
    valid_names.sort()
    print('Usage: %s <name>' % sys.argv[0])
    print('With name one of: ', valid_names)
    exit(0)

script = 'D:\MyVirtualEnv/OSLO-SpecificationGenerator/specgen/generate_vocabulary.py'
if not os.path.isfile(script):
    print('This file expects the OSLO-SpecificationGenerator to be installed in this directory.')
    print('Could not find file: ' + script)
    exit(1)


model_name = sys.argv[1]
print('Processing ' + model_name)
model = models[model_name]


# Convert CSV of contributors to RDF for merging
print('Converting CSV of contributors to RDF for merging.')
stakeholders_rdf = 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/temp-%s-%s.rdf' % (model['stakeholders_csv'], model_name)
subprocess.run(['python', script,
                '--contributors',
                '--csv', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/' + model['stakeholders_csv'],
                '--csv_contributor_role_column', model['stakeholders_csv_column'],
                '--output', stakeholders_rdf
                ])

# Merge contributors RDF with vocabulary TTL
print('Merging contributors RDF with vocabulary RDF.')
subprocess.run(['python', script,
                '--merge',
                '--rdf', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/' + model['source_voc'],
                '--rdf_contributor', stakeholders_rdf,
                '--output', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/ns/' + model['source_voc']
                ])

# Generate documentation for vocabulary
print('Generating vocabulary documentation.')
subprocess.run(['python', script,
                '--rdf', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/ns/' + model['source_voc'],
				'--schema', model['template_voc'],
                '--output', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/ns/%s/index.html' % model_name
                ])

# Generate JSON-LD context
print('Generating JSON-LD context.')
subprocess.run(['python', 'D:\MyVirtualEnv/OSLO-SpecificationGenerator/specgen/generate_jsonld.py',
                '--input', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/' + model['source_ap'],
                '--output', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/context/%s.jsonld' % model_name
                ])

# Generate documentation for AP
print('Generating AP documentation.')
subprocess.run(['python', script,
                '--ap',
				'--title', model['title_ap'],
                '--csv', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/' + model['source_ap'],
                '--csv_contributor', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/src/' + model['stakeholders_csv'],
				'--csv_contributor_role_column', model['stakeholders_csv_column'],
				'--schema', model['template_ap'],
                '--output', 'D:\Werk\OSLO-Vocabularia-november_publicatie\OSLO-Vocabularia-november_publicatie/doc/applicatieprofiel/%s/index.html' % model['target_ap']
                ])

print('Done!')