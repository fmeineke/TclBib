package provide Rtf 1.0
package require Basic 1.0
package require Db 1.0

namespace eval Rtf {
    namespace export writeFile
}

proc Rtf::formatEntry { entry } {
    global outFields
    set out ""
    append out [format "%s: " [Entry::getField $entry AUTHOR]]
    if { [Entry::getField $entry OTITLE] != ""} {
	append out [format "{\\i %s}" [Entry::getField $entry OTITLE]]
    } else {
	append out [format "{\\i %s}" [Entry::getField $entry TITLE]]
    }
    if { [Entry::getField $entry JOURNAL] != ""} {
    	append out [format ", %s" [Entry::getField $entry JOURNAL]]
    }
    
    
    set tmpout  ""
    if { [Entry::getField $entry VOLUME] != ""} {
    	append tmpout [format "{\\b %s}" [Entry::getField $entry VOLUME]]
    }
    if { [Entry::getField $entry NUMBER] != ""} {
	append tmpout [format "(%s)" [Entry::getField $entry NUMBER]]
    }
    if { $tmpout != "" } {
    	append out [format ", %s" $tmpout]
    }
    
    if { [Entry::getField $entry PAGES] != ""} {
    	append out [format ", %s" [Entry::getField $entry PAGES]]
    }
    
    if { [Entry::getField $entry PDATE] != ""} {
    	set tmpout  [format ", %s" [Entry::getField $entry PDATE]]
	regsub {.*(....)$} $tmpout "\\1" tmpout
    	append out [format ", %s" $tmpout]

    }
    
    append out "\\par"
    return [Basic::wrapString $out]
}

proc Rtf::header { } {
    return "\{\\rtf1\\ansi"
}

proc Rtf::footer { } {
    return "\}"
}

proc Rtf::writeFile { fname } {
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
    puts $fp [footer]
    Basic::busyCounter off
    close $fp
}
