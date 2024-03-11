package provide Csv 1.0
package require Basic 1.0
package require Db 1.0

namespace eval Csv {
    namespace export writeFile
}

proc Csv::formatEntry { entry } {
	set sep ","
    set out ""
  
   	append out [format "\"%s\"" [Entry::getField $entry TEXID]]
	set t 0
 	switch [Entry::getField $entry PTYPE] {
		"" { 
			set t "0"
		}
		"article" { 
			set t "0"
		}
		"book" {
			set t "1"
		}
	}
    append out [format "%s\"%s\"" $sep $t]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry AUTHOR]]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry EDITOR]]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry PUBLISHER]]
    if { [Entry::getField $entry OTITLE] != ""} {
		append out [format "%s\"%s\"" $sep [Entry::getField $entry OTITLE]]
    } else {
		append out [format "%s\"%s\"" $sep [Entry::getField $entry TITLE]]
    }
	append out [format "%s\"%s\"" $sep [Entry::getField $entry TITLE]]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry JOURNAL]]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry VOLUME]]
	append out [format "%s\"%s\"" $sep [Entry::getField $entry NUMBER]]
    append out [format "%s\"%s\"" $sep [Entry::getField $entry PAGES]]
    
	set tmpout  [format ", %s" [Entry::getField $entry PDATE]]
	regsub {.*(....)$} $tmpout "\\1" tmpout
    append out [format "%s\"%s\"" $sep $tmpout]
    
	return $out
}
proc Csv::header { } {
    global outputSelected
    set n 0
    foreach entry $Db::dbList {
    	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    incr n
	}
    }
	set sep ","
    set s [format "Identifier"]
	append s [format "%sType" $sep]
	append s [format "%sAuthor" $sep]
	append s [format "%sEditor" $sep]
	append s [format "%sPublisher" $sep]
	append s [format "%sTitle" $sep]
	append s [format "%sBooktitle" $sep]
	append s [format "%sJournal" $sep]
	append s [format "%sVolume" $sep]
	append s [format "%sNumber" $sep]
	append s [format "%sPages" $sep]
	append s [format "%sYear" $sep]
    return $s
}
proc Csv::writeFile { fname } {
    global outputSelected

    set fp [open $fname "w"]
    puts $fp [header]
    Basic::busyCounter on
    foreach entry $Db::dbList {
		if { ! $outputSelected || [Entry::isSelected $entry] } {
	    	puts $fp [formatEntry $entry]
    	    	Basic::busyCounter incr
		}
    }
    Basic::busyCounter off
    close $fp
}
