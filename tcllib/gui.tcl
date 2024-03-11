package provide Gui 1.0

package require Control 1.0

namespace eval Gui {
    namespace export create \
    	updateFilename \
    	updateSelection \
	updateList 
    variable mainWindowHeight 20
    variable mainWindowBgColor
    variable mainWindowFgColor
    variable windowFgColor \#000000
    variable windowBgColor \#e0e0e0
    variable mainWindowBgColor $windowBgColor
    variable entryWindowBgColor $windowBgColor
    variable mainWindowFgColor $windowFgColor
    variable entryWindowFgColor $windowFgColor
    variable hscrollFlag 0
    variable entryWindowHeight 25
}

proc Gui::createMenuBar { } {
    menu .menu

    menu .menu.file
    .menu add cascade -label "Database"  -menu .menu.file -underline 0
    .menu.file add command \
	-label "New" \
	-command "newIlf "
    .menu.file add command  \
	-label "Open..." \
	-command "Control::openIlf " \
	-accelerator "Ctrl+O"
	bind . <Control-o> { .menu.file invoke "Open..." }
    .menu.file add command \
	-label "Merge..." \
	-command "Control::mergeIlf "
    .menu.file add command \
	-label "Save" \
	-command "Control::saveIlf " \
	-accelerator "Ctrl+S"
	bind . <Control-s> { .menu.file invoke "Save" }
    .menu.file add command \
	-label "Save As..." \
	-command "Control::saveAsIlf"
    .menu.file add separator
    .menu.file add command \
	-label "Import Nlm"  \
	-command "Control::importNlm "

    menu .menu.file.export
    .menu.file add cascade \
	-label "Export" -menu .menu.file.export
	.menu.file.export add command -label "Options..." \
		-command { exportOptionsDialog }
	.menu.file.export add separator
	.menu.file.export add command \
	    -label "BibTeX" \
	    -command "Control::export BibTeX"
	.menu.file.export add command \
	    -label "TeX" \
	    -command "Control::export TeX"
	.menu.file.export add command \
	    -label "CSV" \
	    -command "Control::export Csv"
	.menu.file.export add command \
	    -label "Html"  \
	    -command "Control::export Html"
	.menu.file.export add command \
	    -label "Ilf" \
	    -command "Control::export Ilf"
	.menu.file.export add command \
	    -label "Memo"  \
	    -command "Control::export Memo"
	.menu.file.export add command \
	    -label "Rtf"  \
	    -command "Control::export Rtf"

    .menu.file add separator
    .menu.file add command \
	-label "Quit"  \
	-command  { if [reallyContinue Quit] exit } \
	-accelerator Ctrl+Q
	bind . <Control-q> { .menu.file invoke "Quit" }


    menu .menu.edit
    .menu add cascade  \
	-label "Entry" -menu .menu.edit -underline 0
	
    menu .menu.edit.new
    .menu.edit add cascade \
    	-label "New" -menu .menu.edit.new
	.menu.edit.new add command \
	    -label "Article" \
	    -command "newRecord article"
	.menu.edit.new add command \
	    -label "Book" \
	    -command "newRecord book"
	.menu.edit.new add command \
	    -label "in Book" \
	    -command "newRecord inbook"
	.menu.edit.new add command \
	    -label "in Collection" \
	    -command "newRecord incollection"
	.menu.edit.new add command \
	    -label "in Proceedings" \
	    -command "newRecord inproceedings"

#    .menu.edit add command \
#	-label "New"  \
#	-command "newRecord" \
#	-accelerator Ins
#	bind . <Insert> { .menu.edit invoke "New" }
    
    
    .menu.edit add command \
	-label "Delete"  \
	-command "delRecord" \
	-accelerator Del
	bind . <Delete> { .menu.edit invoke "Delete" }
	
    .menu.edit add separator
    #.menu.edit add command \
    #   -label "Edit" -command entryDialog
    #.menu.edit add command \
    #   -label "Deselect" \
    #   -command "selectRecord deselect"
    #.menu.edit add command \
    #   -label "Select" \
    #   -command "selectRecord select"
    .menu.edit add command \
	-label "Select all" \
	-command "selectRecord all"
    .menu.edit add command \
	-label "Deselect all" \
	-command "selectRecord none"\
	-accelerator Esc
    .menu.edit add command \
	-label "Invert Selection" \
	-command "selectRecord invertall"
    .menu.edit add command \
	-label "Select duplicate TEXID" \
	-command "selectDuplicate"
    .menu.edit add separator
    .menu.edit add command \
	-label "Search..." \
	-command "searchDialog " \
	-accelerator "Ctrl+F"
	bind . <Control-f> { .menu.edit invoke "Search..." }


    menu .menu.options
    .menu add cascade \
	-label "Options" -menu .menu.options -underline 0
    #.menu.options add command \
    #    -label "Author List... " \
    #    -command "authorList"
    .menu.options add radio \
	-label "Show all" \
	-variable showAll -value 1\
	-command "updateDisplay " \
	-accelerator Esc
	bind . <Escape> { .menu.options invoke "Show all"; .menu.edit invoke "Deselect all"}

    .menu.options add radio \
	-label "Show selected" \
	-variable showAll -value 0\
	-command "updateDisplay "
    .menu.options add separator

    menu .menu.options.sort
    .menu.options add cascade \
	-label "Sort" -menu .menu.options.sort
	.menu.options.sort add radio \
	    -label "Author" \
	    -variable sortMode -value AUTHOR \
	    -command "updateDisplay "
	.menu.options.sort add radio \
	    -label "Title" \
	    -variable sortMode -value TITLE \
	    -command "updateDisplay "
	.menu.options.sort add radio \
	    -label "Journal" \
	    -variable sortMode -value JOURNAL \
	    -command "updateDisplay "
	.menu.options.sort add radio \
            -label "TeX ID" \
            -variable sortMode -value TEXID \
            -command "updateDisplay "
	.menu.options.sort add radio \
	    -label "ID" \
	    -variable sortMode -value ID \
	    -command "updateDisplay "

    .menu.options add separator
    .menu.options add command -label "Export options..." \
	-command { exportOptionsDialog }


    menu .menu.help
    .menu add cascade \
	-label "Help" -menu .menu.help -underline 0
    .menu.help add command \
	-label "Version..." \
	-command {tk_messageBox -title "Version" -type ok -message [format "\
TclBib Version %s\n\
Copyright 1997-2001 \n\
Frank A. Meineke \n\
University of Leipzig\n\
All rights reserved. \n\n\
This is Tcl %s running on %s."\
    $version [info patchlevel] $tcl_platform(platform)] }

    . configure -menu .menu
    .menu configure -font ansi
    foreach m { edit edit.new file file.export options options.sort help } {
	.menu.$m configure -font ansi -tearoff 0
    }
    
    bind . <Return> { .menu.popup invoke "Edit" }
    bind . <BackSpace> { .menu.options invoke "Show all" }
}


proc Gui::createPopup {} {
    menu .menu.popup
    .menu.popup add command -label "Select" \
	-command "selectRecord select"
    .menu.popup add command -label "Deselect" \
	-command "selectRecord deselect"
    .menu.popup add command -label "Edit" \
	-command Gui::entryDialog
    .menu.popup configure -font ansi -tearoff 0
}

proc Gui::createMainList { w } {
    variable hscrollFlag
    
    frame $w.frame
    pack $w.frame -side top -fill both -expand yes

    scrollbar $w.frame.vscroll -orient vertical \
	-command "$w.frame.list yview"
    scrollbar $w.frame.hscroll -orient horizontal \
	-command "$w.frame.list xview"
    listbox $w.frame.list  -font ansifixed -width 111 -height $Gui::mainWindowHeight\
	-yscroll "$w.frame.vscroll set" -xscroll "$w.frame.hscroll set"\
	-selectmode extended  -bg $Gui::mainWindowBgColor -fg $Gui::mainWindowFgColor
    bind $w.frame.list <Double-1> { .menu.popup invoke "Edit" }
    bind $w.frame.list <Button-2> { Gui::doPopup }
    bind $w.frame.list <Button-3> { Gui::doPopup }


    # Hauptfenster liste
    grid $w.frame.list -in $w.frame \
	-row 0 -column 0 -rowspan 1 -columnspan 1 -sticky news
    # dazugehöriger vertikaler Scrollbar
    grid $w.frame.vscroll \
	-row 0 -column 1 -rowspan 1 -columnspan 1 -sticky news

    # evtl. dazugehöriger horizontaler Scrollbar
    if { $hscrollFlag } {
	grid $w.frame.hscroll \
		-row 1 -column 0 -rowspan 1 -columnspan 1 -sticky news
	grid columnconfig $w.frame 0 -weight 1 -minsize 0
    }

    grid rowconfig    $w.frame 0 -weight 1 -minsize 0
}

# Status Zeile
proc Gui::createStatusLine { w } {
    global status
    set status "ok"
    label $w.status  -relief sunken  -textvariable status  -font ansi \
    	-padx 10 -pady 4
    pack $w.status  -side left
}

proc Gui::entryDialog { { id 0 } } {
    global showAll
    global dbWidget

    if { $id == 0 } {
# Falls kein Eintrag definiert war, sofort zurueck
	set cs [$dbWidget curselection]
	if { $cs == {} } return

	set i [lindex $cs 0 ]
	set id [string range  [$dbWidget get $i] 1 3 ]
    }
    
    set w .text$id
    if { ! [Basic::initDialog $w $id] } {
    	return
    }

# Save und Close Button
    frame $w.buttons
    pack $w.buttons -side bottom -fill x  -pady 2 ;# m
    button $w.buttons.close -text "Cancel" -command "destroy $w"
    button $w.buttons.save \
	-text "Save" \
	-command "entryDialogSave $w 0"
    button $w.buttons.saveclose \
	-text "Save & Close" \
	-command "entryDialogSave $w 1"
    bind $w <Control-s> "$w.buttons.save invoke"
    bind $w <Escape> "$w.buttons.close invoke"
    pack $w.buttons.close $w.buttons.save $w.buttons.saveclose \
	-side left -expand 1

# Text Eingabefeld
    
    text $w.text -relief sunken -bd 2 -yscrollcommand "$w.scroll set" \
	-setgrid 1 -height $Gui::entryWindowHeight -padx 2 -pady 2 -wrap word -font ansifixed \
	-bg $Gui::entryWindowBgColor -fg $Gui::entryWindowFgColor
    scrollbar $w.scroll -command "$w.text yview"
    pack $w.scroll -side right -fill y
    pack $w.text -expand yes -fill both
    $w.text insert 0.0 \
    	[Ilf::formatEntry [ lindex $Db::dbList $Db::dbIndex($id) ] ]

# Focus in den Text
    focus $w.text
# Cursor auf erstes leeres Benutzerfeld stellen
    # Die eckige Klammer enthält ein TAB und ein SPACE
    set p [ $w.text search -regexp {:[A-Z][A-Z]*:[	 ]*$} 0.0]
    if { $p != "" } {
	regsub {(.*)\..*} $p  {\1.end}  p
    } else {
	set p 0.0
    }
    $w.text mark set insert $p
    $w.text config -cursor xterm
}


proc Gui::doPopupConfigure {  } {
    global dbWidget
    set n [ llength [ $dbWidget curselection]]
    if  { $n == 0 } {
	.menu.popup entryconfigure "Select" -state disabled
	.menu.popup entryconfigure "Deselect" -state disabled
    } else {
	.menu.popup entryconfigure "Select" -state normal
	.menu.popup entryconfigure "Deselect" -state normal
    }
    if { $n == 1 } {
	.menu.popup entryconfigure "Edit" -state normal
    } else {
	.menu.popup entryconfigure "Edit" -state disabled
    }
}

proc Gui::doPopup { } {
    doPopupConfigure
    tk_popup .menu.popup [winfo pointerx .] [winfo pointery .]
}

proc Gui::updateFilename { filename } {
    if { $filename == "UNTITLED" } {
	set s disabled
    } else {
	set s normal
    }
    .menu.file entryconfigure "Save" -state $s

    wm title . $filename
}

proc Gui::create { } {
    variable hscrollFlag
    if { ! $hscrollFlag  } {
	wm resizable . 0 1
    }
    createMenuBar
    createPopup
    createMainList ""
    createStatusLine ""
}

proc Gui::updateSelection {  } {
    global dbWidget
    set n [llength [Db::getSelected 1]]

    if { $n == 0 } {
	set s disabled
    } else {
	set s normal
    }
    .menu.edit entryconfigure "Delete" -state $s
}
