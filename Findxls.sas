******************************************************
* Macro: findxls                                     *
* Purpose: find all excel files in folder/subfolder  *
******************************************************;

%macro findxls(dir) / minoperator;
  %local ref rc did n memname didc;
  %let rc=%sysfunc(filename(ref, &dir)); /*FILENAME function assigns a fileref to the folder. Because the first argument, the macro variable, ref, has a null value, a fileref is generated and assigned to ref. */
  %let did=%sysfunc(dopen(&ref)); /* the macro variable, ref, is passed to the DOPEN function to open the requested folder. The return value, a directory identifier, is assigned to a macro variable named did.*/
  %if &did=0 %then %do;
    %put ERROR: Directory %upcase(&dir) does not exist;
    %return;
  %end;
  %do n=1 %to %sysfunc(dnum(&did));  /* The %DO loop iterates from 1 to the number of members in the folder. The stop value is determined by the DNUM function. */
    %let memname=%sysfunc(dread(&did, &n));  /*On each pass through the loop, DREAD reads the name of the nth member. Each member name is converted to upper case, and the extension is tested to see whether it is an Excel file. If so, the full path and member name are written to the log.*/
    %if %upcase(%scan(&memname, -1,.)) in XLS XLSX
      %then %importxls(&dir/&memname);
    %else %if %scan(&memname, 2,.)= %then
      %findxls(&dir/&memname);  /*When a subfolder is found, Findxls calls itself with the name of the subfolder.*/
  %end;
  %let didc=%sysfunc(dclose(&did)); /*After every member has been processed, DCLOSE closes the folder*/
  %let rc=%sysfunc(filename(ref)); /*FILENAME deassigns the fileref*/
%mend findxls;