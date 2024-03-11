#Aufbau des Tclbib Programms

##Pflichtenheft:
- alle Daten liegen in einer Textdatei
- Import von Medline Daten
- Eintragen eigener Bemerkungen zu einem Eintrag
    
    
##Model-View-Controller

Gui:: 
- enthält alle Viewspezifischen Routinen, insbesondere alle TK Befehle.
- greift nur auf Control:: zu

Control:: 
-  greift auf alle Module zu

Exportfilter
- greifen nur auf Db:: zu
    
Db::
 - greift auf nichts zu
 - Verwaltung aller Einträge

Besondere Schwierigkeit sind tcl bedingt:
- es gibt nur Listen und assoz. Arrays
- die Einträge haben eine sehr heterogene Anzahl von Feldern
- ein inplace Replace in Listen gibt es nicht (?)
- sortieren geht nur über lsort

Wie ist es nun gemacht?
- Jeder Eintrag ist ein Liste, wobei einige Elemente Pflichtelement
sind, die immer vorkommen. Nur nach diesen kann sortiert werden.
