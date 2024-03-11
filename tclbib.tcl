#!/bin/sh
# the next line restarts using wish \
exec wish "$0" "$@"

lappend auto_path [file dirname [info script]]/tcllib


package require Control 1.0
package require Gui 1.0
package require Db 1.0
package require Ilf 1.0
package require Basic 1.0
package require Nlm 1.0
package require Memo 1.0
package require Html 1.0
package require BibTeX 1.0
package require Csv 1.0
package require TeX 1.0
package require Rtf 1.0

Basic::Basic
namespace import Basic::*
#namespace import Basic::busy Basic::openFile Basic::saveFile

font create ansi -family Helvetica -size 10 -weight bold
font create ansifixed -family Courier -size 10 -weight normal

# Control::
set wrapMode 0
set sortMode AUTHOR
set outputTeXId 0
set outputSelected 1
# Achtung: dieses Datum wird im Makefile auf das aktuelle Datum gesetzt 
set version "2001-01-26"

if { $tcl_platform(platform) == "unix" } {
    set defpath [pwd]
    set rcfile ~/.tclbibrc
    set tmpFile /tmp/ilf.tmp
} else {
    set defpath .
    set rcfile "E:/tclbib.ini"
    set tmpFile "C:/ilf.tmp"

    font configure ansi -family Helvetica -size 9 -weight normal
    font configure ansifixed -family Courier -size 9 -weight normal
}


set showAll 1
set dbWidget 0
set dbHasChanged 0
set lineNumber -1

# lokales resource file deaktiviert
#if [ file exists $rcfile ] {
#    source $rcfile
#}



proc reallyContinue { a } {
    global dbHasChanged

    if { ! $dbHasChanged }  {
	return 1
    }
    set r [tk_messageBox \
	-message [format "You will loose your %d changes !\nReally %s?" \
	    $dbHasChanged $a ] \
	-type yesno -icon warning]
    if { $r } {
    	return 1
    }
    return 0
}


# Convenience Routinen


proc arr2list { arrVar } {
    upvar $arrVar arr
    set l [list]
    set searchId [array startsearch arr]
    while { [array anymore arr $searchId] } {
	set e [array nextelement arr $searchId]
	if { $arr($e) == 1 } {
	    lappend l $e
	}
    }
    array donesearch arr $searchId
    return $l
}

proc searchAll { s1 } {
    global showAll
    set idlist [list]
    set s1 [format "*%s*" [ string tolower $s1 ]]
    global sArr
    set searchFieldList [arr2list sArr]
    foreach entry $Db::dbList {
	if { $showAll || [Entry::isSelected $entry] } {
	    foreach field $searchFieldList {
		set s2 [ string tolower [Entry::getField $entry $field] ]
		if { [string match $s1 $s2] } {
		    lappend idlist [Entry::getId $entry]
		    break
		}
	    }
	}
    }
    Db::selectEntry [Db::getSelected 1] 0
    Db::selectEntry $idlist
    set showAll 0
    updateDisplay
}



proc exportOptionsDialog { } {
    set w .exportDialog
    set searchWord ""
    if { ![Basic::initTransientDialog $w "Export Options"] } {
    	return
    }

    frame $w.whatframe -relief groove -bd 2
    set f $w.whatframe
    checkbutton $f.wrapMode -text "Wrap Lines In Output" -variable wrapMode
    checkbutton $f.texId -text "Include TexID" -variable outputTeXId
    checkbutton $f.sel -text "Selected only" -variable outputSelected
    pack $f.wrapMode $f.texId $f.sel -side top -anchor w
    pack $f -fill x -side top

    set f $w.buttonframe
    frame $f -bd 10
    button $f.help -text Help -command {
	tk_messageBox -message \
"Wrap Lines In Output: sinnvoll, wenn man die Ausgabe direkt ausdrucken möchte.\n\
Include TexID: sinnvoll, wenn man mit bibtex arbeitet.\n\
Selected only: Gesamtliste oder nur die * Auswahl ausgeben?"
	}
    button $f.ok -default active -text Ok -command " destroy $w "
    bind $w <Return> "$f.ok invoke"
    pack $f.help $f.ok -side left -expand 1
    pack $f -fill x -side top
}


proc searchDialog { } {
    set w .searchDialog
    set searchWord ""
    if { ! [Basic::initTransientDialog $w "Search"] } {
    	return
    }

    set f $w.whatframe
    frame $f -relief groove -bd 2

    set n 0
    global sArr
    foreach fieldName [Entry::getSearchFields] {
	set fn [string tolower $fieldName]
	checkbutton $f.$fn -text $fieldName \
	    -variable sArr($fieldName)
	grid configure $f.$fn -in $f -sticky w \
	    -row [expr $n / 3] -column [expr $n % 3]
	incr n
    }
    grid columnconfigure $f [list 0 1 2] -minsize 40
    pack $f
    set f $w.search
    frame $f -relief groove -bd 2
    label $f.text -text "Enter:"
    entry $f.entry -textvariable searchWord
    pack $f.text $f.entry -side left
    pack $f -fill x -side top

    focus $f.entry

    set f $w.buttonframe
    frame $f -bd 10
    button $f.close -text Close -command " destroy $w "
    button $f.help -text Help -command {
	tk_messageBox -message \
"Bei 'Show selected' wird nur innerhalb der selektierten Eintraege gesucht .\
'?' bzw. '\*' stehen fuer 1 bzw. 0-n beliebige Zeichen"
	}
    button $f.ok -default active -text {Search } -command { busy; searchAll $searchWord }
    #bind $w <Return> { searchAll $searchWord ; destroy .searchDialog }
    bind $w <Return> "$f.ok invoke"
    bind $w <Escape> "$f.close invoke"
    pack $f.close $f.help $f.ok -side left -expand 1
    pack $f -fill x -side top
}


proc compRecords { i1 i2 } {
    global fieldNameIndex

    set t1 [lindex [lindex $dbList $i1] $fieldNameIndex(Title) ]
    set t2 [lindex [lindex $dbList $i2] $fieldNameIndex(Title) ]
    set t1 [string tolower $t1]
    set t2 [string tolower $t2]
    regsub -all { [^a-z0-9] } $t1 "" t1
    regsub -all { [^a-z0-9] } $t2 "" t2
    if { [string compare $t1 $t2] != 0} {
	return 1
    }
    return 0
}

proc getListSelection { } {
    global dbWidget
    set idlist [list]
    foreach i [ $dbWidget curselection] {
	lappend idlist [string range [$dbWidget get $i] 1 3 ]
    }
    return $idlist
}

proc selectDuplicate { } {
    global sortMode
    set saveSortMode $sortMode
    Db::sort TEXID
    set prevtexid ""
    set previd ""
    foreach entry $Db::dbList {
        set texid [ Entry::getField $entry TEXID ]
        set id [ Entry::getId $entry ]
	if { $texid == $prevtexid } {
	    Db::selectEntry $id
	    Db::selectEntry $previd
	}
	set previd $id
	set prevtexid $texid
    }
    set sortMode $saveSortMode
    updateDisplay
}

proc selectRecord { cmd } {
    busy
    switch -- $cmd {
    "none"      { Db::selectAllEntries 0}
    "all"       { Db::selectAllEntries 1}
    "select"    { Db::selectEntry [getListSelection] 1}
    "deselect"  { Db::selectEntry [getListSelection] 0}
    "invertall" { Db::invertAllEntries }
    }
    updateDisplay nosort
}


proc delRecord { } {
    set idList [Db::getSelected 1]
    
    foreach id $idList {
	destroy .text$id
    }
    Db::deleteEntry $idList

    updateDisplay nosort
}


proc newRecord { type } {
    global dbWidget
    set entry [Entry::getNew]
    Entry::setField entry AUTHOR ""
    Entry::setField entry TITLE ""
    Entry::setField entry PDATE ""
    Entry::setField entry DOMAIN "M"
    switch -- $type {
    "article"	{
		    Entry::setField entry JOURNAL ""
		    Entry::setField entry NUMBER ""
		    Entry::setField entry PAGES ""
		    Entry::setField entry VOLUME ""
    	    	}
    "book"  	{
		    Entry::setField entry EDITOR ""
		    Entry::setField entry PUBLISHER ""
		    Entry::setField entry PADDRESS ""
		    Entry::setField entry ISBN ""
    	    	}
    "inbook"	{
		    Entry::setField entry PUBLISHER ""
		    Entry::setField entry PADDRESS ""
		    Entry::setField entry EDITOR ""
		    Entry::setField entry PAGES ""
		    Entry::setField entry ISBN ""
    	    	}
    "incollection"	{
		    Entry::setField entry BOOKTITLE ""
		    Entry::setField entry PUBLISHER ""
		    Entry::setField entry PADDRESS ""
		    Entry::setField entry EDITOR ""
		    Entry::setField entry PAGES ""
		    Entry::setField entry ISBN ""
    	    	}
    "inproceedings"	{
		    Entry::setField entry BOOKTITLE ""
		    Entry::setField entry EDITOR ""
		    Entry::setField entry ORGANIZATION ""
		    Entry::setField entry SERIES ""
		    Entry::setField entry PAGES ""
		    Entry::setField entry PUBLISHER ""
		    Entry::setField entry PADDRESS ""
    	    	}
    }
    Entry::setField entry PLACE ""
    Entry::setField entry CONTENT ""
    Entry::setField entry DOI ""
    Entry::setField entry PTYPE $type
    Db::addEntry entry
    
# Hinscrollen
    $dbWidget yview moveto 1
    updateDisplay nosort
# Fenster öffnen
    Gui::entryDialog [ Entry::getId $entry]
}



proc entryDialogSave { w cls} {
    global dbHasChanged
# ID aus dem Fenstertitel holen
    set id [wm title $w]
    set s [$w.text get 1.0 end]
# Eintrag mit **** beenden
    append s "\n****"
    set entry [list]
# Eintrag aktualisieren
    incr dbHasChanged
    Db::replaceEntry [Ilf::scanEntry $s $id]
    updateDisplay
# Fenster schliesen
    if { $cls } {
	destroy $w
    }
}

# wird momentan nicht genutzt FAM 210300
proc authorList { } {
    global dbWidget
    global dbList
    global mainWindowBgColor
    global mainWindowFgColor

    set w .aList
    if { ! [Basic::initDialog $w "Authors"] } return
    frame $w.frame
    pack $w.frame -side top -fill both -expand yes

    scrollbar $w.frame.vscroll -orient vertical \
	-command "$w.frame.list yview"
    listbox $w.frame.list -font ansifixed -width 104 -height 200\
	-yscroll "$w.frame.vscroll set" \
	-selectmode extended -bg $mainWindowBgColor -fg $mainWindowFgColor
    set aWidget $w.frame.list
    $aWidget delete 0 end
}


proc updateDisplay { { sort yes } } {
    global dbWidget
    global sortMode
    global showAll
    global status

    set yl [$dbWidget yview]
    if {$sort == "yes"} {
	Db::sort $sortMode
    }
    $dbWidget delete 0 end
    
    foreach entry $Db::dbList {
	if { $showAll || [Entry::isSelected $entry] } {
	    $dbWidget insert end [Entry::getString $entry]
	}
    }
    
    set s [$dbWidget size]
    if { $s == 1 } {
	set e entry
    } else {
	set e entries
    }
    if { $showAll == 0 } {
	if { $s == 0 } {
	    set status "no entries selected - use \"Show all\""
	} else {
	    set status [format "%d %s selected" $s $e]
	}
    } else {
	set status [format "%d %s" $s $e]
    }

    Gui::updateSelection
    $dbWidget yview moveto [lindex $yl 0]
    busy 0
}



proc warnSaver { } {
    global dbHasChanged

    if { $dbHasChanged > 0 } {
    	if { $dbHasChanged == 1 } {
	    set msg "You have made one change.\nBetter save some time."
	} else {
	    set msg [format "You have made %d changes.\nBetter save some time..." \
	    $dbHasChanged]
	}
	Basic::Warning $msg
    }
    after 600000 warnSaver
}


proc askExport { } {
    global outputSelected
    set n [llength [Db::getSelected 1]]

    if { $n == 0 && $outputSelected } {
#    	set outputSelected 0

	tk_messageBox \
	    -message [format "Export options is \"selected only\".\
		But nothing is selected. \
		So please select some entries first!" ] \
	    -type ok -icon warning
	return cancel
    }
    return ok
}


proc newIlf { } {
    global dbHasChanged

    if { ! [reallyContinue New] } {
    	return
    }

    set dbHasChanged 0

# Alle noch offenen Entry Fenster schliessen
# Frage waeren hier zwecklos..
    foreach w [winfo children .] {
	if { [string match ".text*" $w] } {
	    destroy $w
	}
    }
    Db::new
    updateDisplay nosort
    Control::setFilename UNTITLED
}


###########################################################################
# HIER STARTET DAS PROGRAMM
###########################################################################

foreach field [list AUTHOR TITLE ] {
    set sArr($field) 1
}

Gui::create
set dbWidget .frame.list
newIlf

# Geht nicht unter Win ?
#doEntryConfigure
.menu.edit entryconfigure "Delete" -state disabled

focus .frame.vscroll

if { $argc == 1 } {
    Control::openIlf [lindex $argv 0]
}

if { $argc == 3 } {
    Control::openIlf [lindex $argv 0]
    selectRecord all
    Control::export [lindex $argv 1 ] [ lindex $argv 2 ]
    exit
}


after 600000 warnSaver

###########################################################################
# AB HIER TESTUMGEBUNG
###########################################################################

set test 0

if { $test != 0 } {

    puts [ time [Control::openIlf /home/frank/Literatur/frank.ilf ]]
    #puts [ time [openIlf /usr/local/share/Literatur/imi_arch.ilf ]]
    
    Control::importNlm "testdata/out.nlm"
    set outputSelected 0
    set outputTeXId 1
    #newIlf
    #puts [time [mergeNLM conny.nlm]]
    #newIlf
    #puts [time [mergeNLM conny.nlm]]

    Control::saveAsIlf conny.ilf
    Control::saveIlf
    newIlf
    Control::openIlf conny.ilf
    
    #newIlf
    #openIlf conny.ilf
    ##exportBib conny.bib
    
    Control::export Csv conny.csv
    Control::export Memo conny.txt
    Control::export Html conny.htm
    Control::export Rtf conny.rtf
    Control::export TeX conny.tex
    Control::export BibTeX conny.bib
    exit
}

