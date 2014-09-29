#!/usr/bin/tclsh
#############################################################################
#
# Antelope Studio
#
# Advanced Analyze System for Individual Investor
#
# Revisions:
# Sept 09/21, 2014  initial revision 0.1   last modified by YoungY
#############################################################################

set release false

if {$release} {
   package provide antelope 1.0
   package require toolbox
} else {
   source toolbox/readline.tcl
   source toolbox/canvas_zooming.tcl
}

proc init_antelope {} {
     verinfo
	 if {[regexp "Linux" $::tcl_platform(os)]} {
        puts ">> +++ Terminal enhancement feature is enabled."
        tclline
        register_alias
        fileevent stdin readable tclline
        vwait forever
        doExit
     }
}

proc open_analyzer {} {
     package require Tk

	 # set scheme/theme
     ttk::setTheme clam

	 # set window title
	 wm title . "Antelope Studio"
     
	 # create notebook style menu bar
	 create_notemenu

     # create nested operation panel
     create_op_panel
}

proc create_notemenu {} {
	 # Notebook menubar
     ttk::notebook .notemenu
     ttk::notebook::enableTraversal .notemenu
     pack .notemenu -side top -fill x -expand 1 -padx 0 -pady 0

	 ## Populate file menu
     ttk::frame .notemenu.file -padding 2 
     .notemenu add .notemenu.file -text "File" -underline 0 -padding 2
	 grid columnconfigure .notemenu.file {0 1} -weight 1 -uniform 1 -pad 10

	 ttk::button .notemenu.file.open -text "Open" -underline 0 -width -1 
     bind . <Alt-o> "focus .notemenu.file.open; .notemenu.file.open invoke"
     grid .notemenu.file.open -padx {0 0} -sticky w
     grid rowconfigure .notemenu.file 1 -weight 1

	 ## Populate options pane
	 ttk::frame .notemenu.options
     .notemenu add .notemenu.options -text "Options" -underline 0 -padding 2

	 ## Populate account profile pane
	 ttk::frame .notemenu.profile
     .notemenu add .notemenu.profile -text "Account Profile" -underline 0 -padding 2

     ## Populate general market pane
	 ttk::frame .notemenu.market
     .notemenu add .notemenu.market -text "General Market" -underline 0 -padding 2

	 ## Populate stock category pane
	 ttk::frame .notemenu.category
     .notemenu add .notemenu.category -text "Stock Category" -underline 0 -padding 2

	 ## Populate short term pane
	 ttk::frame .notemenu.shortterm
     .notemenu add .notemenu.shortterm -text "Short Term" -underline 0 -padding 2

	 ## Populate commodity pane
	 ttk::frame .notemenu.commodity
     .notemenu add .notemenu.commodity -text "Commodity" -underline 0 -padding 2

	 ## Populate help pane
	 ttk::frame .notemenu.help
     .notemenu add .notemenu.help -text "Help" -underline 0 -padding 2
}

proc create_op_panel {} {
     ttk::frame .op_panel 
     pack .op_panel -fill both -expand 1 
     set panels .op_panel
     ttk::panedwindow $panels.outer -orient horizontal
	 $panels.outer add [ttk::panedwindow $panels.outer.tool  -orient vertical -width 60   -height 1000] -weight 0
	 $panels.outer add [ttk::panedwindow $panels.outer.chart -orient vertical -width 1280 -height 1000] -weight 1 
     $panels.outer add [ttk::panedwindow $panels.outer.info  -orient vertical -width 400  -height 1000] -weight 0

	 # fill the Tool pane
     $panels.outer.tool add [ttk::labelframe $panels.outer.tool.title  -text "Tools" -labelanchor n]
     ttk::button $panels.outer.tool.draw -text "Draw" -command {freeDraw .op_panel.sketchpad} -width -1
     pack $panels.outer.tool.draw -padx 2 -pady 5 -in $panels.outer.tool.title

	 # fill the Chart pane
     set title [ttk::labelframe $panels.outer.chart.title -text "Stock Chart" -labelanchor n]
     pack $title -fill x  
	 init_canvas $panels.sketchpad 1280 1000 $panels.outer.chart.title
	 
     # fill the Information pane
     $panels.outer.info add [ttk::labelframe $panels.outer.info.title -text "Information Panel" -labelanchor n]
	 text $panels.txt -wrap word -yscroll "$panels.sb set" -width 30 -borderwidth 0
     scrollbar $panels.sb -orient vertical -command "$panels.txt yview"
     pack $panels.sb -side right -fill y -in $panels.outer.info.title
     pack $panels.txt -fill both -expand 1 -in $panels.outer.info.title
     pack $panels.outer -fill both -expand 1 -padx 10 -pady {6 10}
}

proc freeDraw {sketchpad} {
     set ::color "black"
	 # display pen location
     bind $sketchpad <ButtonPress-1> {sketch_box_add .op_panel.sketchpad %x %y}
	 bind $sketchpad <B1-Motion>     {sketch_box_add .op_panel.sketchpad %x %y}
}

proc sketch_box_add {sketchpad x y} {
	 set x0 [expr $x-1]
	 set x1 [expr $x+1]
	 set y0 [expr $y-1]
	 set y1 [expr $y+1]
	 $sketchpad create rectangle $x0 $y0 $x1 $y1 -outline "" -fill $::color
}

proc verinfo {} {
	 set systemTime [clock seconds]
     if {[regexp "Linux" $::tcl_platform(os)] || [regexp "OSX" $::tcl_platform(os)]} {
	     puts ">> +++ \033\[1;93mAntelope Studio\033\[0m +++"
	     puts ">> +++ \033\[1;91mVersion 0.1\033\[0m | Advanced Analyze System for Individual Inverstors | [clock format $systemTime -format {%D %H:%M:%S}]"
	     puts ">> +++ Machine: $::tcl_platform(machine) | OS: $::tcl_platform(os) $::tcl_platform(osVersion) | Platform: $::tcl_platform(platform)"
	 } else {
	     puts ">> +++ Antelope Studio +++"
	     puts ">> +++ Version 0.1 | Advanced Analyze System for Individual Inverstors | [clock format $systemTime -format {%D %H:%M:%S}]"
	     puts ">> +++ Machine: $::tcl_platform(machine) | OS: $::tcl_platform(os) $::tcl_platform(osVersion) | Platform: $::tcl_platform(platform)"
     }
}

proc register_alias {} {
	 #alias oa open_analyzer
     # Custom Commands 
	 alias ll [list ls -ltr]
	 alias g  [list gvim]
}

proc source_opt {file} {
     if {info exists file} {
		 source $file
     }
}

init_antelope
