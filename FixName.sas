**************************************************************
* Macro:   FixName                                           *
* Purpose: Correct Invalid Names of Files we want to read in *
           (used in conjunction with %import____ macro)      *
**************************************************************;

%macro fixname(badname);
  *if first character is numeric then insert underscore;
  %if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
    %then %let badname=_&badname;

  *translate from blank to underscore and keep valid name characters;
  %let badname=%sysfunc(compress(%sysfunc(translate(&badname,_,%str( ))),,kn)); 
                                                                         
  *substr extracts first 32 characters;
  %if %length(&badname)>32
    %then %substr(&badname,1,32); 
  %else &badname; 
%mend fixname;

*Examples;
/*
%put %fixname(bad name #1);
%put %fixname(123Bad na!@#$*-%^me);
%put %fixname(1234456890-234589-24589-234589-89-234589-234);
*/