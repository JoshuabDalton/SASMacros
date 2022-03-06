***********************************************
* Macro:   ImportCSV                          *
* Purpose: Import CSV Files (one at a time)   *
***********************************************;

%macro importcsv(file);
  *suppress notes and source code in the log;
  options nonotes nosource; 

  *%superq to mask file name so no characters are misinterpreted;
  proc import
    datafile="%superq(file)"    
    out=%fixname(%scan(&file,-2,/.\)) replace  /*%scan to extract name portion of filename and run %fixname macro*/
    dbms=csv;
  run;

  *notes and source options are reset;
  options notes source; 
%mend importcsv;
