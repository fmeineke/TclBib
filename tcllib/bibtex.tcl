package provide BibTeX 1.0
package require Basic 1.0
package require Db 1.0

namespace eval BibTeX {
    namespace export writeFile
}


proc BibTeX::convString { s } {
    regsub -all "ä" $s "{\\\"a}" s
    regsub -all "ö" $s "{\\\"o}" s
    regsub -all "ü" $s "{\\\"u}" s
    regsub -all "Ä" $s "{\\\"A}" s
    regsub -all "Ö" $s "{\\\"O}" s
    regsub -all "Ü" $s "{\\\"U}" s
    regsub -all "%" $s "\\\%" s
    regsub -all "\&" $s {\\&} s
    return $s
}


proc BibTeX::addCont { texname f } {
    if { $f != "" } {
	set ret [format "%s = {%s},\n" $texname [convString $f]]
 	return $ret
    }
    return ""
}

proc BibTeX::addField { entry texname field} {
    return [addCont $texname [Entry::getField $entry $field]]
}

proc BibTeX::formatEntry { rec } {
    global outFields
    set out ""


# oder sollte ich das blind übernehmen ?
#   switch -regexp [string tolower [Entry::getField $rec PTYPE]] {
#	"book" {append out "@book" }
#	"inbook" {append out "@inbook" }
#	"unpublished" {append out "@unpublished" }
#	"incollection" {append out "@incollection" }
#	"inproceedings" {append out "@inproceedings" }
#	default {append out "@article" }
#    }
    set ptype [string tolower [Entry::getField $rec PTYPE]]
    if { $ptype == "" } { 
    	set ptype "article"
    }
    append out "@" $ptype
    append out  "{" [Entry::getField $rec TEXID] ",\n"


    set f [Entry::getField $rec AUTHOR]
    regsub -all " *; *" $f " and " f
    regsub -all "\\\." $f ". " f
    append out  [addCont author $f]


    set f [Entry::getField $rec TITLE]
    if { [Entry::getField $rec LANGUAGE] != "" } {
	append out  [addCont title [format "{%s}" $f ]]
    } else {
	append out  [addCont title $f ]
    }
#   if { [Entry::getField $rec OTITLE] != ""} {
#       append out [format "title  = {%s},\n" [Entry::getField $rec OTITLE]]
#   } else {
#       append out [format "title  = {%s},\n" [Entry::getField $rec TITLE]]
#   }

    append out [addField $rec booktitle BOOKTITLE]
    append out [addField $rec publisher PUBLISHER]
    append out [addField $rec edition EDITION]
    append out [addField $rec address PADDRESS]

    set f [Entry::getField $rec EDITOR]
    regsub -all " *; *" $f " and " f
    regsub -all "\\\." $f ". " f
    append out  [addCont editor $f]

    append out [addField $rec journal JOURNAL]
    append out [addField $rec pages PAGES]
    append out [addField $rec volume VOLUME]
    append out [addField $rec number NUMBER]
    append out [addField $rec series SERIES]
    append out [addField $rec note NOTE]
    append out [addField $rec school SCHOOL]
    append out [addField $rec organization ORGANIZATION]
    append out [addField $rec institution INSTITUTION]
    append out [addField $rec type CTYPE]
    append out [addField $rec doi DOI]

    set f [Entry::getField $rec PDATE]
    regsub {.*\.([^\.]*)} $f "\\1" year
    if { $year != "" } {
	append out [addCont  "year" $year ]
    }
# Da stimmt was nicht, vorerst kein Monat in der Ausgabe
#   regsub {(.*\.)?([^\.]+)\..*} $f "\\2" month
#   if { $month != "0" } {
#       append out [format "month = {%s},\n" $month ]
#   }

    append out "}\n"
    
#    return [Basic::wrapString $out]
    return $out
}

proc BibTeX::header { } {
    set s "BibTeX Literature Database\n"
    append s [format "Generated : %s\n" [getDate] ]
    return $s
}

proc BibTeX::footer { } {
    return ""
}

proc BibTeX::writeFile { fname } {
    global outputSelected
    set fp [open $fname "w"]
    
    Basic::busyCounter on
    
    puts $fp [header]
    foreach entry  $Db::dbList {
	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    puts $fp [formatEntry $entry]
	    puts $fp ""
    	    Basic::busyCounter incr
	}
    }
    Basic::busyCounter off
    puts $fp [footer]
    close $fp
}
