package provide Memo 1.0
package require Basic 1.0
package require Db 1.0

namespace eval Memo {
    namespace export writeFile
}

proc Memo::formatEntry { entry } {
    global outputTeXId
    set out ""
    if { $outputTeXId } {
		append out [format "%s\n"  [Entry::getField $entry TEXID]]
    }
    append out [format "%s:"  [Entry::getField $entry AUTHOR]]
    if { [Entry::getField $entry OTITLE] != ""} {
		append out [format " %s" [Entry::getField $entry OTITLE]]
    } else {
		append out [format " %s" [Entry::getField $entry TITLE]]
    }
    append out [format ", %s" [Entry::getField $entry JOURNAL]]
    append out [format ", %s" [Entry::getField $entry VOLUME]]
    if { [Entry::getField $entry NUMBER] != ""} {
	append out [format "(%s)" [Entry::getField $entry NUMBER]]
    }
    append out [format ", pp.%s" [Entry::getField $entry PAGES]]
    append out [format ", %s" [Entry::getField $entry PDATE]]
    return [Basic::wrapString $out]
}

proc Memo::header { } {
    set s  "MEMO Literature Database\n"
    append s [format "Generated : %s\n\n" [Basic::getDate] ]
    return $s
}

proc Memo::footer { } {
    return ""
}

proc Memo::writeFile { fname } {
    global outputSelected
    set fp [open $fname "w"]

    puts $fp [header]
    foreach entry  $Db::dbList {
	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    puts $fp [formatEntry $entry]
	    puts $fp ""
	}
    }
    puts $fp [footer]    
    close $fp
}

