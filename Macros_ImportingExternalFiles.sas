************************************************
* Importing External Files Macros              *
************************************************;


/*Converting CSV filenames to valid SAS names*/
%macro fixname(badname); 
   %if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
      %then %let badname=_&badname;
   %let badname=%sysfunc(compress(
	%sysfunc(translate(&badname,_,%str( ))),,kn));
   %if %length(&badname)>32
      %then %substr(&badname,1,32);
   %else &badname;
%mend fixname;
 
/*Importing a CSV File*/
%macro importcsv(file);
   options nonotes nosource;
   proc import 
      datafile="%superq(file)" 
      out=%fixname(%scan(&file,-2,/.\)) replace
      dbms=csv;
   run;
   options notes source;
%mend importcsv;
 

/*Importing All CSV Files*/
%macro findcsv(dir);
   filename filelist pipe "dir /b /s &dir\*.csv";
   options nonotes nosource;
   data _null_;
      infile filelist truncover;
      input filename $100.;
      call execute(cats('%importcsv(', filename, ')' ));
   run;
   options notes source;
%mend findcsv;


/*Executing all SAS programs*/
%macro findsas(dir);
   filename filelist pipe "dir /b /s &dir\*.sas";
   data _null_;
      infile filelist truncover;
      input filename $100.;
      call execute(cats('%include ', quote(trim(filename)), ';'));
   run;
%mend findsas;


/*Importing an Excel File*/
%macro importxls(excel);
   options nostimer;
   libname myexcel pcfiles path="&excel";
   proc sql noprint;
      select memname into :sheet1-
         from dictionary.tables
            where libname="MYEXCEL";
   quit;

   %do i=1 %to &sqlobs;        	
      data %fixname(&&sheet&i);
         set myexcel."&&sheet&i"n;
      run;
   %end;
   libname myexcel clear;
%mend importxls;


/*Using External File Functions*/
%macro findxls(dir) / minoperator;
   %local ref rc did n memname didc;
   %let rc=%sysfunc(filename(ref,&dir));
   %let did=%sysfunc(dopen(&ref));
   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist;
      %return;
   %end;
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%sysfunc(dread(&did,&n));
      %if %upcase(%scan(&memname,-1,.)) in XLS XLSX 
         %then %put &dir/&memname;	
   %end;
   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(ref));
%mend findxls;


/*Importing All Excel Files*/
%macro findxls(dir) / minoperator;
   %local fileref rc did n memname didc;
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));
   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist.;
      %return;
   %end;
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%sysfunc(dread(&did,&n));
      %if %upcase(%scan(&memname,-1,.)) in XLS XLSX %then 
         %put &dir/&memname;	
      %else %if %scan(&memname,2,.)= %then
         %findxls(&dir/&memname);	
   %end;
   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
%mend findxls;

/*Importing External Files*/
%macro importdriver(type=,dir=.);
   %local rc did didc;
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));
   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist.;
      %return;
   %end;
   %let type=%upcase(&type);
   %if       &type=CSV %then %findcsv(&dir);
   %else %if &type=XLS %then %findxls(&dir);
   %else %do;
      %put ERROR: Valid Types are: CSV, XLS.;
      %put ERROR- XLS includes XLS and XLSX.;
    %end;
