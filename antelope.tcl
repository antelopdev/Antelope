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
   source toolbox/info_panel.tcl
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
     #ttk::setTheme default

     # global variables
	 set ::enable_draw false

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
     .notemenu add .notemenu.file -text " File " -underline 1 -padding 2
	 grid columnconfigure .notemenu.file {0 1} -weight 1 -uniform 1 -pad 10

	 ttk::button .notemenu.file.open -text "Open" -style Toolbutton -underline 0 -width -1 
     bind . <Alt-o> "focus .notemenu.file.open; .notemenu.file.open invoke"
     grid .notemenu.file.open -padx {0 0} -sticky w
     grid rowconfigure .notemenu.file 1 -weight 1

	 ## Populate options pane
	 ttk::frame .notemenu.options
     .notemenu add .notemenu.options -text " Options " -underline 1 -padding 2

	 ## Populate account profile pane
	 ttk::frame .notemenu.profile
     .notemenu add .notemenu.profile -text " Account Profile " -underline 1 -padding 2

     ## Populate general market pane
	 ttk::frame .notemenu.market
     .notemenu add .notemenu.market -text " General Market " -underline 1 -padding 2

	 ## Populate stock category pane
	 ttk::frame .notemenu.category
     .notemenu add .notemenu.category -text " Stock Category " -underline 1 -padding 2

	 ## Populate short term pane
	 ttk::frame .notemenu.shortterm
     .notemenu add .notemenu.shortterm -text " Short Term " -underline 1 -padding 2

	 ## Populate commodity pane
	 ttk::frame .notemenu.commodity
     .notemenu add .notemenu.commodity -text " Commodity " -underline 1 -padding 2

	 ## Populate help pane
	 ttk::frame .notemenu.help
     .notemenu add .notemenu.help -text " Help " -underline 1 -padding 2
}

proc create_op_panel {} {
     ttk::frame .op_panel 
     pack .op_panel -fill both -expand 1 
     set panels .op_panel

	 # fill the Tool pane
	 ttk::frame $panels.tool 
     ttk::labelframe $panels.tool.title -text "Tools" -labelanchor n
     ttk::button $panels.tool.draw -text "Draw" -command {set ::enable_draw true} -width -1
	 pack $panels.tool.title -fill both -expand 1 
	 pack $panels.tool.draw -padx 2 -pady 5 -in $panels.tool.title

	 ttk::panedwindow $panels.outer -orient horizontal
	 $panels.outer add [ttk::panedwindow $panels.outer.chart -orient vertical -width 1280 -height 1000] -weight 1 
     $panels.outer add [ttk::panedwindow $panels.outer.info  -orient vertical -width 400  -height 1000] -weight 0

	 # fill the Chart pane
     $panels.outer.chart add [ttk::labelframe $panels.outer.chart.title -text "Stock Chart" -labelanchor n]
     ttk::notebook $panels.charts
     pack $panels.charts -side top -fill x -expand 1 -in $panels.outer.chart.title

	 ## Populate daily chart pane
     ttk::frame $panels.charts.daily -padding 2 
     $panels.charts add $panels.charts.daily -text "Daily" -underline 0 -padding 2 
	 init_canvas $panels.daily_sketchpad 1280 1000 $panels.charts.daily

	 ## Populate weekly chart pane
	 ttk::frame $panels.charts.weekly -padding 2 
     $panels.charts add $panels.charts.weekly -text "Weekly" -underline 0 -padding 2
	 init_canvas $panels.weekly_sketchpad 1280 1000 $panels.charts.weekly

	 ## Populate monthly chart pane
	 ttk::frame $panels.charts.monthly -padding 2 
     $panels.charts add $panels.charts.monthly -text "Monthly" -underline 0 -padding 2
	 init_canvas $panels.monthly_sketchpad 1280 1000 $panels.charts.monthly
	 
     # fill the Information pane
     $panels.outer.info add [ttk::labelframe $panels.outer.info.title -text "Information Panel" -labelanchor n]
     init_info_panel $panels.info_panel $panels.outer.info.title

  	 pack $panels.tool  -side left -padx 2 -pady 5 -fill both -expand 0 
  	 pack $panels.outer -side left -padx 2 -pady 5 -fill both -expand 1  
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
