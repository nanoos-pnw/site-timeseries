from Scientific.IO.NetCDF import NetCDFFile
from shutil import move
import os, cmop, datetime
import numpy
import time, re

fillvalue = 2.0 ** 40

cfname = {"salt": "water_salinity",
          "temp": "water_temperature",
          "cond": "water_electrical_conductivity",
          "elev": "elevation",
          "pres": "water_pressure",
          "fluores": "fluorescence",
          "turbidity": "turbidity"}

#syslog.openlog("DB2CDF [%s]" % os.getpid(), 0, syslog.LOG_DAEMON )

#


reviewdate = re.compile('Last revision                    : (%d+/%d+/%d+)')
reviewer = re.compile('Data reviewed by                 : (\w+)')


def readPD2ASCII(file):
  f = open(file ,'r')
  flag = 'false'
  fields = ( 'time','salt','temp','pres')
  data = dict(zip(fields,([],[],[],[])))
  metadata = dict()
  for line in f.readlines():
   if flag=='false':
    r = reviewer.match(line)
    if r is not None:
       data['reviewer'] = r.group(1)
    r = reviewdate.match(line)
    if r is not None:
       metadata['reviewdate'] = r.group(1)
    if r is not None:
       metadata['reviewdate'] = r.group(1)
    if line.find('#############')!=-1:
      flag='true'
   else:
     tokens = line.strip().split()
     data['time'].append(time.mktime(time.strptime(tokens[0] + ' ' + tokens[1] + ' PST','%Y/%m/%d %H:%M:%S %Z')))
     data['salt'].append(float(tokens[2]))
     data['temp'].append(float(tokens[3]))
     data['pres'].append(float(tokens[4]))
  data['salt'] = numpy.array(data['salt'])
  data['pres'] = numpy.array(data['pres'])
  data['temp'] = numpy.array(data['temp'])
  return (metadata,data)

def convertPD2ASCII(station):
  basedir = '/home/workspace/ccalmr2/amb24/publicarch/%s/data/' % station
  files = os.listdir(basedir)
  pd2 = re.compile('CR%sPD2CTD(\d{5})(\a)-(\d{4})-(\d{2}).txt' % station) 
  db = cmop.db.DB()
  for f in files:
    p = pd2.match(f)
    if p is not None:
       # get offering name and variables for station, depth, bracket, where instrument type is CT, CTD, Tide Gauge or ADP
       
       offering = []
       # get data from ASCII file
       sql = '''select offering,station,extract('epoch' from deployedon),extract('epoch' from retrievedon) from instrument.offeringdetails where variable = 'salinity' and station = '%s' and msldepth = %s and bracket = '%s' and (retrievedon > '%s/%s/01' or retrievedon is null) and deployedon < '%s/%s/01' ''' % (p.group(1),p.group(3),p.group(2)) 
       # construct netcdf file with appropriate file name and variables 
       outfile = os.path.join(nchome,)
   
       # write data from ascii to netcdf file

def openFile(filename, size, variables, units):
   file = NetCDFFile(filename, 'w')
   file.createDimension('time', size) 
   dimensions = ('time',)   

   timeVar = file.createVariable('time', 'd', dimensions)
   setattr(timeVar, 'units', 'seconds since 1970-01-01 00:00:00-00')

   for variable in variables:
     unit = units[variable]
     if unit is None: unit = ''
     variable = variable.strip().replace(' ', '_').lower()
     var = file.createVariable(variable, 'd', dimensions)
     setattr(var, 'units', unit)

   return file

#
def getColumn(matrix, column):
  from operator import itemgetter
  f = itemgetter(column)
  return map(f, matrix)


def pushData(file, data, variables,st,en):
   (file.variables['time'])[st:en] = data['time']
   for var in variables:
     cmop.info(data[var])
     variable = var.strip().replace(' ', '_').lower() 
     (file.variables[variable])[st:en] = data[var]
     setattr(file.variables[variable], '_FillValue',fillvalue)

# 
def listDeployments(db, stationName, deploymentFlag='', level = 0,variable='all'):
  sql = """select distinct on (deployedon, retrievedon, offering) date_trunc('second', deployedon) as deployedon,  
           date_trunc('second', retrievedon) as retrievedon, offering, instrumenttype, msldepth, bracket
           from instrument.offeringdetails where station='%s' and instrumenttype notnull 
            and not msldepth=99999
""" % (stationName)

  #list only current deployments
  if deploymentFlag=='current':
    sql = "%s and retrievedon isnull" % sql
  if level == 1:
    sql = '''%s and 
         (offering in (select offering from integrated.offering_metadata 
              where key = 'PD1_table') 
                   OR (offering,variable) in (select offering,variable from instrument.offeringdetails_annotation)
          OR variable_validvaluemin is not NULL OR
          variable_validvaluemax is not NULL)''' % sql     
  if variable != 'all':
    sql = '''%s and variable = '%s' ''' % (sql,variable)
  print sql
  db.execute(sql)
  rows = db.fetchall()
  retArray = []
  ncfile = ""

  for row in rows:
    tmpVar = {}
    tmpVar['instrumenttype'] = row[3]
    tmpVar['deployedon'] = row[0]
    tmpVar['retrievedon'] = row[1]
    tmpVar['msldepth'] = row[4]
    tmpVar['bracket'] = row[5]
    tmpVar['offering'] = row[2] 
    retArray.append(tmpVar)

  return retArray

#
def exportCDF(db, stationName, deployment, starttime, endtime, home, level = 0):
  sql = "select variable,alias from integrated.variablealias where agency = 'CF'"
  db.execute(sql)
  rows = db.fetchall()
  cfname = dict(rows)
  print deployment,stationName, starttime,endtime,home,level
  cmop.info('starting exportCDF')
  sql = """select schemaname, tablename, columnname, units, variable, offering, NULL, NULL from instrument.offeringdetails where station='%s' and 
           instrumenttype='%s' and date_trunc('second', deployedon)='%s' and offering='%s' and columnname is not null group by schemaname, tablename, columnname, units, variable, offering
           """ % (stationName, deployment['instrumenttype'], deployment['deployedon'], deployment['offering'])
  
  if stationName=='saturn01':
     sql = """select schemaname, tablename, columnname, units, variable, offering, NULL, NULL from instrument.offeringdetails where station='%s' and 
              instrumenttype='%s' and date_trunc('second', deployedon)='%s' and msldepth=%s and bracket='%s' 
              and offering = '%s'  and columnname is not null
 group by schemaname, tablename, columnname, units, variable, offering
           """ % (stationName, deployment['instrumenttype'], deployment['deployedon'], deployment['msldepth'], deployment['bracket'],deployment['offering'])
  if level == 1:
     sql = """select schemaname,coalesce(integrated.getoffering_metadata(offering,'PD1_table'),tablename), columnname, units, variable, offering, coalesce(integrated.getofferingvariable_metadata(offering,variable,entity,'PD1_validvaluemin'), variable_validvaluemin), coalesce(integrated.getofferingvariable_metadata(offering,variable,entity,'PD1_validvaluemax'), variable_validvaluemax) from instrument.offeringdetails where station='%s' and 
           instrumenttype='%s' and date_trunc('second', deployedon)='%s' and offering='%s'  and columnname is not null
 group by schemaname, tablename, columnname, units, variable, offering, entity, variable_validvaluemin, variable_validvaluemax
           
           """ % ( stationName, deployment['instrumenttype'], deployment['deployedon'], deployment['offering'])
     if stationName=='saturn01':
        sql = """select schemaname,coalesce(integrated.getoffering_metadata(offering,'PD1_table'),tablename), columnname, units, variable, offering, coalesce(integrated.getofferingvariable_metadata(offering,variable,entity,'PD1_validvaluemin'), variable_validvaluemin), coalesce(integrated.getofferingvariable_metadata(offering,variable,entity,'PD1_validvaluemax'), variable_validvaluemax) from instrument.offeringdetails where station='%s' and 
              instrumenttype='%s' and date_trunc('second', deployedon)='%s' and msldepth=%s and bracket='%s' 
              and offering = '%s' and columnname is not null
 group by schemaname, tablename, columnname, units, variable, offering, entity, variable_validvaluemin, variable_validvaluemax
           """ % (stationName, deployment['instrumenttype'], deployment['deployedon'], deployment['msldepth'], deployment['bracket'],deployment['offering'])
  db.execute(sql)
  cmop.info('finished query %s' % sql)
  #cmop.info(sql)
  rows = db.fetchall()
  cmop.info('finished getting offerings')
  if len(rows)==0:
     cmop.info("no public variables for %s %s %s %s" % (stationName, deployment['msldepth'], deployment['bracket'],deployment['instrumenttype']))
     return
  units = {}
  variables = []
  valuemin = {}
  valuemax = {}
  columns = ["extract(epoch from time) as time"]
  tablename = ''
  #if stationName=='saturn01':
  #  columns = ["extract(epoch from date_trunc('second', time)) as time"]

  altStationName = ''
  if level ==1:
    columnnames = ['deploymentid','time']
  else:
    columnnames = ['time']

  for row in rows:
    r = re.match('station(\w+)',row[1])
    if r is not None:
       if r.group(1) == 'flntu':
          row[0] = 'staging'
       table = r.group(1)
    else:
       table = row[1]
    if table == 'gps':
       table='stationgps'
    tablename = "%s.%s" % (row[0], table)
    columns.append("%s as %s" % (row[2], row[4]))
    variable = row[4]
    altStationName = row[5]

    #use cf names
    if cfname.has_key(variable):
      variable = cfname[variable]

    units[variable] = row[3]
    print 'units:',variable,row[3]
    if row[6] is not None:
       valuemin[variable] = float(row[6])
    if row[7] is not None:
       valuemax[variable] = float(row[7])
    variables.append(variable)
    columnnames.append(variable)
  cmop.info('finished parsing offerings')
  offeringNameParts = altStationName.split('.')
  altStationName = offeringNameParts[0]

  #build path and file name
  path = "%s/%s/%s/" % (home, altStationName, deployment['offering'])
  fileName = "%s%s.nc" % (starttime.strftime("%Y"), starttime.strftime("%m"))

  #Check if dataset column exists
  (nspname, relname) = tablename.split(".")
  datasetFlag = "" 
  sql = """select exists(select attname from pg_attribute a, pg_class c, pg_namespace s
           where a.attrelid = c.oid and c.relnamespace = s.oid and s.nspname = '%s'
           and c.relname = '%s' and a.attnum > 0 and a.atttypid != 0 and attname = 'dataset') """ % (nspname, relname)

  db.execute(sql)
  rows = db.fetchall()

  if rows[0][0]:
    datasetFlag = " and dataset=0 " 

  cmop.info('finished dataset column query %s' % sql)

  if level == 1:
     #sql = '''select extract('epoch' from starttime) as starttime, extract('epoch' from endtime) as endtime,variable,deploymentid from instrument.offeringdetails_annotation where offering = '%s' and authority = 'PD1' and status = 'bad' and (endtime >= '%s' and starttime <= '%s') order by deploymentid,starttime,variable ''' % (deployment['offering'],
        sql = '''select extract('epoch' from starttime) as starttime, extract('epoch' from coalesce(endtime,now())) as endtime,varmin,varmax,variable,deploymentid from instrument.offeringdetails_annotation where offering = '%s' and authority = 'PD1' and status = 'bad' and ((endtime >= '%s' or endtime is null) and starttime <= '%s') order by deploymentid,starttime,variable ''' % (deployment['offering'],
           starttime.strftime("%Y-%m-%d %H:%M"), endtime.strftime("%Y-%m-%d %H:%M"))
        db.execute(sql)
        cmop.info(sql)
        PD1rows = db.fetchall()
  now = datetime.datetime.now()
  #build data query
  if level == 1:
     sql = """select deploymentid,%s from %s where deploymentid in (select deploymentid from instrument.deployment where station='%s' and msldepth=%s and bracket='%s' and instrumenttype='%s' and (deployedon<='%s PST' and (retrievedon >='%s PST' or retrievedon is null ) ) ) and (time>='%s PST' and time<'%s PST') %s
           order by time""" % (", ".join(columns), tablename, stationName, deployment['msldepth'], deployment['bracket'], deployment['instrumenttype'], 
           endtime.strftime("%Y-%m-%d %H:%M"), starttime.strftime("%Y-%m-%d %H:%M"),
           starttime.strftime("%Y-%m-%d %H:%M"), endtime.strftime("%Y-%m-%d %H:%M"), datasetFlag)
  else:
     sql = """select %s from %s where deploymentid in (select deploymentid from instrument.deployment where station='%s' and msldepth=%s and bracket='%s' and instrumenttype='%s' and (deployedon<='%s PST' and (retrievedon >='%s PST' or retrievedon is null ) ) ) and (time>='%s PST' and time<'%s PST') %s
           order by time""" % (", ".join(columns), tablename, stationName, deployment['msldepth'], deployment['bracket'], deployment['instrumenttype'], 
           endtime.strftime("%Y-%m-%d %H:%M"), starttime.strftime("%Y-%m-%d %H:%M"),
           starttime.strftime("%Y-%m-%d %H:%M"), endtime.strftime("%Y-%m-%d %H:%M"), datasetFlag)

  if deployment['instrumenttype']=='ADP':
    sql = "%s, bin" % sql

  cmop.info('starting query %s' % sql)
  db.execute(sql)
  cmop.info('finished query' )
  size = db.rowcount
  fetched = 0
  if not os.path.exists(path):
     cmop.info('create path %s' % path)
     os.makedirs(path)
  if size==0:
     cmop.info("Skip %s %s %s, not enough data" % (altStationName, deployment['instrumenttype'], starttime.strftime("%Y/%m")))
     return
  ncfile = openFile("%s/.%s" % (path, fileName), size, variables, units)
  cmop.info('opened file %s/.%s' % (path, fileName))
  while fetched < size:
     rows = db.fetchmany(100000)
     startind = fetched
     fetched = fetched + 100000
     if fetched > size: fetched = size
     endind = fetched
     cmop.info('finished getting %d rows of %d'  % (fetched,size))
     data = dict(zip(columnnames,numpy.array(zip(*rows),dtype='double')))
     #return to main thread if data is not available
     # replace None values with fill values
     for c in columnnames:
       data[c][numpy.nonzero(numpy.equal(data[c],None) | numpy.isnan(data[c]))[0]] = fillvalue
     cmop.info('replaced Nones')
     #   data[c] = numpy.array(data[c],dtype='float32')
     #raise
     # end test
     # remove flagged bad data if level is 1
     # remove data flagged bad at PD1 level
     if  level == 1:
        for (st,en,mn,mx,var,depid) in PD1rows:
           if cfname.has_key(var):
              var = cfname[var]
           if mn and mx:
               matches = numpy.nonzero((data['time'] >= float(st)-1) & (data['time'] <= float(en)+1) & (data['deploymentid'] == depid) & (data[var] >= mn) & (data[var] <= mx))
           elif mn:
               matches = numpy.nonzero((data['time'] >= float(st)-1) & (data['time'] <= float(en)+1) & (data['deploymentid'] == depid) & (data[var] >= mn) )
           elif mx:
               matches = numpy.nonzero((data['time'] >= float(st)-1) & (data['time'] <= float(en)+1) & (data['deploymentid'] == depid) & (data[var] <= mx))
           else:
               matches = numpy.nonzero((data['time'] >= float(st)-1) & (data['time'] <= float(en)+1) & (data['deploymentid'] == depid))
           data[var][matches[0]] = fillvalue
           if len(matches[0]) < 20: cmop.info('removed %s' % ','.join(['%s' % d for d in data['time'][matches[0]]]))
       # remove values outside valid range
        for var in variables:   
         if cfname.has_key(var):
            var = cfname[var]
         if data.has_key(var):
            cmop.debug('cleaning %s' % var)
            if valuemax.has_key(var) and valuemin.has_key(var):
               data[var][numpy.nonzero((data[var] < valuemin[var]) | (data[var] > valuemax[var]))[0]]= fillvalue
            elif valuemax.has_key(var):
               data[var][numpy.nonzero(data[var] > valuemax[var])[0]]= fillvalue
            elif valuemin.has_key(var):
               data[var][numpy.nonzero(data[var] > valuemin[var])[0]]= fillvalue
        cmop.info('Finished cleaning data')
     for var in data.keys(): cmop.info('%s: min %s max %s' % (var, numpy.min(data[var]), numpy.max(data[var])))
     #create folder if not esistent
     pushData(ncfile, data, variables,startind,endind)
  cmop.info('Finished pushing data')
  ncfile.flush()
  ncfile.close()
  elapsedTime = datetime.datetime.now() - now

  #file generated
  if os.path.exists("%s/.%s" % (path, fileName)):
    move("%s/.%s" % (path, fileName), "%s/%s" % (path, fileName))
  else:
    cmop.info("%s %s file generation failed" % (altStationName, fileName))

  cmop.info("%s %s %s %s with %s rows generated on %s hours:mins:secs" % (altStationName, deployment['offering'], starttime.strftime("%Y"), fileName, size, elapsedTime) )









    






