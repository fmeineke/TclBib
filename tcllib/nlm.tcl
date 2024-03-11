package provide Nlm 1.0
package require Basic 1.0
package require Db 1.0


namespace eval Nlm {
    namespace export readFile
}


#   Eingaben:                   Ausgabe:
#   van den Aardweg GJ          Aardweg, G.J. van den
#   van Marwijk Kooij M         Marwijk Kooij, M. van
#   Breton-Gorius J             Breton-Gorius, J.       
#   Le Bousse Kerdiles C        Le Bousse Kerdiles, C.  
#   McFarland-Starr EC          McFarland-Starr, E.C.
#   BUNDSCHUH, R				Bundschuh, R
#   d'Aloja P                   Aloja, P. d'
#   d'Amore F
#   et al
#   De Fusco M
#   Murphy MJ Jr                Murphy Jr, MJ
#   Keunig JJ [corrected to Keuning JJ]
#   Frei E 3d                   Frei 3d, E          
#   AU  - Locatelli
# NAME: et al | pre? main* initial? post?
# pre: [a-z' ]*
# main: [A-Z][a-z]*
# initial:   [A-Z]+
# post: .*
# Ergebnis et.al | main post, initial pre

# Nachname := [A-Za-z]*
# Ausgabe: Aardweg,G.J. van den
# Eingabe: AU  - Murphy MJ Jr (UI  - 97028167)
# Ausgabe: Murphy, M.J. Jr      # geht noch nicht
# ?? van den Murphy MJ Jr ??
proc Nlm::formatAuthor {name} {
    if { [regexp "et al" $name d ] } {
    	return "et al."
    }

    set pre ""
    set post ""
    set main ""
    set initial ""

    #regexp {([a-z ]*) ?([A-Z][^A-Z]*) ?([A-Z][^A-Z]*) ?([A-Z]+) ?([^ ]*).*} \
    #   $name dummy pre main1 main2 initial post

    #d'Amore -> d' Amore
    regsub -all {'} $name "' " name

    set l [split $name]
    set li [llength l]
    set i 0

    if { [string match {[a-z]*} [lindex $l $i]] } {
	append pre " [lindex $l $i]"
	incr i
    }
    if { [string match {[a-z]*} [lindex $l $i]] } {
	append pre " [lindex $l $i]"
	incr i
    }
#patch 14.4.2003
# nlm sendet auch GROSSBUCHSTABEN Nachname in AU:
# 
    if { [string match {[A-Z][-A-Za-z']*} [lindex $l $i]] } {
    set main [string totitle [lindex $l $i] ]
    incr i
    }
    if { [string match {[A-Z][a-z]*} [lindex $l $i]] } {
	append main " [lindex $l $i]"
	incr i
    }
    if { [string match {[A-Z]*} [lindex $l $i]] } {
	append initial " [lindex $l $i]"
	incr i
    }
    set post [lindex $l $i]
    if { $post != "" } {set post " $post"}

    regsub -all "\[A-Z\]\[a-z\]*" $initial "&." initial

#    puts [format "MAIN:<%s>" $main]
#    puts [format "POST:<%s>" $post]
#    puts [format "INITIAL:<%s>" $initial]
#    puts [format "PRE:<%s>" $pre]

    set ret [format "%s%s,%s%s" $main $post $initial $pre]
    return $ret
}

#Eingabe: J Theor Biol
#Ausgabe: J. Theor. Biol.
#Eingabe: ACM J XXX
#Ausgabe: ACM J. XXX.

proc Nlm::formatJournal {s} {
    variable fullWord [ list \
	"ACM" \
	"Acta" \
	"Blood" \
	"Blut" \
	"Cancer" \
	"Cell" \
	"Cytokines" \
	"Epithelial" \
	"Physical" \
	"Review" \
	"Letters" \
	"Genes" \
	"Stem" \
	"Virchows" \
    ]
    if { 0 != [ regsub -all " " $s ". " s  ] } { append s "." }
    
    foreach w $fullWord {
    	regsub -all "$w." $s $w s
    }
    return $s
}

# Aufgabe: "JOURNAL ARTICLE" wird ausgefiltert
proc Nlm::formatCType {s} {
    regsub -all "JOURNAL ARTICLE" $s "" s
    return $s
}

# Eingabe 2670-8 Suppl 2
# Ausgabe 2670-2678 Suppl 2
# Eingabe 594 (UI  - 96300590)
# Ausgabe 594
proc Nlm::formatPages {s} {
    set from ""
    set to ""
    set remark ""
    regexp "(\[0-9\]+)-(\[0-9\]*)(.*)" $s d from to2 remark
    if { $from == ""} {
	regexp "(\[0-9\]+)(.*)" $s d from remark
	return [format "%s %s" $from $remark ]
    }
    set l [expr [string length $from] - [string length $to2]]
    incr l -1
    set to [string range $from 0 $l]
    return [format "%s-%s%s%s" $from $to $to2 $remark ]
}



# Nur Sprachen nicht-englisch als Sprache merken
# Eingabe: Eng
# Ausgabe:
proc Nlm::formatLanguage {s} {
    if {$s == "Eng"} return ""
    return $s
}

# Kleine Zoo Auswahl:
# TI  - Hazards of unit dose artificial tear preparations [letter] [see
#      comments]
# TI  - Is stem length important in uncemented endoprostheses? [published
#      erratum appears in Med Eng Phys 1995 Sep;17(6):478]
# TI  - [Juvenile ossifying fibroma of the facial skull. Computerized
#      tomography and nuclear magnetic resonance tomography]
# TI  - A mathematical approach to benzo[a]pyrene-induced hematotoxicity.
proc Nlm::formatTitle {s} {
    #set rest ""
    #regsub { *(\[[^[]*])$} $s "" s
    #regsub { *(\[[^[]*])$} $s "" s
    #regsub { ]$} $s "" s
    #puts $rest
    #regsub {\[(.*)\] ?} $s "\\1" s
    regsub {\[(.*)\] } $s {\1} s
    #regsub -all { ?\[.*\] ?} $s "" s
    return $s
}

# Eingabe: 759-73-9 (Ethylnitrosourea)
# Ausgabe: Ethylnitrosourea
proc Nlm::formatObject {s} {
    regsub ".*\\\((.*)\\\)" $s "\\1" s
    return $s
}

# Eingabe: Jan-Feb (UI 90218566)
# Ausgabe: 1-2
proc Nlm::formatMonth {s} {
    regsub "Jan" $s 01 s
    regsub "Feb" $s 02 s
    regsub "Mar" $s 03 s
    regsub "Apr" $s 04 s
    regsub "May" $s 05 s
    regsub "Jun" $s 06 s
    regsub "Jul" $s 07 s
    regsub "Aug" $s 08 s
    regsub "Sep" $s 09 s
    regsub "Oct" $s 10 s
    regsub "Nov" $s 11 s
    regsub "Dec" $s 12 s
    return $s
}

# Eingabe: 1996 Mar 15
# Ausgabe: 15.3.1996
# Eingabe: 1996 Mar
# Ausgabe: 3.1996
# Eingabe: 1996
# Ausgabe: 1996
proc Nlm::formatDateLong {s} {
    set nr [scan $s "%d %s %d" year monthname day]
    switch -- $nr {
	1 {return [format "%d" $year] }
	#2 {return [format "%d/%s" $year [formatMonth $monthname ] ] }
	#3 {return [format "%d/%s/%02d" $year [formatMonth $monthname ] $day ] }
	2 {return [format "%s.%d" [formatMonth $monthname ] $year] }
	3 {return [format "%02d.%s.%d" $day [formatMonth $monthname ] $year] }
    }
    return [format "ERROR CONVERTING DATE: %s" s]
}

# Eingabe: J Theor Biol 1995 Sep 7;176(1):79-89
# Cancer Chemother Pharmacol 1997;40 Suppl:S42-6
proc Nlm::formatSource {s ji di vi ni pi} {
    upvar $ji j
    upvar $di d
    upvar $vi v
    upvar $ni n
    upvar $pi p
    set n ""
# jetzt auch ein Punkt in den pages ganz hinten erlaubt.
# wurde ab 2001 in erster SO Zeile verwendet??    
#SO  - Pathol Res Pract 1992 Jun;188(4-5):410-2.
#SO  - Pathol Res Pract 1992 Jun;188(4-5):410-2

    regexp {([^12]*)([^;]*).([^\(:]*)\(?([^\):]*)\)?.([^\.]*).?} $s dummy jo do v n po
 #           <jo    ><date > <volume>    <number>     <pages + rest>
    if { $do == "" } {
	set jo ""
	set j $s
	set d ""
	set p ""
	return 0
    } else {
	set jo [string trimright $jo]
	set j [formatJournal $jo]
	set d [formatDateLong $do]
	set p [formatPages $po]
	return 1
    }
}

# Eingabe 970701 (bis 1997)
# Eingabe 19970701 (ab 1998)
# Ausgabe 1.7.1997 (bis 1997)
# Ausgabe 1997/07/01 (ab 1998)
proc Nlm::formatDateShort {s} {
    if { [string match {19*} $s] || [string match {20*} $s] } {
	set nr [scan $s "%04d%02d%02d" year month day]
    } else {
	set nr [scan $s "%02d%02d%02d" year month day]
	set year [expr $year + 1900]
    }
    switch -- $nr {
	1 { return [format "%04d" $year] }
	#2 { return [format "%d.%04d" $month $year] }
	2 { return [format "%d/%02d" $year $month] }
	#3 { return [format "%d.%d.%04d" $day $month $year] }
	3 { return [format "%d/%02d/%02d" $year $month $day] }
    }
    return ERROR
}


proc Nlm::addField { entryVar prevFieldNameVar contVar newFieldName s} {
    upvar $entryVar entry
    upvar $contVar cont
    upvar $prevFieldNameVar prevFieldName

    switch -- $newFieldName {
	"AUTHOR"    { set s [formatAuthor       $s] }
	"CTYPE"     { set s [formatCType        $s] }
	"LANGUAGE"  { set s [formatLanguage     $s] }
	"DBDATE"    { set s [formatDateShort    $s] }
    }
    if { $prevFieldName == $newFieldName} {
	append cont "; " $s
    } else {
	if { $prevFieldName != "" && $cont != ""} {
	    Entry::setField entry $prevFieldName $cont
	}
	set prevFieldName $newFieldName
	set cont $s
    }
}



proc Nlm::readEntry {fp entryVar} {
    upvar $entryVar entry

    set entry [Entry::getNew]
    Entry::setField entry PLACE "-"
    Entry::setField entry CONTENT "-"
    Entry::setField entry KEYWORDS "-"

    set cont ""
    set fieldName ""
    set lineNumber 0
    set key ""
    set endFlag 1
    while { ! [eof $fp] } {
	gets $fp inbuffer
	incr lineNumber
	set s [string range $inbuffer 6 end]
	set command [string range $inbuffer 0 4]
	switch -- $command {
	    # exakt 5 spaces
	    "     " {
		if { $cont != "" } {
		    append cont " " $s
		}
	    }
	    "TI  -" { addField entry key cont TITLE     $s }
	    "TT  -" { addField entry key cont OTITLE    $s }
	    "AB  -" { addField entry key cont ABSTRACT  $s }
	    "AU  -" { addField entry key cont AUTHOR    $s }
	    "PT  -" { addField entry key cont CTYPE     $s }
	    "AD  -" { addField entry key cont AADDRESS  $s }
	    "CM  -" { addField entry key cont XREF      $s }
	    "EM  -" { addField entry key cont DBDATE    $s }
	    "LR  -" { Entry::setField entry DBDATE ""
		      addField entry key cont DBDATE    $s }
	    "ID  -" { addField entry key cont GRANTID   $s }
	    "IS  -" { addField entry key cont ISSN      $s }
	    "LA  -" { addField entry key cont LANGUAGE  $s }
	    "PMID-" { set endFlag 0; addField entry key cont PUBMEDID  $s }
	    "RF  -" { addField entry key cont REFNUM    $s }
	    "UI  -" { addField entry key cont MEDID     $s }
	    "SO  -" {
		set j "" ; set d ""; set v "" ; set n "" ; set p ""
		if { [formatSource $s j d v n p ] } {
		    if { $j != "" } { Entry::setField entry JOURNAL $j}
		    if { $d != "" } { Entry::setField entry PDATE $d}
		    if { $v != "" } { Entry::setField entry VOLUME $v}
		    if { $n != "" } { Entry::setField entry NUMBER $n}
		    if { $p != "" } { Entry::setField entry PAGES $p}
		} else {
		    Warning [format "Die Quellenangabe (SO) des Artikels\n%s\nkonnte \
nicht korrekt analysiert werden" [Entry::getField $entry TITLE]]
		}
# SO gilt nicht mehr als Eintrags Ende (FAM 2001)
#		return 1
	    }
# Leerzeile markiert Record Ende, zweimal Leerzeile Dateiende
	    "" {
	    	if { $endFlag != 1 } { return 1; }
	    }
	    "     " {
		if { $key != "" && $cont != ""} {
		    Entry::setField entry $key $cont
		    set key ""
		    set cont ""
		}
	    }
	    default {
	    }
	}
    }
    return 0
}

proc Nlm::readFile {fname } {
    set fp [open $fname "r"]
    Basic::busyCounter on
    while { [readEntry $fp entry] } {
	# Einräge sortieren !
	Entry::setField entry TITLE [formatTitle [Entry::getField $entry TITLE]]

	set entry [lsort $entry]
	Db::addEntry entry
     	Basic::busyCounter incr
    }
    Basic::busyCounter off
    close $fp
}

