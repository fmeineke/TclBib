package provide Entry 1.0

namespace eval Entry {
    namespace export \
    	getString \
    	getField \
	getSearchFields \
	getFieldIndex \
	setField \
	getId \
	getNew \
	init
    variable fieldIndex     ;# Array zum Wandeln Kurz <-> Lang Feldbezeichner
    variable searchFields   ;# Eintraege ueber die gesucht werden kann
    variable fieldInfo      ;# Informationen zu Feldern selber
    variable nextId         ;# naechste frei zu vergebende ID
    variable asciia         ;# Konstante: ASCII kleines a
    proc Entry { } { }
}
	
proc Entry::getNew { { id none } } {
    variable nextId
    if { $id == "none" } {
    	set id  $nextId
    	set nextId [int2id [expr [id2int $nextId] + 1]]
    }
    return [list A0 "B$id" C D E F]
}

proc Entry::getFieldIndex { fieldName } {
    variable fieldIndex
    scan $fieldIndex($fieldName) "%c" n
    return [expr $n - 65]
}

#
proc Entry::getField { entry fieldName } {
    variable fieldIndex
    if [catch "set fieldId $fieldIndex($fieldName)"] {
	Basic::Error [format "get:: unknown field name %s " $fieldName]
	return ""
    }
    set entryFieldIndex [lsearch  $entry $fieldId*]
    if { $entryFieldIndex == -1 } {
	return ""
    } else {
	return [string range [lindex $entry $entryFieldIndex] 1 end ]
    }
}

# Setzen, dabei entweder HinzufÃŒgen oder Ersetzen
proc Entry::setField { entryVar fieldName cont } {
    variable fieldIndex
    upvar $entryVar entry
    
# ids werden auschlieÃlich von Entry::getNew vergeben
    if { ! [string compare $fieldName "ID" ]} { return 0 }
    
    if [catch "set fieldId $fieldIndex($fieldName)" ] {
	Basic::Error [format "unknown field %s ignored" $fieldName]
	return 1
    }
    set entryFieldIndex [lsearch  $entry $fieldId*]
    if { $entryFieldIndex == -1 } { 	;# Feld gab es noch nicht ?
	lappend entry "$fieldId$cont"	;# dann hÃ€nge es jetzt dran
    } else {
	set entry [lreplace $entry $entryFieldIndex $entryFieldIndex \
		"$fieldId$cont"]
    }
    return 0
}

# Ersetzen ohne Abfrage
# Wird zur Zeit nicht mehr benutzt ?
proc Entry::replaceField { entryVar fieldName cont } {
    upvar $entryVar entry
    variable fieldIndex
    set fieldId $fieldIndex($fieldName)
    set entryFieldIndex [lsearch  $entry $fieldId*]
    set entry [lreplace $entry $entryFieldIndex $entryFieldIndex \
	"$fieldId$cont"]
}

proc Entry::setSelected { entryVar { sel 1 } } {
    upvar $entryVar entry
    set entry [lreplace $entry 0 0 "A$sel" ]
}

proc Entry::isSelected { entry } {
    return [string range [lindex $entry 0] 1 end ]
}

proc Entry::setId { entryVar id } {
    upvar $entryVar entry
    set entry [lreplace $entry 1 1 "B$id" ]
}

proc Entry::getId { entry } {
    return [string range [lindex $entry 1] 1 end ]
}

# getEntryDisplayString 
# Konstruiert den anzuzeigende String, fest formatiert als 110 Zeichen 
# siehe Gui::createMainList

proc Entry::getString {entry} {
    # Ein Stern zeigt selektierte EintrÃ€ge an
    if { [isSelected $entry ] } {
	set sel "*"
    } else {
	set sel " "
    }

    # Nur die Nachnamen der Autoren
    set author  [getField $entry AUTHOR ]
    regsub -all {,[^;]*.} $author "" author


    set journal [ getField $entry JOURNAL ]
    regsub -all {\. } $journal "." journal
    
    if { $journal == "" } {
    	set journal [ getField $entry PTYPE ]
    }
    
    # das grosse return brachte tclparse zum Absturz
    set ret [format "%s%3s %-20s %-45s %-16s %-19s %s%s" \
	    $sel  \
	    [getId $entry ] \
	    [string range $author 0 19] \
	    [string range [getField $entry TITLE ] 0 44] \
	    [string range $journal 0 15] \
	    [string range [getField $entry TEXID ] 0 18] \
	    [string range [getField $entry DOMAIN] 0 0] \
	    [string range [getField $entry PLACE] 0 0] ]
    return $ret
}


proc Entry::createTexId { entryVar } {
    upvar $entryVar entry

    set texid  ""

    set f [getField $entry AUTHOR]
# nur den Nachnamen des Erstautors, den Rest wegschneiden
    regsub -all ",.*" $f "" f
# nestimmte Sonderzeichen komplette lÃ¶schen
    regsub -all "'" $f "" f
# andere Sonderzeichen durch einen Unterstrich ersetzen
    regsub -all -- "\[- \]" $f "_" f
# in Kleinbuchstaben wandeln
    append texid [ string tolower $f ]
    set f [getField $entry PDATE]
# vom  Jahr nur die letzen zwei Stellen
    regsub {.*(..)$} $f "\\1" f
    append texid "-" $f
    set f [getField $entry PAGES]
# von der Seitenzahl nur die erste Ziffernfolgem den Rest wegschneiden
    regsub {([0-9][0-9]*).*$} $f "\\1" f
    append texid "-" $f

    if { $texid == "--" }  {
    	set texid "-"
    }
    setField entry TEXID $texid
}

proc Entry::getSearchFields { } {
    variable searchFields
    return $searchFields
}

proc Entry::init { } {
    variable fieldIndex
    variable nextId  aaa
    variable fieldInfo [ list \
	[list SELECTED  0 "Systemintern"]\
	[list ID        0 "Systeminterne eindeutige Kennung, z.B. abc"] \
	[list TEXID     0 "Kennung fuer Textverarbeitung, z.B. arnl-dpcm-96"] \
	[list AUTHOR    1 "Autorenliste, z.B. Alexander,W.S.; Roberts,A.W."] \
	[list TITLE     1 "Titel (Orginal)" ] \
	[list JOURNAL   1 "Zeitschrift"] \
	[list OTITLE    0 "englischsprachiger Titel, falls abweichend von TITLE" ] \
	[list NOTE      0 "Technische Bemerkungen"] \
	[list PDATE     1 "Publikations Datum, z.B. 1996/04/23 23.4.1996"] \
	[list PTYPE     1 "Publikations Typ, z.B. Article, Book"] \
	[list CTYPE     0 "Inhaltlicher Typ, z.B. Report, Study" ] \
	[list NUMBER    0 "Heftnummer"] \
	[list VOLUME    0 "Zeitschriftenband"] \
	[list PAGES     0 "Seitenbereich, z.B. 12-18 , 13"] \
	[list PLACE     1 "Ablage" ]\
	[list KEYWORDS  1 "Nutzerdefinierte Schluessel"] \
	[list CONTENT   1 "Nutzerdefiniertes Inhaltsfeld"] \
	[list ABSTRACT  1 "Zusammenfassung" ] \
	[list MESH      1 "Medline Schlagwoerter"] \
	[list OBJECTS   0 "Schlagwoerter bzgl. Dingen"] \
	[list PERSONS   0 "Schlagwoerter bzgl. Personen"] \
	[list AADDRESS  0 "Autoren Anschrift"] \
	[list XREF      0 "???"] \
	[list REFNUM    0 "???"] \
	[list DBDATE    0 "Datum des Eintrags in die Datenbank"] \
	[list LANGUAGE  0 "Sprache der Publikation" ] \
	[list ISSN      0 "Zeitschriften Code" ] \
	[list GRANTID   0 "???"] \
	[list MEDID     0 "Medline Kennummer"] \
	[list PUBMEDID  0 "Public Medline Kennummer"] \
	[list BOOKTITLE 1 ""] \
	[list CHAPTER   0 ""] \
	[list EDITION   0 ""] \
	[list EDITOR    0 ""] \
	[list PUBLISHER 0 "Herausgeber"] \
	[list PADDRESS  0 ""] \
	[list SCHOOL    0 ""] \
	[list INSTITUTION 0   ""] \
	[list SERIES    0  ""] \
	[list ORGANIZATION 0    ""] \
	[list PUBLISHEDAS 0 ""] \
	[list DOI      0  ""] \
	[list ISBN      0  ""] \
 	[list DOMAIN    1  "Bereich, z.B., Medizin/Informatik"] \
   ]
    
    variable asciia    
    scan a "%c" asciia

    variable searchFields
    set searchFields [list]
    set fieldId A
    foreach f $fieldInfo {
	set fieldName [lindex $f 0] 	    	;# fieldName = AUTHOR
	set fieldIndex($fieldName) $fieldId 	;# fieldIndex(AUTHOR) D
	set fieldIndex($fieldId) $fieldName 	;# fieldIndex(D) AUTHOR
	scan $fieldId "%c" n
	if { $fieldId == "Z" } {    	    	;# bei 'Z' angekommen?
	    set fieldId a   	    	    	;# mach weiter mit 'a'
	} else {    	    	    	    	;# ansonsten
	    incr n  	    	    	    	;# gehe zum nÃ€chsten Buchstaben
	    set fieldId [format "%c" $n]
	}
# Die Felder mit der 1 erscheinen im Suchdialog
	if { [lindex $f 1] == "1" } {
	    lappend searchFields $fieldName
	}
    }

}

proc Entry::id2int {id} {
    variable asciia
    scan $id  "%c%c%c" i1 i2 i3
    incr i1 -$asciia
    incr i2 -$asciia
    incr i3 -$asciia
    return [expr $i1 * 676 + $i2 * 26 + $i3]
}

proc Entry::int2id {i} {
    variable asciia
    set i1 [ expr $i / 676 ] ; set i  [ expr $i % 676 ]
    set i2 [ expr $i / 26 ]
    set i3 [ expr $i % 26 ]
    incr i1 $asciia
    incr i2 $asciia
    incr i3 $asciia
    return [format "%c%c%c" $i1 $i2 $i3]
}

Entry::init

