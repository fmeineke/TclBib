package provide Db 1.0

package require Entry 1.0

namespace eval Db {
    namespace export Db\
	getEntry \
	addEntry \
	replaceEntry \
	deleteEntry \
	new \
	invertAllEntries \
	selectAllEntries \
	selectEntry

    # dbList ist eine Liste, die alle Einträge enthält
    variable dbList
    # dbIndex ist ein Array für die Abbildung von id -> Index in dbList
    variable dbIndex
    # Index des sortierbaren Entry Pflichtelementes
    variable sortIndex
    
    proc Db { } { }
}

#every time initialization
proc Db::new { } {
    variable dbList [list]
    variable nextId  aaa
    variable dbIndex
    set dbIndex(0) 0 
    updateIndex
}

#first and once initialization
proc Db::init { } {
    variable sortIndex 1
    new
}


proc Db::getEntry {id} {
    variable dbList
    variable dbIndex
    if { [idExists $id] } {
	return [lindex $dbList $dbIndex($id)]
    }
    puts [format "Es gibt keinen Eintrag mit ID = %s" $id]
    return "error"
}


# Hinzufügen mit Abfrage
# entry ist Varname, da evtl. die ID veraendert wird
proc Db::addEntry { entryVar } {
    variable dbList
    variable dbIndex
    upvar $entryVar entry
    
    set id [Entry::getId $entry]
    set texid [Entry::getField $entry TEXID]

    if { $texid == "" || $texid == "-"} {
	Entry::createTexId entry
    }

    set dbIndex($id) [llength $dbList]
    
    lappend dbList $entry
    
}

# Ersetzen ohne Abfrage
proc Db::replaceEntry { entry } {
    variable dbList
    variable dbIndex
    set id [Entry::getId $entry]

    # Wird jetzt auch nach dem Ändern evtl. neu gesetzt FAM 20.09.2001
    set texid [Entry::getField $entry TEXID]
    if { $texid == "" || $texid == "-"  } {
	Entry::createTexId entry
    }

    set dbList [lreplace $dbList $dbIndex($id) $dbIndex($id) $entry]
}

#bool
proc Db::idExists {id} {
    variable dbIndex
    if { [array names dbIndex $id] != "" } {
	return 1
    }
    return 0
}


proc Db::sort { {fieldName ""} } {
    variable dbList
    variable sortIndex

    if { $fieldName != "" } {
    	set sortIndex [Entry::getFieldIndex $fieldName]
    }

    set dbList [lsort -index $sortIndex $dbList]
    updateIndex
}

proc Db::updateIndex { } {
    variable dbIndex
    variable dbList

    unset dbIndex
    set dbIndex(0) 0
    set i 0
    foreach entry $dbList {
	set dbIndex([Entry::getId $entry]) $i
	incr i
    }
}


proc Db::getSelected { { val 1 } } {
    variable dbList
    set idlist [list]
    foreach entry $dbList {
	if { [Entry::isSelected $entry ] == $val} {
	    lappend idlist [Entry::getId $entry]
	}
    }
    return $idlist
}

proc Db::invertAllEntries { } {
    variable dbList
    set dbtmp [list]
    foreach entry $dbList {
	Entry::setSelected entry [expr ! [Entry::isSelected $entry]]
	lappend dbtmp $entry
    }
    set dbList $dbtmp
}

proc Db::selectAllEntries { { val 1 }} {
    variable dbList
    set dbtmp [list]
    foreach entry $dbList {
	Entry::setSelected entry $val
	lappend dbtmp $entry
    }
    set dbList $dbtmp
}

proc Db::selectEntry { idList { val 1 }} {
    foreach id $idList {
	if { ! [idExists $id] } {
	    puts [format "Es gibt keinen Eintrag ID %s" $id ]
	} else {
	    set entry [getEntry $id]
	    Entry::setSelected entry $val
	    replaceEntry $entry
	}
    }
}


proc Db::deleteEntry { idList } {
    variable dbIndex
    variable dbList
    # Schritt 1: alle zu loeschenden Eintraege leeren / markieren
    foreach id $idList {
	if { ! [idExists $id] } {
	    puts [format "Es gibt keinen Eintrag ID %s" $id ]
	} else {
	    set n $dbIndex($id)
	    set dbList [lreplace $dbList $n $n ""]
# frei werdende id werden nicht mehr verwedendet
#	    if { $id < $nextId } {
#		set idNext $id
#	    }
	}
    }
    # Schritt 2: alle leeren / markierten Listen entfernen
    set n 0
    foreach entry $dbList {
	if { $entry == "" } {
	    set dbList [lreplace $dbList $n $n ]
	} else {
	    incr n
	}
    }
    # Sortieren ist nicht noetig, es wurde ja nur zusammengeschoben
    updateIndex
}

Db::init

