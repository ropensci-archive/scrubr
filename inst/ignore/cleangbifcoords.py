#!/usr/bin/env python

	##################################################################################
	## this script takes an input GBIF dump formatted as tab delimited text, no header,
	## with at least three columns:
	#  - species name
	#  - latitude
	#  - longitude
	## it filters out coordinates exactly at a political centroid or major herbaria.
	## it implements the cleaning step in "Edwards EJ, De Vos JM, Donoghue MJ, in press.
	#  Brief Communications Arising: Doubtful pathways to cold tolerance in plants.
	#  Nature." that underlies the generation of the _groomed dataset from the data set
	#  _noDups (see the full script: (https://github.com/ejedwards/reanalysis_zanne2014/blob/master/handling_climate_data/getTminPerSpecies.py)
	# i.e., by default it assumes that duplicate records have already been removed

	## there are several ways to determine whether a specific locality near a "bad"
	#  coordinate is good or bad (i.e. is kept or discarded). Namely by asking for a coordinate (this script) or jointly for a set of localities (in the file https://github.com/ejedwards/reanalysis_zanne2014/blob/master/handling_climate_data/getTminPerSpecies.py) either:
	## 1. is any of the bad coordinates (as string) in the locality coordinates
	#  (as string)?
	#  For instance,
	#	>>>bad = ('1.12', '1.10')
	#	>>>x = ('1.123', '1.106')
	# 	>>>(bad[0] in x[0]) and (bad[1] in x[1])
	#  gives True
	#  By using tuples, it is possible to very fast compare sets of thousands of
	#  localities against thousands of bad coordinates.
	#  In effect, it determines whether a locality falls in the 0.01 x 0.01 gridcell of
	#  which the bad coordinate is the corner nearest the equator along the Greenwich
	#  meridian.
	#  The original script contained a mistake: because the expression
	#  >>>'0.83' in '10.83'
	#  also gives True, we erroneously excluded too many coordinates for the "_groomed"
	#  data set (e.g. 10.83,123.123 would be excluded if 0.83,123.12 were a specified
	#  "bad" coordinate). To fix this, we add leading zeros to each coordinate (asking
	#  >>>'000.83' in '010.83'
	## Alternatively,
	## 2. is any of the actual coordinate x  within the 0.01 x 0.01 grid cell of which the
	#  "bad" coordinate is the centre?
	#  For instance, using the same bad and x
	#   >>>round(float(bad[0]), 2) == round(float(x[0]), 2) and round(float(bad[1]), 2) == round(float(x[1]), 2)
	#  gives False
	#  In effect we determine whether we are less than 0.005 degree lat and 0.005 degree
	#  lon away from both bad coordinate. Because it entails pairwise comparisons between
	#  all members of two lists of coordinates, this approach is really slow and not
	#  usable for the Zanne et al. data.
	## By specifying all four corners of the 0.01 by 0.01 degree of the forbidden locality
	#  as "bad", we are sure to exclude the localities we want to exclude.
	## This script implents both methods. The default method "BadByString" is as used
	#   in our reply to Zanne et al.'s paper
	##################################################################################

import time
import sys

TimeStart = time.time()

## parse command line string

Usage = '\nUsage of cleanGbifCoords script.\n\nThis python script parses locality data and returns files with "good" and "bad" locality coordinates.\nIt requires at least four input arguments (in this order):\n- input file name (with path if located in different directory): locality data, tab or comma delimited, \n\tno header, specifying a name, latitidude, longitude, and other stuff if you wish. The latitude\n\tand longitude need to be in decimal degrees and placed in the second and third column in the\n\tinput file, respectively.\n- bad coordinate file name:  bad coordinates (corners of 0.01 degree grid cells), no header, each\n\tcoordinate on a new line, lat and long comma or tab delimited. This script is intended to be\n\tused with the file allHerbaria_ADM1_badCoords which specifies the four corners of the 0.01\n\tdegree gridcells that contain herbaria with > 1,500,000 specimens and the ADM1 level\n\tadministrative divisions (e.g. states / provinces / cantons).\n- output file name for good localities.\n- output file name for bad localities.\n- [optional] setting for method to match localities to "bad" coordinates. Possible values:\n\t- "BadByString" truncates locality data after the second digit\n\t- "BadbyNumber" rounds locality data to two digits\n\t- "BadByBoth" tries matching first by rounding and then tries it by truncating.\n\t- "BadByNone" only excludes records by being imprecise.\n\tDefault behaviour is "badByString" because it is the faster way to exclude "bad" localities.\n\nNB: this script does not (yet) remove duplicate records. They can typically be removed e.g. with\nTextWrangler, Excel, etc. prior to processing.\n\nSuggested citation: Edwards EJ, De Vos JM, Donoghue MJ, in press. Brief Communications Arising: Doubtful\npathways to cold tolerance in plants. Nature.\n'

if len(sys.argv) < 5 or len(sys.argv) > 6 or '-h' in sys.argv:
	print Usage
	sys.exit()
if len(sys.argv) == 6 and sys.argv[5] not in ['BadByString', 'BadByNumber', 'BadByBoth', 'BadByNone']:
	print Usage
	sys.exit()

# apply command line settings
InFileName 			= sys.argv[1]
PolitCoordFileName	= sys.argv[2]
OutGoodFileName 	= sys.argv[3]
OutBadFileName		= sys.argv[4]

# adjust default settings if specified
if len(sys.argv) == 6:
	if sys.argv[5]   == 'BadByNumber':
		ExclusionViaStringMatching	= False
		ExclusionViaRounding		= True
	elif sys.argv[5] == 'BadByString':
		ExclusionViaStringMatching	= True
		ExclusionViaRounding		= False
	elif sys.argv[5] == 'BadByBoth':
		ExclusionViaStringMatching	= True
		ExclusionViaRounding		= True
	elif sys.argv[5] == 'BadByNone':
		ExclusionViaStringMatching	= False
		ExclusionViaRounding		= False
else:
	ExclusionViaStringMatching		= True
	ExclusionViaRounding			= False
TakeAllCorners = True  ## not fully implemented


print '\nCleaning of coordinate data.'
print '\nRunning with these data:'
print '\tInfile localities:       ' + InFileName.split('/')[-1]
print '\tInfile bad coordinates:  ' + PolitCoordFileName.split('/')[-1]
print '\tOutfile good localities: ' + OutGoodFileName.split('/')[-1]
print '\tOutfile bad localities:  ' + OutBadFileName.split('/')[-1]
print '\nInclusion criteria (use -h to see all options):'
print '\t- Adding information beyond the first decimal digit (i.e. more than 6 arcminutes precision)'
if ExclusionViaStringMatching == True:
	print '\t- Not within a 0.01 degree grid cell that also contains a ADM1 political centroid or herbarium\n\t  (based on string matching)'
if ExclusionViaRounding == True:
	print '\t- Not within a 0.01 degree grid cell that also contains a ADM1 political centroid or herbarium\n\t  (based on number rounding)'







############# prepare set of bad coordinates
# Make a list of "bad" coordinates that need to be excluded (herbaria + political areas ADM1 level), depending on whether all corners or just one corner is considered

if ExclusionViaStringMatching == True or ExclusionViaRounding == True:
	print '\nProcessing file with "bad" coordinates...'
	BadCoordinates = []
	PolitCoordFile	= open(PolitCoordFileName, 'rU')
	if TakeAllCorners == False:  # we only take the SW most corner
		LineNumber	= 0
		BadLats		= []
		BadLons		= []
		for Line in PolitCoordFile:
			LineNumber += 1
			Line        = Line.strip('\n')
			LineElements= Line.replace('\t', ',').split(',')
			BadLats.append(str(LineElements[0]))
			BadLons.append(str(LineElements[1]))
			if LineNumber % 4 == 0:
				BadLat = min([float(lat) for lat in BadLats])
				BadLon = min([float(lon) for lon in BadLons])
				BadLat 		= str(BadLat)
				BadLon 		= str(BadLon)
				if ExclusionViaStringMatching == True:
					if '-' not in BadLat:
					# then we don't have a negative and need to fix the digit number
					# the length needs to be three so we add a number of zeros of 3 minus
					# how many digits we already have
						Tmp = BadLat.split('.')[0]
						DigitsMissing = 3 - len(Tmp)
						BadLat = DigitsMissing * '0' + BadLat
					if '-' not in BadLon:
						Tmp = BadLon.split('.')[0]
						DigitsMissing = 3 - len(Tmp)
						BadLon = DigitsMissing * '0' + BadLon
				BadTuple = (str(BadLat), str(BadLon))
				BadCoordinates.append(BadTuple)
				BadLats		= []
				BadLons		= []
	if TakeAllCorners == True:
		for Line in PolitCoordFile:
			Line        = Line.strip('\n')
			LineElements= Line.replace('\t', ',').split(',')
			BadLat 		= str(LineElements[0])
			BadLon 		= str(LineElements[1])
			if ExclusionViaStringMatching == True:  # do we need to fix leading zeros?
				if '-' not in BadLat:
					Tmp = BadLat.split('.')[0]
					DigitsMissing = 3 - len(Tmp)
					BadLat = DigitsMissing * '0' + BadLat
				if '-' not in BadLon:
					Tmp = BadLon.split('.')[0]
					DigitsMissing = 3 - len(Tmp)
					BadLon = DigitsMissing * '0' + BadLon
			BadTuple = (BadLat, BadLon)
			BadCoordinates.append(BadTuple)
	BadCoordinates = set(BadCoordinates) 	# to have the object in useful format
	PolitCoordFile.close()
	print '\tdone.'
else:
	print '\nNo "bad" coordinates specified.'


############# parse the infile
# check whether good/bad coordinate and whether desired precision
InFile 		= open(InFileName, 'rU')
OutGoodFile = open(OutGoodFileName, 'w')
OutBadFile	= open(OutBadFileName, 'w')

# progress counters
Counter							= 0
BigCounter						= 1
BeyondStart						= False
BadRecordsImprecisionCounter	= 0
BadRecordsRoundingCounter		= 0
BadRecordsStringCounter			= 0

print "\nStart processing infile..."
for Line in InFile:
	Counter += 1
	Line = Line.strip('\n').strip('\r')
	LineElements= Line.replace('\t', ',').split(',')
	Lat = LineElements[1]
	Lon = LineElements[2]

	##  decide whether good or bad coordinate... start assuming good
	GoodRecord = True

	#   1a. What precision does it have?
	LatPrecision = 0
	LonPrecision = 0
	MinImprecision = ['166666', '333333', '666666', '833333']
	#   Decimal coordinate starts with:
	#	166666  = 10 min
	#	333333  = 20 min
	#	666666  = 40 min
	#	833333  = 50 min

	# precision for latitude:
	LatLength  = Lat
	LatLength  = LatLength.split('.')
	if (len(LatLength) == 2):
		# then it was splitted at the . and thus it has decimals
		if LatLength[1][0:6] in MinImprecision:
			# then its exactly precise at imprecise minutes
			LatPrecision = int(1)
		else:
			LatPrecision = int(len(LatLength[1]))
	else:
		LatPrecision = int(0)

	# precision for longitude:
	LonLength  = Lon
	LonLength  = LonLength.split('.')
	if (len(LonLength) == 2):
		# then it was splitted at the . and thus it has decimals
		if LonLength[1][0:6] in MinImprecision:
			# then its exactly precise at imprecise minutes
			LonPrecision = int(1)
		else:
			LonPrecision = int(len(LonLength[1]))
	else:
		LonPrecision = int(0)

	#   1b. Is the coordinate precise enough?
	CoordPrecision = max(LatPrecision, LonPrecision)
	if CoordPrecision < 2:
		GoodRecord = False
		BadRecordsImprecisionCounter += 1


	####   2. Does the coordinate fall within the "bad squares"

	## via rounding:
	#      no list comprehension, is really slow.: 12 min for 14000 records

	if ExclusionViaRounding == True:
		IsBad = any( (round(float(Bad[0]), 2) == round(float(Lat), 2) and round(float(Bad[1]), 2) == round(float(Lon), 2) ) for Bad in BadCoordinates)
		if IsBad == True:
			print '  ! Excluded : ' + str(Line)
			GoodRecord == False
			BadRecordsRoundingCounter += 1


	## via string matching:
	#		list comprehension; takes a minute for 14000 records.

	if ExclusionViaStringMatching == True:
		if '-' not in Lat:
		# then we don't have a negative and need to fix the digit number
		# the length needs to be three so we add a number of zeros of 3 minus how many
		# digits we already have
			Tmp = Lat.split('.')[0]
			DigitsMissing = 3 - len(Tmp)
			Lat = DigitsMissing * '0' + Lat
		if '-' not in Lon:
			Tmp = Lon.split('.')[0]
			DigitsMissing = 3 - len(Tmp)
			Lon = DigitsMissing * '0' + Lon
		LatLonTuple = (Lat, Lon)
		x = [LatLonTuple for BadCoord in BadCoordinates if (BadCoord[0] in LatLonTuple[0] and BadCoord[1] in LatLonTuple[1])]
		# x is the LatLonTuple IF IT IS BAD
		if LatLonTuple in x:
			# uncomment this to check each record that is excluded
			# y = [BadCoord for BadCoord in BadCoordinates if (BadCoord[0] in LatLonTuple[0] and BadCoord[1] in LatLonTuple[1]) ]
			# print 'Query : ' + str(Line)
			# print 'match found : ' + str(y)
			# print 'decicion: exclude \n'
			print '  ! Excluded : ' + str(Line)
			GoodRecord == False
			BadRecordsStringCounter += 1


	##  Print line to file with good or with bad coordinates
	if GoodRecord == False:
		OutBadFile.write(Line + '\n')
	if GoodRecord == True:
		OutGoodFile.write(Line + '\n')


	##  Track progress line to file with good or with bad coordinates
	if Counter == 500:
		print '\t' + str(Counter * BigCounter) + ' records parsed...'
		if BeyondStart == False:
			RunTime = time.time()-TimeStart
			print str(round(RunTime)*10) + " seconds projected runtime per thousand records"
			BeyondStart = True
		BigCounter += 1
		Counter = 0

	if Counter == 200 and BeyondStart == False:
		RunTime = time.time()-TimeStart
		print "\t200 records parsed; projected runtime per 10,000 records:  " + str(round(RunTime * 50 / 60, 2)) + " minutes."
		BeyondStart = True


## print output
print '\tdone.'

print '\nOf ' + str(BigCounter*500+Counter) + ' records parsed, ' + str(BadRecordsImprecisionCounter+BadRecordsRoundingCounter+BadRecordsStringCounter) + ' were excluded.'
print str(BadRecordsImprecisionCounter) + ' excluded due to imprecision of the locality'
if ExclusionViaRounding == True or ExclusionViaStringMatching == True:
	print str(BadRecordsRoundingCounter+BadRecordsStringCounter) + ' excluded due to suspicious locality (herbarium / political centroid)'
	if ExclusionViaRounding == True:
		print '\tof the ' + str(BadRecordsRoundingCounter+BadRecordsStringCounter) + ', ' + str(BadRecordsRoundingCounter) + ' were found through rounding'
	if ExclusionViaStringMatching == True:
		print '\tof the ' + str(BadRecordsRoundingCounter+BadRecordsStringCounter) + ', ' + str(BadRecordsStringCounter) + ' were found through truncating'
print '\n\n'












## these are the herbaria localities based on wikipedia
#  40.863611, -73.878333	New York Botanical Garden	7,200,000	NY	USA; The Bronx, New York City, New York	[72]
#  38.6141, -90.2589	Missouri Botanical Garden	6,231,759	MO	USA; St. Louis, Missouri	[73]
#  42.378819, -71.114589	Harvard University Herbaria	5,005,000	A, AMES, ECON, FH, GH, NEBC	USA; Cambridge, Massachusetts	[74]
#  38.8888, -77.026	United States National Herbarium, Smithsonian Institution	4,340,000	US	USA; Washington, D.C.	[75]
#  41.866278, -87.617039	Field Museum	2,650,000	F	USA; Chicago, Illinois	[76]
#  37.871303, -122.262436	University and Jepson Herbaria, University of California, Berkeley	2,200,000	UC/JEPS	USA; Berkeley, California	[77]
#  48.842109, 2.356286	Museum National d'Histoire Naturelle	9,500,000	P, PC	France; Paris	[35]
#  59.970685, 30.321007	Komarov Botanical Institute 7,160,000	LE	Russia; St. Petersburg	[36]
#  51.474667, -0.295467	Royal Botanic Gardens Kew	7,000,000	K	UK; Kew, England	[37]
#  46.227410, 6.146967	Conservatoire et Jardin botaniques de la Ville de Geneve	6,000,000	G	Switzerland; Geneva	[38]
#  51.496414, -0.178118	British Museum of Natural History	5,200,000	BM	UK; London, England	[39]
#  48.205212, 16.359399	Naturhistorisches Museum Wien	5,000,000	W	Austria; Vienna	[40]
#  59.368999, 18.053043	Swedish Museum of Natural History (Naturhistoriska riksmuseet)	4,400,000	S	Sweden; Stockholm	[41]
#  52.165119, 4.475357	National Herbarium of the Netherlands (Nationaal Herbarium Nederland)	4,000,000	L	Netherlands; Leiden	[42]
#  43.631944, 3.863889	Universite Montpellier	4,000,000	MPU	France; Montpellier	[43]
#  45.780837, 4.867900	Universite Claude Bernard	4,000,000	LY	France; Lyon	[44]
#  47.358727, 8.559751	Joint Herbarium of the University of Zurich and the ETH Zurich	3,500,000	Z+ZT	Switzerland, Zurich	[45]
#  50.928664, 4.326260	National Botanic Garden of Belgium	3,500,000	BR	Belgium, Meise	[46]
#  52.456173, 13.306054	Botanischer Garten und Botanisches Museum Berlin-Dahlem, Zentraleinrichtung der Freien Universitaet Berlin	3,000,000	B	Germany, Berlin	[47]
#  60.171282, 24.931378	Finnish Museum of Natural History (University of Helsinki)	3,000,000	H	Finland, Helsinki	[48]
#  48.164844, 11.497351	Botanische Staatssammlung Muenchen	3,000,000	M	Germany, Munich	[49]
#  55.690116, 12.567992	University of Copenhagen	2,510,000	C	Denmark, Copenhagen	[50]
#  55.963086, -3.212224	Royal Botanic Garden, Edinburgh	2,000,000	E	UK; Edinburgh, Scotland	[51]
#  39.992270, 116.214663	Chinese National Herbarium, (Chinese Academy of Sciences)	2,470,000	PE	People's Republic of China; Xiangshan, Beijing	[7]
#  -6.486492, 106.854193	Herbarium Bogoriense	2,000,000	BO	Indonesia; Bogor, West Java
#  35.714897, 139.768633	University of Tokyo	1,700,000	TI	Japan; Tokyo	[8]
#  53.558837, 9.862371	Herbarium Hamburgense	1,800,000	HBG	Germany, Hamburg	[52]
#  37.7701, -122.466407	California Academy of Sciences, Herbarium	1,950,000	CAS/DS	USA; San Francisco, California	[78]
#  42.236256, -83.727517	University of Michigan Herbarium	1,700,000	MICH	USA; Ann Arbor, Michigan	[79]







