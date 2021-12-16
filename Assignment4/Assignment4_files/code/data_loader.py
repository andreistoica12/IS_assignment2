import os
from osgeo import ogr

class DataLoader:
	
	def load_shape_file(self,filename, database):

		shapefile = filename
		driver = ogr.GetDriverByName("ESRI Shapefile")
		dataSource = driver.Open(shapefile, 0)
		layer = dataSource.GetLayer()

  
		print(layer.GetFeatureCount())
		count = 0 
		while count < layer.GetFeatureCount():
		#for feature in layer:
			feature = layer.GetNextFeature()
			center = feature.GetGeometryRef().Centroid()
			database.insert([center.GetX(), center.GetY()])
			count = count + 1


	def load_wiki_example_data(self,database):
		data = [[2,3], [5,4], [9,6], [4,7], [8,1], [7,2]]
		database.insert_iterable(data)

	def load(self,args, database):
		if args.filename:
			self.load_shape_file(args.filename, database)	
		else:
			self.load_wiki_example_data(database)
