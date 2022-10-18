CREATE OR REPLACE FUNCTION PY_LOAD_KML(PATH_TO_FILE string)
returns table (wkb binary, properties object)
language python
runtime_version = 3.8
imports=('@geostage/archive.zip')
packages = ('fiona', 'shapely')
handler = 'KMLReader'
AS $$
import fiona
from shapely.geometry import shape
import sys
IMPORT_DIRECTORY_NAME = "snowflake_import_directory"
import_dir = sys._xoptions[IMPORT_DIRECTORY_NAME]

class KMLReader:        
    def process(self, PATH_TO_FILE: str):
      fiona.drvsupport.supported_drivers['libkml'] = 'rw' # enable KML support which is disabled by default
      fiona.drvsupport.supported_drivers['LIBKML'] = 'rw' # enable KML support which is disabled 
      shapefile = fiona.open(f"zip://{import_dir}/archive.zip/{PATH_TO_FILE}")
      for record in shapefile:
        yield ((shape(record['geometry']).wkb, dict(record['properties'])))
$$;

-- An example of how to call the function
SELECT * FROM table(PY_LOAD_KML('linestring.kml'));