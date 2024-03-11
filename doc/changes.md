## Entwicklung und Ausblick
- tclbib sollte auch ein package werden, gerade um einge Variablen aus dem 
  global Bereich zu nehmen

- MVC Konzept:
    + View  	= Gui::  
    + Control	= Tclbib::
    + Model 	= Db:: und andere

## Bekannte, noch fehlende Features
keine?

## Bekannte Fehler
- Suchen in Feldern mit einem , geht nicht recht ? 

Diese Fehler treten nur in HPUX auf und können 
von mir nicht behoben werden:
- Nicht erreichbare Einträge, die eigentlich grau sein muessten werden dennoch
  nach dem ersten überfahren schwarz angezeigt 

Diese Fehler treten nur in Win3.1 auf, nicht in Win95/NT oder UNIX und können 
von mir nicht behoben werden:
- Alt Tab ist blockiert
- Tclbib läßt sich nur einmal starten 

## Bekannte Unstimmigkeiten
- soll Entry/Delete alle Mausmarkierten oder alle mit Sternchen vesehenen
  Eintraege loeschen?


-------------------------------------------------------------------------------
## Version 11.3.2024
CHANGED:
- Kleine Anpassungen nach 23 Jahren (UTF-8, md statt txt)
NEU: 
- DOI als neue Feld

## Version 20.9.2001
NEU:
- Mehr BibTex Formate bei new
- Laufzeitversion ist nur noch eine komprimierte Datei, dadurch ist nun gar 
  keine Pfadangabe mehr zur Laufzeit notwendig
- Bei der Neueingabe wird eine leere TEXID korrekt belegt


## Version 19.9.2000
VERÄNDERT:
- ID wird nicht mehr gespeichert
- WarnSaver überarbeitet
- busyCounter gibt strukturiertere Verlaufsinfo, 
  dadurch ca 40% bessere Ladezeit beim *.ilf Laden
- Quelltext überarbeitet


## Version 12.9.2000
VERÄNDERT:
- Bibtex Export exportiert alles, falls nichts selektiert war
- Texid Erzeugung ist zuverlässiger und im neuen Format
- Warnung nach Änderungen und Import verbessert
- im Html export wird auch das place Feld geschrieben
- Rtf Ausgabe verfeinert
- Quelltext überarbeitet
- NLM to ILF Menüpunkt entfernt

NEU:
- Select Duplicate Texid

## Version 1.7.1998
ENTFERNTE BUGS:
- graue Menueeintraege sind jetzt auch in 3.11 grau (in HPUX gibt es da noch
  Probleme)
 
VERÄNDERT:
- Bibtex Ausgabe verfeinert, Month fehlt jedoch noch


NEU:
- Warnung, wenn man ohne vorherige Selektion Export versucht
- Export als RTF, jedoch nur der Stil wie auch in HTML


## Version 17.4.1998

ENTFERNTE BUGS:
- NLM to ILF Filter 

## Version 27.3.1998

NEU:
- Edit New erzeugt einen (fast) leeren neuen Eintrag am Ende der Liste
- Standard beim Export option ist es nun nur Selektierte zu exportieren
- Export erlaubt auch das Exportieren im eigenen ILF Format

VERÄNDERT:
- Invert Selection, Deselect und Select All beschleunigt, hoffentlich..


## Version 23.1.1998

ENTFERNTE BUGS:
- Speicherproblem unter DOS behoben
- einige nlm Felder (z.B. OTITLE) wurden gelesen aber nicht gespeichert
- Namen wie d'Amore etc. gehen jetzt 
- Eckige Klammern um Titel werden entfernt


## Version 8.1.1998

NEU: 
- komplett neue interne Datenstruktur, jeder Record ist eine Liste nur der
  vorhandenen Felder, deren erstes Zeichen ist ein Tag für Art des Feldes.
  Fest stehen lediglich die ersten n Felder, über die auch gesucht werden 
  kann. Insgesamt sollte damit das Verhalten bei großen Listen verbessert 
  sein.
- Funktionen zum Selektieren, Deselektieren und Invertieren aller Einträge
- Export Optionen ermöglichen für alle Format export von allen oder nur der
  selektierten Einträge

  
VERÄNDERT:
- Suchdialog ist auf eine "vernünftige" Anzahl von Einträgen begrenzt
- Datumsformat nun im Stil 1990/01/31, ist u.a. besser sortierbar
- Medline Format der von der EM und LR Felder wurde von der Medline um 
  Jahrhundert ergänzt, momentan werden beide Formate korrekt verarbeitet
- Nicht analysierbare SO Zeilen führen zu einer Warnung und nicht mehr zu 
  einem Abbruch.
- alle bekannten exotischen Namensformen werden korrekt importiert 

## Version 10.12.1997

NEU:

- die Dateipfade bei alle open/save Dialogen werden gespeichert 
  (wichtig bei 3.11) 
- die Dialogboxen haben korrekte Titel
- All files sind * UND *.*

Mergen zweier ILF Dateien master.ilf new.ilf (hier nur UNIX Workaround)
	- Loesche new.ilf ID in vi: %s/:ID:\(.*\)/:ID: -/
	- open master
	- merge new
	
Medline Download Verfahren 10.12.97
- 	Wähle: Medline Report
- 	Display (möglichst viele auf einmal)
- 	wichtig: erste Textzeile ist ein UI  - usf
- 	"Save the above reports in \[Mac/PC/Unix ist fur tclbib egal\] [Text]"


## Version 9.12.1997

BUGFIX:
- man kann wieder speichern...

NEU:
- es werden 4 backupstufen verwaltet name.il1 name.il2 name.il3 name.il4
  die il1 ist die juengste. 
- beim Schreiben wird erst ein il0 geschrieben, dann der umbennungsshift 
  3->4 2->3 1->2 gemacht, dann il0 in ilf umbennant
- es gibt es zeitliche gesteuerte Save Warnung: alle 5 Minuten wird 
  gewarnt, falls es mehr als 10 Aenderungen gab, Merge und Import sind keine
  Aenderungen in diesem Sinn. Save setzt die Anzahl wieder auf 0.

-------------------------------------------------------------------------------
## Version 7.12.97

NEU:
- Suchen geht jetzt sehr viel differenzierter ueber alle (zuviele) 
  Felder. 
  + z.B. Suche alle Eintraege mit Place Inhalt: 
  	Suchtext ist '??' (= alle Eintraege  mit mind 2 Zeichen im 
	Place Feld, ein '-' steht ja immer drin)
- Neuer String im Listenfeld: Journal wird mitangezeigt, auch sortierbar
- im Listenfeld kriegt man mit der rechten Taste ein Popupmenu
- Sicherheitsabfragen bei gefaehrlichen Operationen
- MESH, OBJECTS Felder werden nicht mehr aus NLM importiert (wohl werden 
  bereits vorhandene im ILF weiter gespeichert)
- Tastaturkuerzel im Menu
- Tastaturkuerzel in Dialogen (z.B. Cancel <Escape>, OK <Return>)
- in den Editfeldern werden ID und **** nicht mehr angezeigt
- Cursor steht im Editfeld auf erstem noch einzugebendem Feld (z.B. Place)

INKOMPATIBILITAETEN:
- u.U. die Datei e:\tclbib.ini ist nicht mehr so gueltig und sollte erstmal 
  wieder geloescht werden.

GEPLANT:
- Doubletten  / Merge 
- Masken fuer neue manuelle Eintraege, Buch / Proceedings etc 
  Unterstuetzung
- Datumsortierung (s.u) 
- Hilfetexte
 
DESIGN:
- TITLE / OTITLE Konzept :
 	ich will TITLE zum Orginaltitel machen, falls dieser bekannt ist, 
	ansonsten ist es der englische Titel.
	OTITLE enthält einen Alternativtitel, i.Allg. den englischen Titel. 
	Das Feld sollte eigentlich besser ATITLE / ETITLE o.ae heissen.
	nun gut: OTITLE = Other Title ...
	
- DATE: das Datum waere leichter als 1996/05/31 sortierbar gewesen, 
  	egal was dann mit 1996/05-06/31 waere. Ich werde es wohl verträglich 
  	umstellen)

