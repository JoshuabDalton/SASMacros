*************************************************
* Macro: findcsv                                *
* Purpose: Importing all CSV Files in directory *
*************************************************;

%macro findcsv(dir);
  filename filelist pipe "dir /b /s &dir\*.csv";
                        /*dir command similiar to command prompt; /b bare format (suppresses header and summary info
                                                                /s include all subfolders in search 
                                                                *.csv wildcard to find all csv files  */
  options nonotes nosource;
  data _null_;
    infile filelist truncover;
    input filename $100.;
    call execute(cats('%importcsv(', filename, ')' )); /*use execute call routine to issue data-driven macro calls to 
                                                         the Importcsv macro for every CSV file found in a selected
                                                         folder and all its subfolders*/ 
  run;
  options notes source;
%mend findcsv;
