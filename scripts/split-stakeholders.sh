#!/bin/bash

# 2 arguments
#   1: stakeholders file
#   2: the columns to keep as a ; seperated string
#
#  ./split-stakeholders.sh stakeholders.csv "Adres;Gebouw;Generiek"


CONCEPTSCHEMECSV=$1


awk -F ";" \
     -v selected="$2" \
     'BEGIN{
	   FS=OFS=";"
           ORS=""
	}
        (NR<2) {
             for (i=1 ; i <= NF ; i++) { header[tolower($i)]=i }
	    
             split(selected, selectedArray, ";");
             print $1 ";" $2 ";" $3 ";" $4 ";" $5 ";" 
	    for (a in selectedArray) { 
                print $header[tolower(selectedArray[a])] 
		print ";"
	   } 
             print "bool"
             print "\n"
         }
         (NR > 1) {
            print $1 ";" $2 ";" $3 ";" $4 ";" $5 ";" 
            bool=0;
	    for (a in selectedArray) { 
                print $header[tolower(selectedArray[a])] 
		print ";"
                if ($header[tolower(selectedArray[a])] != "") { bool = 1}
		}
	     print bool;
             print "\n"
         }
         ' $CONCEPTSCHEMECSV > /tmp/ruw

awk -F ";" \
     'BEGIN{
	   FS=OFS=";"
           ORS=""
	}
     (NR < 2) { 
             for (i=1 ; i <= NF-1 ; i++) { print $i ";"}
             print "\n";
     }
     (NR > 1) {
        
	if ($NF != 0) {
             for (i=1 ; i < NF ; i++) { print $i ";"}
        print "\n";
	}
	
     }
         ' /tmp/ruw

