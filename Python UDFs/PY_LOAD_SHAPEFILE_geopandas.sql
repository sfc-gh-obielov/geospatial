CREATE OR REPLACE FUNCTION  PY_LOAD_SHAPEFILE(PATH_TO_FILE string)
returns table (osm_id string, lastchange string, code integer, fclass string, 
               geomtype string, postalcode string, name string, geometry string)
language python
runtime_version=3.8
packages = ('geopandas')
imports=('@geostage/shapefiles_archive.zip')
handler='ReadShapefile'
as $$
import sys
import geopandas as gpd
import_dir = sys._xoptions["snowflake_import_directory"]

class ReadShapefile:
    def process(self, PATH_TO_FILE: str):
        gdf = gpd.read_file(f"zip://{import_dir}/shapefiles_archive.zip/{PATH_TO_FILE}")
        return tuple(gdf.itertuples(index=False, name=None))
$$;

-- An example of how to call the function
SELECT * FROM table(PY_LOAD_SHAPEFILE('<PATH_TO_FILE>'));