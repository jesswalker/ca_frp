#-------------------------------------------------------------------------------
# Name:        intersect_frp_data_with_fire_perimeters.py
# Purpose:
#
# Author:      jjwalker
#
# Created:     21/05/2018
# Copyright:   (c) jjwalker 2018
# Licence:     <your licence>
#-------------------------------------------------------------------------------

# Import arcpy module
import arcpy, os, csv

# Overwrite existing files
arcpy.env.overwriteOutput = True

# These files have to exist:
# ----------- User input required here -------------------------

# Arc workspace
arcpy.env.workspace = "E:\\OneDrive - DOI\\projects\\ca_frp\\gis\\data" 
csvfolder = "E:\\OneDrive - DOI\\projects\\ca_frp\\data"  
original_polys = "firep20_gte1000ac_ca.shp" #"firePerimeters_1940_2016_gt1000ac_notPrescribed.shp"


# -------------------------------------------------------------



csvfile = os.path.join(csvfolder, "maxFRP_CA_gte4sqkm_2002to2020_processed_slim.csv")
print('*** Processing ' + csvfile)
try:
    # Set local variables
    x_coords = "longitude"
    y_coords = "latitude"
    out_layer = "consolidated_layer"

    sp_ref2 = r"Coordinate Systems\Geographic Coordinate Systems\World\WGS 1984.prj"

    # Set spatial reference
    sp_ref = "GEOGCS['GCS_WGS_1984',DATUM['D_WGS_1984',SPHEROID['WGS_1984',6378137.0,298.257223563]],\
                PRIMEM['Greenwich',0.0],UNIT['Degree',0.0174532925199433]];\
                -400 -400 1000000000;-100000 10000;-100000 10000;8.98315284119522E-09;\
                0.001;0.001;IsHighPrecision"

    sr = arcpy.SpatialReference()
    sr.loadFromString(sp_ref)

    # Copy the table to in_memory to generate OIDs
    in_memory_table = arcpy.CopyRows_management(csvfile, r"in_memory\tbl")

    # Make XY event layer (may not be necessary)
    arcpy.MakeXYEventLayer_management(r"in_memory\tbl", x_coords, y_coords, out_layer, sr)

    print(arcpy.GetCount_management(out_layer))

except Exception as err:

    print(err.args[0])

# Intersect annual fire data with all fire perimeters
try:
    intersect_output = "consolidated_plus_fire_info"
    print("Intersection output: " + intersect_output + ".shp")
    arcpy.Intersect_analysis([out_layer, original_polys], intersect_output, "ALL", "", "INPUT")

except Exception as err:
    print(err.args[0])

# Define output table
outcsv = os.path.join("E:\\OneDrive - DOI\\projects\\ca_frp\\data\\", intersect_output + ".csv")

arcpy.CopyRows_management(intersect_output + ".shp", outcsv)

print("Table output: " + intersect_output + ".csv")

# Clean up
print 'Deleting files...'
arcpy.Delete_management('in_memory')












