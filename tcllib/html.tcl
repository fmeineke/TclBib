package provide Html 1.0
package require Basic 1.0
package require Db 1.0

namespace eval Html {
    namespace export writeFile
}

proc Html::formatEntry { entry } {
    global outFields
    set out "<p>"
    append out [format "%s:<br>" [Entry::getField $entry AUTHOR]]
    if { [Entry::getField $entry OTITLE] != ""} {
	append out [format " %s" [Entry::getField $entry OTITLE]]
    } else {
	append out [format " <i>%s</i><br>" [Entry::getField $entry TITLE]]
    }
    append out [format "%s" [Entry::getField $entry JOURNAL]]
    append out [format ", <b>%s</b>" [Entry::getField $entry VOLUME]]
    if { [Entry::getField $entry NUMBER] != ""} {
	append out [format "(%s)" [Entry::getField $entry NUMBER]]
    }
    append out [format ", pp.%s" [Entry::getField $entry PAGES]]
    append out [format ", %s" [Entry::getField $entry PDATE]]
    set place [Entry::getField $entry PLACE]
    if { $place != "" && $place != "-"} {
    	append out [format " \[Standort: %s\]" $place]
    }
    return [Basic::wrapString $out]
}

proc Html::header { } {
    global outputSelected
    set n 0
    foreach entry $Db::dbList {
    	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    incr n
	}
    }
    set s {
<HTML>
<HEAD><TITLE>ILF Literaturliste</TITLE></HEAD>
<BODY BGCOLOR="FFFFFF" TEXT="000000">
<H1 align=center>ILF Literaturliste</H1>
}
    append s [format "<H4 align=center> %s, %s Einträge</H4>" \
    [Basic::getDate] $n ]
    append s {
<HR>
<H2>
<A HREF="#A">A</A> <A HREF="#B">B</A> <A HREF="#C">C</A> <A HREF="#D">D</A>
<A HREF="#E">E</A> <A HREF="#F">F</A> <A HREF="#G">G</A> <A HREF="#H">H</A>
<A HREF="#I">I</A> <A HREF="#J">J</A> <A HREF="#K">K</A> <A HREF="#L">L</A>
<A HREF="#M">M</A> <A HREF="#N">N</A> <A HREF="#O">O</A> <A HREF="#P">P</A>
<A HREF="#Q">Q</A> <A HREF="#R">R</A> <A HREF="#S">S</A> <A HREF="#T">T</A>
<A HREF="#U">U</A> <A HREF="#V">V</A> <A HREF="#W">W</A> <A HREF="#X">X</A>
<A HREF="#Y">Y</A> <A HREF="#Z">Z</A>
</H2>
<HR>
}
    return $s
}

proc Html::footer { } {
    return "</BODY>\n</HTML>"
}

proc Html::writeFile { fname } {
    global outputSelected

    set fp [open $fname "w"]
    set prevletter 0
    puts $fp [header]
    Basic::busyCounter on
    foreach entry $Db::dbList {
	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    #assert Liste ist nach Autoren sortiert
	    #assert Alle Anfangsbuchstaben in [A-Z]
	    set nextletter [string index [Entry::getField $entry AUTHOR] 0]
	    if { $nextletter != $prevletter} {
		set prevletter $nextletter
		puts $fp [format "<A NAME=%s><H2>%s</H2></A>" $nextletter $nextletter]
	    }
	    puts $fp [formatEntry $entry]
    	    Basic::busyCounter incr
	}
    }
    puts $fp [footer]
    Basic::busyCounter off
    close $fp
}
