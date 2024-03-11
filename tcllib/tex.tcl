package provide TeX 1.0
package require Basic 1.0
package require Db 1.0

namespace eval TeX {
    namespace export writeFile
}


proc TeX::formatEntry { entry } {
    global outFields
    set out ""
    append out [format "\\textsc{%s}: " [Entry::getField $entry AUTHOR]]
    if { [Entry::getField $entry OTITLE] != ""} {
	append out [format "\\emph{%s}" [Entry::getField $entry OTITLE]]
    } else {
	append out [format "\\emph{%s}" [Entry::getField $entry TITLE]]
    }
    append out [format ", %s" [Entry::getField $entry JOURNAL]]
    append out [format ", \\textbf{%s}" [Entry::getField $entry VOLUME]]
    if { [Entry::getField $entry NUMBER] != ""} {
	append out [format ",(%s)" [Entry::getField $entry NUMBER]]
    }
    append out [format ", pp.%s" [Entry::getField $entry PAGES]]
    append out [format ", %s\n" [Entry::getField $entry PDATE]]
    return [Basic::wrapString $out]
}

proc TeX::header { } {
    return ""
}

proc TeX::footer { } {
    return ""
}

proc TeX::writeFile { fname } {
    global outputSelected

    set fp [open $fname "w"]
    puts $fp [header]
    foreach entry $Db::dbList {
	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    puts $fp [formatEntry $entry]
	}
    }
    puts $fp [footer]
    close $fp
}
