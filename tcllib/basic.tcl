package provide Basic 1.0

namespace eval Basic {
    namespace export \
	Error\
	Warning\
	formatString\
	getDate\
	openFile\
	saveFile \
	isOpen \
	busy \
	busyCounter \
	Basic
    variable savedStatus
    variable stack [list]
    proc Basic { } { }
}

proc Basic::busy { {f "on" } } {
    global .
    if { $f != "on" } {
	. configure -cursor ""
    } else {
	. configure -cursor watch
    }
}

proc Basic::busyCounter {f} {
    global status
    switch $f {
    "on" { 
    	set status 0
    	busy on
	}
    "off" { 
    	update
    	busy off
	}
    "incr" {
    	incr status
	if { $status % 25 == 0} {
	    update
    	}
	}
    }
}

# Achtung: bug, handelt kein newline im string!
proc Basic::wrapString {s {width 64}} {
    global wrapMode
    if { ! $wrapMode } {
	return $s
    }
    set ret ""
    while { [string length $s] > $width} {
	set s2 [string range $s 0 $width]
	set t [string last " " $s2 ]
	if { $t == -1} {
	    set t $width
	}
	set s2 [string range $s2 0 $t]
	set s2 [string trimright $s2]

	append ret [string range $s2 0 $t]
	append ret "\n\t\t"
	set s [string range $s $t end]
	set s [string trimleft $s]
    }
    append ret $s
    return $ret
}

proc Basic::Error { msg } {
    global lineNumber
    if { $lineNumber != -1} {
	append msg [format "\n(Line %d)" $lineNumber]
    }
    tk_messageBox -title "TclBib Error" -type ok -message $msg
}

proc Basic::Warning { msg } {
    global lineNumber
    if { $lineNumber != -1} {
	append msg [format "\n(Line %d)" $lineNumber]
    }
    tk_messageBox -title "TclBib Warning" -type ok -message $msg
}

proc Basic::getDate { } {
    return [clock format [clock seconds] -format "%d.%m.%Y, %H:%M"]
}

proc Basic::openFile { types {title open }} {
    global defpath
    global tcl_platform
    if { $tcl_platform(platform) == "unix" } {
	set n 0
	foreach t $types {
	    if { [lindex $t 1] == ".*" } {
		set types [lreplace $types $n $n  [ lreplace $t 1 1 "*" ]]
	    }
	    incr n
	}
    }
    set f [tk_getOpenFile \
	    -title $title \
	    -initialdir $defpath \
	    -filetypes $types -defaultextension [lindex [lindex $types 0] 1]]
    if { $f != "" } {
	set defpath [file dirname $f]
    }
    return $f
}

proc Basic::saveFile { types {title save }} {
    global defpath
    set f [tk_getSaveFile \
	    -title $title \
	    -initialdir $defpath \
	    -filetypes $types -defaultextension [lindex [lindex $types 0] 1]]
    if { $f != "" } {
	set defpath [file dirname $f]
    }
    return $f
}

proc Basic::isOpen {w} {
    if { [ winfo exist $w ] } {
	wm deiconify $w
	raise $w
	#focus $w
	return 1
    }
    return 0
}

proc Basic::push { a } {
    variable stack
    lappend stack $a
}

proc Basic::pop { a } {
    variable stack
    upvar $a r
    set r [ lindex $stack end]
    lreplace $stack end end
}

proc Basic::initDialog {w name} {
    if [ isOpen $w ] { 
    	return 0 
    }
    toplevel $w
    wm title $w $name
    return 1
}

proc Basic::initTransientDialog {w name} {
    if [ isOpen $w ] { 
    	return 0 
    }
    toplevel $w
    wm title $w $name
    wm transient $w .
    set x [expr [winfo pointerx .] - 100]
    set y [expr [winfo pointery .] - 100]
    wm geom $w +$x+$y
    return 1
}

