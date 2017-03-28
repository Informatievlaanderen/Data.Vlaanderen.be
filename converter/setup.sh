virtualenv -p python3 specgen
cd $(dirname $(readlink -f $0))
cd specgen
. bin/activate
git clone https://github.com/InformatieVlaanderen/OSLO-SpecificationGenerator.git
cd OSLO-SpecificationGenerator
pip install -r requirements.txt
python3 setup.py build
python3 setup.py install
