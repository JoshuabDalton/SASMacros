***************************************************
* Macro: findsas                                  *
* Purpose: Executing all SAS Programs in folder   *
***************************************************;
%macro findsas(dir);
  filename filelist pipe "dir /b /s &dir\*.sas";
  data _null_;
    infile filelist truncover;
    input filename $100.;
    call execute(cats('%include ', quote(trime(filename)), ';'));
  run;
%mend findsas;
