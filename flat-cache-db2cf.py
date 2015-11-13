import pgdb, sys, datetime, time, os, cmop
from pupynere import NetCDFFile

dbObj =  pgdb.connect(user='reader', dsn='cdb02.stccmop.org:cmop')
db = dbObj.cursor()


#
def extractStationData(stationName, currentOrAll='',level=0, rootdir = 'archive', variable = 'all'):
  if rootdir == 'archive':
     home = "/home/workspace/ccalmr/data/nc/PD%s/stations/" %  level
  else: home = rootdir

  #Get a list of offerings for given station
  offerings = station.listDeployments(db, stationName, currentOrAll, level,variable)
  print offerings
  #Process offerings individualy 
  for offering in offerings:
    starttime = datetime.datetime.strptime(offering['deployedon'], '%Y-%m-%d %H:%M:%S')
    starttime = datetime.datetime(starttime.year,starttime.month, 1, 0, 0, 0) # prevents cutoff of data from previous deployment in same month in archive mode
    if type(offering['retrievedon'])!=type(None):
      endtime = datetime.datetime.strptime(offering['retrievedon'], '%Y-%m-%d %H:%M:%S')
    else: 
      endtime = datetime.datetime.now() 

    if currentOrAll=='current':
      starttime = datetime.datetime.now()
      starttime = datetime.datetime(starttime.year, starttime.month, 1, 0, 0, 0)
      endtime = datetime.datetime.now() + datetime.timedelta(hours=25)
      #starttime = datetime.datetime(starttime.year, 5, 1, 0, 0, 0)
      #endtime = datetime.datetime(starttime.year, 6, 1, 0, 0, 0) + datetime.timedelta(hours=25)

    while (endtime - starttime).days > 0:
      print starttime
      print endtime

      #Next starttime calculations
      nextMonth = starttime.month + 1
      nextYear = starttime.year
      if nextMonth==13: 
        nextMonth = 1 
        nextYear = starttime.year + 1 
      print "offering %s, level = %s" % (offering,level)
      #List 
      station.exportCDF(db, stationName, offering, starttime, datetime.datetime(nextYear, nextMonth, 1, 0, 0, 0), home, level = level)
      starttime = datetime.datetime(nextYear, nextMonth, 1, 0, 0, 0)

#
def isRunning(current,rootdir,sta,level):

  import glob
  if rootdir != 'archive':
     rootdir = 'test'
  testname = "/tmp/flat-cache-db2cdf-level%s-%s-%s-%s" % (level,current,sta,rootdir)
  pids = glob.glob("%s.*" % testname)
  instanceCount = 0

  for pid in pids:
    pid = pid.split(".")[1]

    # is running
    if os.path.exists("/proc/%s" % (pid)):
      instanceCount = instanceCount + 1
    # not running
    else:
      cmop.info("instance [%s] is death" % (pid))
      os.remove("%s.%s" % (testname,pid))

  if instanceCount==0:
    pidfile = open("%s.%d" % (testname,os.getpid()), "w")
    pidfile.close()

  return (instanceCount,testname)

#
if __name__=='__main__':
  if len(sys.argv) > 1:
    if sys.argv[1] == '--help' or sys.argv[1] == '-h':
      print '''usage: %s current/archive test level1/level0 [list of station names]
    argument of 'current' processes only the current month.
    argument of 'archive' processes all data.
    argument of test uses './test/' as the target directory.
    argument of level0 extracts raw data.
    argument of level1 extracts processed data.
    argument of station names restricts the processing to those stations.''' % sys.argv[0]
      exit(0)
 
  variable = 'all'
  #variable = 'temp'
  current = 'current'
  rootdir = 'archive'
  sta = 'all'
  stationsList = []
  level = 0
  for arg in sys.argv[1:]:
     if arg == 'current':
        current = arg
     elif arg == 'archive':
        current = 'all'
     elif arg == 'test':
        rootdir = './test/'
     elif arg == 'level0':
        level = 0
     elif arg == 'level1':
        level = 1
     else:
        sta = ''
        stationsList.append([arg])
  print '%s %s %s %s' % (current,rootdir,level,sta)
  print stationsList
  test = isRunning(current,rootdir,sta,level)
  if test[0]!=0:
    cmop.info("%s is already running" % test[1])
    exit(0)
#  extractGliderData()
#  extractAUVData()
  currentPath = os.getcwd()
  sys.path[1:1] = [currentPath] 
  import stations as station 
  if sta == 'all':
     if current == 'current':
        cur = " where currentornull='current'"
     else: cur = ''
     sql = "select distinct on (station) station from instrument.offeringdetails %s" % cur
     db.execute(sql)
     stationsList = db.fetchall()  
  
  now = datetime.datetime.now()

  for stationName in stationsList:
    print stationName
    extractStationData(stationName[0], current, level =level, rootdir = rootdir, variable = variable)
#    extractStationData(stationName[0])
  timeLapse = datetime.datetime.now() - now
  cmop.info("Cache refreshing took: %s" % (timeLapse))
  os.remove("%s.%d" % (test[1],os.getpid()))


