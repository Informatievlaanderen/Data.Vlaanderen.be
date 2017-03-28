cd $(dirname $(readlink -f $0))
virtualenv -p python3 specgen
cd specgen
. bin/activate
cd OSLO-SpecificationGenerator
git pull origin master
pip install -r requirements.txt
python3 setup.py build
python3 setup.py install
