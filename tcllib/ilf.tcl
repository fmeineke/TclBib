package provide Ilf 1.0

package require Basic 1.0


namespace eval Ilf {
    namespace export \
	readEntry readFile writeFile formatEntry
}

proc Ilf::formatEntry { entry } {
    set out ""

    # SELECTED + ID Felder werden weggelassen, drum nur "2 end"
    # keine ID Felder mehr in *.ilf (19.09.2000)    
    foreach field [lrange $entry 2 end ] {
	set fieldName $Entry::fieldIndex([string range $field 0 0 ])
	if { [string length $fieldName] < 6 } {
	    set tab "\t\t"
	} else {
	    set tab "\t"
	}
	set cont [string range $field 1 end ]
	set cont [Basic::wrapString $cont]
	append out [format ":%s:%s%s\n" $fieldName $tab $cont ]
    }
    return $out
}

# Krücke, um Datensatz aus String zu lesen
# hier: Schreibe String in Datei und lese daraus
# es fehlt eine string channelId..
# 
proc Ilf::scanEntry { str id } {
    global tmpFile
    global lineNumber
    
    set lineNumber 0
    set fp [open $tmpFile "w+"]
    puts $fp $str
    seek $fp 0
    catch [readEntry $fp entry $id]
    close $fp
    file delete $tmpFile
    set lineNumber -1
    return $entry
}

proc Ilf::readEntry { fp entryVar { id none }} {
    upvar $entryVar entry
    global lineNumber

    set numberOfValidFields 0
    set entry [Entry::getNew $id]
    set cont ""
    set fieldName ""
    while { ! [eof $fp] } {
	gets $fp inbuffer
#       puts $cont
	incr lineNumber
	set inbuffer [string trimright $inbuffer ]
	# -- hinzugefuegt, 3.6.1999 FAM
	    switch -glob -- $inbuffer {
	    {#*} {
	    }
	    {\*\*\*\**} {
		if { $cont != "" } {
		    Entry::setField entry $fieldName $cont
		}
		return 1
	    }
	    {:*:*} {
		if { $cont != "" } {
		    Entry::setField entry $fieldName $cont
		    set fieldName ""
		    set cont ""
		}
		set cont ""
		set fieldName ""
		set re [subst -nocommands {^:([A-Z-]*):[\t ]*(.*)$}]
		regexp $re $inbuffer dummy fieldName cont
	    #puts [format "<%s>" $fieldName]
	    }
	    default {
		if { $fieldName == "CONTENT" } {
		    append cont "\n" $inbuffer
		} else {
		    if { $cont != "" } {
		    	append cont " " [string trimleft $inbuffer]
		    }
		}
	    }
	}
    }
    if { $cont != "" } {
	Entry::setField entry $fieldName $cont
    }
    return 0
}

proc Ilf::backup { fname } {
    set backupLevel 4
    set rootname [file rootname $fname]
    set i 0
    set target [format "%s.il%d" $rootname $backupLevel]   
    # rename il3 -> il4
    # rename il2 -> il3
    # rename il1 -> il2
    for {set i [expr $backupLevel - 1] } { $i > 0 } {incr i -1} {
	set src [format "%s.il%d" $rootname $i]
	if [file exists $src] {
	    file rename -force $src $target
	}
	set target $src    
    }  
    # rename ilf -> il1
    if [file exists $fname] {
	file rename -force $fname $target
    }
    return 1
}

proc Ilf::header { } {
    global version
    set s "# ILF Literature Database\n"
    append s [format "# Creator   : TclBib, version %s\n" $version]
    append s [format "# Generated : %s\n\n" [Basic::getDate] ]
}

proc Ilf::footer { } {
    return ""
}

proc Ilf::writeFile { fname } {
    global outputSelected

    set n 0
    set tmpname [format "%s.il0" [file rootname $fname]]
    if [catch "open $tmpname \"w\"" fp ] {
	Error [format  "Could not open %s for writing.\nNothing saved." $tmpname ]
	return 0
    }

    puts $fp [header]

    Basic::busyCounter on
    foreach entry  $Db::dbList {
	if { ! $outputSelected || [Entry::isSelected $entry] } {
	    puts -nonewline $fp [formatEntry $entry ]
	    puts $fp {****}
    	    Basic::busyCounter incr
	}
    }
    Basic::busyCounter off
    close $fp
    backup $fname
    # rename il0 -> ilf
    if [catch "file rename -force $tmpname $fname" ]  {
	Basic::Error [format "Could not rename the newly saved database %s to %s" \
	    $tmpname $fname]
	return 0
    }
    return 1
}

proc Ilf::readFile {fname} {
    set fp [open $fname "r"]
    global lineNumber 
    set lineNumber 0
    
    Basic::busyCounter on
    
    # Achtung: Die {} hier dürfen nicht entfallen
    # bei tcl 8.1 gibt es Endlosschleife (dokumentiert, siehe while)
    # bei tcl 8.0 ging es auch ohne
    
    while { [ readEntry $fp entry ] } {
	Db::addEntry entry
    	Basic::busyCounter incr
    }
    Basic::busyCounter off
    
    set lineNumber -1
    close $fp
}

