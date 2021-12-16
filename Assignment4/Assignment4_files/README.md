# Get the code up and running

```console
sudo apt-get install libgdal-dev
sudo apt-get install python3-tk
gdal-config --version (place version in requirements) it will complain, pip useses a 4 digit version code
python3 -m venv env
source env/bin/activate
cd gis-lecture/code
pip3 install -r ./requirements.txt
```

# Known errors
1. Matplotlib requires freetype development header
```console
sudo apt-get install libfreetype-dev 
```
