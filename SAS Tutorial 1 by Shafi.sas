
/* Data Prepare on the fly using CARDS within DATA step */

data work.example1;
input name $  ID  date :ddmmyy10.;
format date worddate18.;
format ID comma12.;
cards;
Sam    120001 01-03-2023
Reno   113564391 21-11-2023
Farhan 121  01082023
Sandy  131123  01/03/2023
;


/* ******************************* To Display the data on screen  **************************** */
proc print data = work.example1;
run;

/* **************** To Display the dataset info datatype, #observation, #varibles **************** */
proc contents data = datalib.example1;
run;

/* **************************** PROC SUMMARY **************************** */
data your_dataset;
    input order_date : mmddyy10. country $ order_id amount;
    format order_date mmddyy10.;
    cards;
    11/01/2023 USA 1001 100.00
    11/01/2023 USA 1002 50.00
    11/02/2023 USA 1003 75.00
    11/02/2023 Canada 1004 200.00
    11/03/2023 Canada 1005 150.00
    11/03/2023 Canada 1006 125.00
    ;
run;

PROC SUMMARY DATA=your_dataset print n mean stddev median nway missing;
    CLASS country;
    VAR order_id amount;
    OUTPUT OUT=summary_dataset(drop=_type_ _freq_)
        N(order_id)=count_of_order_ids
        SUM(amount)=sum_of_revenue
        mean(amount) = revenue_mean
        median(amount) = revenue_median
        p25(amount) = percentile25
        p50(amount) = percentile50
        p75(amount) = percentile75
        max(amount) = maxofamount;
RUN;

/* *********************************** PROC MEANS *************************** */
 proc means data = sashelp.shoes print;
 class product;
 var Returns;
 run;


/************************** Macro Variables ****************************/
%let var1 = 23;
%let var2 = 24;
%put %eval(&var2. * 19* &var1.);

/*************************** Macro Function *********************************/



%macro m1(tbl,var1);
proc summary data=sashelp.&tbl. print;
var &var1.;
run;
%mend m1;

%m1(cars,weight);
%m1(cars,length);
%m1(cars,msrp);



/* ******************** DATA INFILE ******************************** */

data work.people3;
%let _EFIERR_ = 0; /* set the ERROR detection macro variable */
infile '/home/u63490872/people.csv' delimiter=',' truncover dsd firstobs=2;

	informat Name $10.;
	informat Ageinyear best32.;
	informat dateofBirth ddmmyy10.;
	format Name $10.;
	format Ageinyear best32.;
	format dateofBirth mmddyy10.; 
	input 
		Name $
		Ageinyear
		dateofBirth;
if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
run;

proc print data=people3;run;

/* ******************** PROC IMPORT ******************************** */

PROC IMPORT
DATAFILE= '/HOME/U63490872/PEOPLE.CSV'
OUT= PEOPLE
DBMS=CSV
REPLACE;
GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE="<Your XLSX File>"
		    OUT=WORK.MYEXCEL
		    DBMS=XLSX
		    REPLACE;
RUN;
/* ******************** PROC EXPORT ******************************** */

proc export 
data=my_data 
outfile="/home/u13181/my_data.csv" 
dbms=csv 
replace;
putnames = yes;
run;


/* Remove duplicates */
data readin;
input ID Name $ Score;
cards;
1     David   45
1     David   74
2     Sam     45
2     Ram     54
3     Bane    87
3     Mary    92
3     Bane    87
4     Dane    23
5     Jenny   87
5     Ken     87
6     Simran  63
8     Priya   72
;
run;

/*
PROC SORT DATA = readin NODUPKEY DUPOUT= dup out=readin2;;
BY ID;
RUN;
*/
PROC SORT DATA = readin NODUP DUPOUT= dup out=readin2;
BY ID;
RUN;


/******************** PROC TRANSPOSE **************/

proc summary data=sashelp.cars nway missing;
class origin Drivetrain;
var weight;
output out = summ1 (drop = _TYPE_ _FREQ_)
sum(weight) = total_weight
;
run;

/*** 
Origin will be first column, 
Drivetrain values will be converted to individual Column 
_name_ column renamed to measure and contains "total_weight" 

***/

proc transpose data = summ1 out=final(rename=(_name_ = measure) drop =_label_);
id Drivetrain; /* convert each value of Drivetrain to Column  */
by origin; /* stay as it is (single column) */
run;

/*** this is same summ1 **/
proc transpose data=final
   out=summ2 (rename=(col1=newValue _name_=newName));
   var All Front Rear;
   by Origin;
run;

/************************/










/* Do Loop */
data readin;
do i=1 to 100;
     int=3;
     multiplier=i;
     result=0 + 3* i;
     output;
end;
drop i;
run;


%let last=%eval (4.5+3.2); # cannot do arithmetic operations on float
%let last2=%sysevalf(4.5+3.2); # can works
%put &last2;






############################ STRING FUNCTIONs  ###################
data new;

a = 'This is Shafi';
lower = lowcase(a);
upper = upcase(a);
proper = propcase(a);
sc = scan(a,3);
substr1 = substr(a,2,5);
substr2 = substr(a,2);
indx = index(a,'is');
indxw = indexw(a,'is');
cmprsS = compress(a,'s');
cmprsIS = compress(a,'is');
cmpbl  = compbl(a);
left3 = left(a);
right3 = right(a);

cat1 = cat(a,'  new text');
cat1s = cats(a,'  new text');
cat1t = catt(a,'  new text');
cat1x = catx('-',a,'new','added',' text');
concat = a || 'new text' || a;
rplc = tranwrd(a,'This','There');
lngth1 = length(a);

run;

proc print data = new ;run;

############# String based scenario ###################
data new ;
input name:&$25.  class$2. ;
cards;
shaik shafi mohiddin  6th
khaja mohiddin shaik  7th
reddy ravi teja  8th
run;

data want;
set new;
final = upcase(substr(name,1,1)) ||'.' || propcase(scan(name,2)) ||' ' || propcase(scan(name,3));
run;

proc print data =want ;run;


################################################# THE START ##############################

%let UName = 'username';
%let UPass = 'password';
%let DBData = 'db';

libname Arw2020 "/data1/folder/sub/2020";

options obs = max nocenter ls = max ps = max mergenoby=error;
options compress = yes mprint mlogic source source2 mstored sasmstore=clog error=1;*symbolgen;

%let out_loc = /data1/folder/sub/2020;


data janArw23 (keep= col1 col2 col3 rename = (col1 = cola col2 = colb)) ;
set Arw2023.frf_arw_jan_2023 (WHERE = (col1>0 AND col2 ="mid"));
Format Company $10.;
if colx = 92001 then Company = "value1"; else Company = "value12";
run;

** oracle live query **;
proc sql;
connect to oracle (user=&UName. password=&UPass. path=&DBData. );
create table live_arw as select * from connection to oracle
(
select * from table
);
quit;



Data Event_data;
Set Event_query;
If mpr_mnth = . then mpr_mnth =99;
If mpr_yr = . then mpr_yr =9999;
mpr_mnth = input (mpr_mnth, best32.);
mpr_yr = input (mpr_yr, best32.);
format MPR_MONTH best32.;
format MPR_YEAR best32.;
MPR_MONTH=mpr_mnth;
MPR_YEAR=mpr_yr;
run;

proc print data=df1 (obs=6);run;

proc contents data=df1 order=varnum;run;


** Affiliation - Primary CST Dec 2022 ;
proc summary data = decArw22 nway missing;
class affl cust_id ;
output out = affl_cst (drop = _type_ rename = (_freq_ = vol));
run;

proc sort data = affl_cst ; by affl descending vol ;run;
proc sort data = affl_cst out=affl_cst_final nodupkey; by affl ; run;


proc freq data=Arw22;
tables seg*company*rep_group /list missing;run;


proc summary data = janArw23 nway missing;
class affl cust_id Company arw_seg;
output out = affl_seg (drop = _type_ rename = (_freq_ = vol));
run;

proc sort data = df1 out=df2 nodupkey;
by affl cust_id;
run;


data df1;
merge df2 (in=a)
df3 (in=b);
by txn_id;
if a;

mi_merge = compress(a||b);
format rep_flag $32.;
if mi_merge = "10" then rep_flag = "New";
else if mi_merge = "11" then rep_flag = "Retained";
else rep_flag = "NA";
run;


*** FRFE1- for pulling Cust_seg for New reps;

proc sql;
connect to oracle (user=&UName. password=&UPass. path=&DBData. ) ;
create table FRF_Data as select * from connection to oracle
(
select ent_id, Jurisdiction_Name as Juris_name, POP_Customer_seg as seg
from fr.frf_e1@fr_rs

where extract(year from GL_Date) in (2021,2022)
and GL_Account in (400217, 400219, 400210, 270505, 420080)
)
;
quit;

proc sort data=FRF_Data nodupkey;
by ent_id Juris_name;
run;

proc sql ;
create table arw22lost as
(
select a.txn_id
from Arwdec21 a
left join Arwdec22 b
ON a.txn_id = b.txn_id
WHERE b.txn_id IS NULL
);
quit;



proc import datafile='/data1/folder1/bundle/mar22/bundle_20.csv' out=bndl_mar_21
dbms=csv replace;
run;

proc export data = final
outfile = "/data1/folder1/Adhocs/21032023_Discount_dropoff_Affl/cst_level_jan23_Dec_Nov_oct22_cmpny_v2.csv"
dbms = csv replace ;
PUTNAMES=YES;
run;



proc sql;
connect to oracle (user=&UName. password=&UPass. path=&DBData. ) ;
create table seg_details as select * from connection to oracle
(
SELECT DISTINCT (a.aban8) AS cust_id,
decode(TRIM(a.abac06),
'200', 'Corporation', '100', 'Small Business', '300', 'Law Firm', '', 'Small Business') AS seg, a.abac16 AS Cust_Type,
c.ccy55ac46 AS Sub_Seg_Code,

FROM table
);
quit;

proc sort data = seg_details out= seg (Keep = cust_id CST_NAME seg);
by cust_id;
run;



/* FRF */
libname FRFE1 "/data1/folder1/FRF_E1/Dataset/";

Data FRF_E1 (keep = GL_Account ent_id Jurisdiction_Name GL_Date POP_Customer_seg POP_CST);
set
FRFE1.frf_e1_2023_11_nov
FRFE1.frf_e1_2023_12_dec
FRFE1.frf_e1_2024_01_jan
FRFE1.frf_e1_2024_02_feb
;
if (GL_Account in (400217, 400219, 400210, 270505, 420080));
run ;

Data FRF_Data (keep=ent_id Juris_name Inv_Month Inv_Year POP_Customer_seg GL_Account POP_CST);
Set FRF_E1;

Format Inv_Date mmddyy10.;
Inv_Date = datepart(GL_Date);

Format Inv_Month Best2.;
Format Inv_Year Best4.;
Inv_Month = month(Inv_Date);
Inv_Year = year(Inv_Date);

Format Juris_Name $200.;
Juris_name = strip(trim(compress(Upcase(Jurisdiction_Name),"","ka")));
run;

proc sort data=FRF_data;
by ent_id Juris_Name descending Inv_year descending Inv_month;
run;

proc sort data=FRF_data nodupkey;
by ent_id Juris_Name ;
run;


libname out "/data1/folder1/Adhocs/11_New_reps_lost_within_12months";
data out.rawdata;
set final;
run;

WbExport -file="D:UsersDownloadsexporttest_exportv1.csv" -type=text -delimiter=',';
select *
from table
where col in ()
group by
;

drop table affl_list;
create global temporary table affl_list(
affl_id int) on COMMIT PRESERVE ROWS;;

WbImport -file='D:UsersDownloadsexportinputctac_affl_list.csv'
-table=affl_list
-batchSize=1000
-filecolumns=affl_id
-mode=insert
-header=true
;
################################################# THE END ##############################