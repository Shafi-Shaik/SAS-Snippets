
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