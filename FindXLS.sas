***************************************************
* Macro: findxls                                  *
* Purpose: excel files in folder                  *
***************************************************;

%macro importxls(excel);
  options nostimer;
  libname myexcel pcfiles path="&excel"; /*assign libref to the requested workbook*/
  proc sql noprint;                        
    select memname into :sheet1-          /*Identify worksheets within workbook         */
      from dictionary.tables              /*and assigns name of each to a macro variable*/
        where libname="MYEXCEL";
  quit;

  %do i=1 %to &sqlobs;                    /*Each iteration of the do loop generates a data step to import one worksheet*/
    data %fixname(&&sheet&i);             /*fixname macro removes the $ sign*/
      set myexcel."&&sheet&i"n;
    run;
  %end;
  libname myexcel clear;
%mend importxls;