package provide Control 1.0
package require Ilf 1.0


namespace eval Control {
     namespace export \
     	setFilename \
	openIlf \
	mergeIlf \
	saveIlf \
	saveAsIlf \
	export
     variable dbFilename
}

proc Control::export { fmt {filename ""} } {
    if { [askExport] == "cancel" } return
    if { $filename == "" } {
	switch $fmt {
	Memo   {set types {{{Text Files} {.txt}}}}
	BibTeX {set types {{{Text Files} {.bib}}}}
	Html   {global tcl_platform
    		if { $tcl_platform(platform) == "unix" } { 
	    	    set types {{{Text Files} {.htm}}}
		} else {
	    	    set types {{{Text Files} {.html}}}
	       }}
	TeX    {set types {{{Text Files} {.tex}}}}
	Csv    {set types {{{Text Files} {.csv}}}}
	Rtf    {set types {{{Text Files} {.rtf}}}}
	Ilf    {set types {{{Text Files} {.ilf}}}}
	}
    	set filename [saveFile $types "Export $fmt"]
    }
    if { $filename != "" } {
    	if { $fmt == "Html"} {
# Für Html muss vorher nach Namen sortiert werden
	    Db::sort AUTHOR
	    ${fmt}::writeFile $filename
	    global sortMode
	    Db::sort $sortMode
	} else {
    	    ${fmt}::writeFile $filename
	}
    }
}

proc Control::setFilename { filename } {
    variable dbFilename
    
    set dbFilename $filename
    Gui::updateFilename $filename
}

proc Control::mergeIlf { { filename ""} } {
    if { $filename == ""  } {
	set types {
	    {{Imise Literatur Format Ilf} {.ilf}}
	}
	set filename [openFile $types "Merge Ilf"]
    }
    if { $filename != ""  } {
	Ilf::readFile $filename
	updateDisplay
    }
}

proc Control::openIlf { {filename ""} } {
    if { ! [reallyContinue Open] } {
    	return
    }
    if { $filename == "" } {
	set types {
	    {{Imise Literatur Format Ilf} {.ilf}}
	}
	set filename [openFile $types "Open Ilf"]
    }
    if { $filename != "" } {
	newIlf
	Ilf::readFile $filename
	updateDisplay
	setFilename $filename
    }
}

proc Control::saveIlf { } {
    variable dbFilename
    global dbHasChanged
    global outputSelected

    set tmp $outputSelected
    set outputSelected 0
    if { [Ilf::writeFile $dbFilename] } {
	set dbHasChanged 0
	set status "ok"
    }
    set outputSelected $tmp
}

proc Control::saveAsIlf { {filename ""} } {
    if { $filename == ""  } {
	set types {
	    {{IMISE Literatur Format Ilf} {.ilf}}
	}
	set filename [saveFile $types "Save Ilf"]
    }
    if { $filename != "" } {
	setFilename $filename
	saveIlf
    }
}

proc Control::importNlm { {filename ""} } {
    global dbHasChanged

    if { $filename == ""  } {
	set types {
	    {{NLM Medline} {.nlm .fcgi}}
	    {{Text Files} {.txt}}
	    {{All Files} {.*}}
	}
	set filename [openFile $types "Import Nlm"]
    }
    if { $filename != ""  } {
	Nlm::readFile $filename
	incr dbHasChanged
	updateDisplay
    }
}

