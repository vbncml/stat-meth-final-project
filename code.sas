* Connect the local folder to sas working directory;
libname gnb "Z:\Downloads\math6364\final";

* Import the dataset from the local folder into sas working directory;
PROC IMPORT OUT= GNB.final 
            DATAFILE= "Z:\Downloads\math6364\final\new_dataset_1.csv" 
            DBMS=csv REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


* explore data;

proc sgplot data = gnb.final noautolegend ;
	pbspline x = year y = num_deaths_AP 
	/ group = country nomarkers LINEATTRS = (COLOR= gray PATTERN = 1 THICKNESS =1);
	pbspline x = year y = num_deaths_AP
	/ nomarkers LINEATTRS = (COLOR= red PATTERN = 1 THICKNESS = 3);
run;
quit;

proc sgplot data = gnb.final(where=(num_deaths_ap<1000000)) noautolegend ;
	pbspline x = year y = num_deaths_AP 
	/ group = country nomarkers LINEATTRS = (COLOR= gray PATTERN = 1 THICKNESS =1);
	pbspline x = year y = num_deaths_AP
	/ nomarkers LINEATTRS = (COLOR= red PATTERN = 1 THICKNESS = 3);
run;
quit;

proc means data = gnb.final(where=(num_deaths_ap<1000000)) n mean var min max; 
  var num_deaths_AP CFT ELC GDP;
  class country;
run;

proc freq data=gnb.final(where=(num_deaths_ap<1000000));
tables num_deaths_AP / plots=freqplot;
run;

* add new column time to store year-2011;
PROC SQL;
ALTER TABLE GNB.final  ADD time NUM (8);
QUIT;

* insert values into column time;
PROC SQL;
UPDATE GNB.final SET time=year-2011;
QUIT;


* choosing correlation structure and distribution ; 
* convergenes is questionable;
proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT time/dist=pois link=log;
REPEATED SUBJECT=country / TYPE=EXCH CORRW; 
run; quit;
* QIC -4390.7326;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT time/dist=pois link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;
* -4416.0608;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT time/dist=pois link=log;
REPEATED SUBJECT=country / TYPE=un CORRW; 
run; quit;
* QIC -4281.4337;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT time/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;
* QIC -139757706.2 best option;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT time/dist=geometric link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;
* QIC -63027593.50;


* bivariate analysis;
proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;*p-value 0.2759 SE 0.0014;
proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = ELC/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;*p-value 0.5160 SE 0.0003;
  
proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = GDP/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;*p-value <0.0001 SE =0.0000;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = time/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;*p-value 0.5268 SE=0.0021;

* fitting model data;
proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT ELC time/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW; 
run; quit;*QIC -138321655.2;


* Test for interaction effect;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT ELC time CFT*ELC/dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW;
run; quit;*p -0.00000;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000));
class country;
model Num_deaths_AP = CFT ELC time CFT*time/dist=nb link=log;;
REPEATED SUBJECT=country / TYPE=ar CORRW;
run; quit;*p -0.00000;

proc genmod data = gnb.final;
class country;
model Num_deaths_AP = CFT ELC time ELC*time/dist=nb link=log;;
REPEATED SUBJECT=country / TYPE=ar CORRW;
run; quit;*p -0.00000;


*Fitting final model;

proc genmod data = gnb.final(where=(num_deaths_ap<1000000)) plots=all descending;
class country;
model Num_deaths_AP = CFT ELC time /dist=nb link=log;
REPEATED SUBJECT=country / TYPE=ar CORRW;
run; quit;






