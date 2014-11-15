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
     # Variables
     set current_date [clock format [clock seconds] -format {%Y %m %d}]
     set ::date_year  [lindex $current_date 0]
     set ::date_month [lindex $current_date 1]
     set ::date_day   [lindex $current_date 2]

 	 package require Tk

     wm withdraw .

     catch {destroy .antelope}
	 toplevel .antelope 

	 # set scheme/theme depending on platform
     if {[regexp "Linux" $::tcl_platform(os)]} {
  	    ttk::setTheme clam
     } elseif {[regexp "Windows" $::tcl_platform(os)]} {
  	    ttk::setTheme xpnative
     } else {
       	ttk::setTheme aqua
     }
	 ttk::style configure Tab -focuscolor [ttk::style configure . -background]

     # global variables
	 set ::enable_draw false

	 # set window title
	 wm title .antelope "Antelope Studio"

	 # create notebook style menu bar
	 create_notemenu .antelope

     # create nested operation panel
     create_op_panel .antelope

	 .antelope.notemenu select 2
}

proc create_notemenu {w} {
	 # Notebook menubar
     ttk::notebook $w.notemenu
     ttk::notebook::enableTraversal $w.notemenu
	 pack $w.notemenu -side top -fill x -expand 1 -padx 0 -pady 0

	 ## Populate file menu
     ttk::frame $w.notemenu.file -padding 2 
     $w.notemenu add $w.notemenu.file -text "  File  " -underline 2 -padding 2
	 grid columnconfigure $w.notemenu.file {0 1 2 3} -pad 10
	     # load session
	     ttk::button $w.notemenu.file.load -text "Load Session" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-l> "focus $w.notemenu.file.load; $w.notemenu.file.load invoke; $w.op_panel.charts select 1"
         # save session
	     ttk::button $w.notemenu.file.save -text "Save Session" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-s> "focus $w.notemenu.file.save; $w.notemenu.file.save invoke"
         # data source management
	     ttk::button $w.notemenu.file.data -text "Data Source" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-d> "focus $w.notemenu.file.data; $w.notemenu.file.data invoke"
		 # print chart/information
	     ttk::button $w.notemenu.file.print -text "Print Info" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-p> "focus $w.notemenu.file.print; $w.notemenu.file.print invoke"
     grid $w.notemenu.file.load $w.notemenu.file.save $w.notemenu.file.data $w.notemenu.file.print -padx {0 0} -sticky w

	 ## Populate options pane
	 ttk::frame $w.notemenu.options
     $w.notemenu add $w.notemenu.options -text "  Options  " -underline 2 -padding 2
	 grid columnconfigure $w.notemenu.options {0} -pad 10
	     # preference
	     ttk::button $w.notemenu.options.prefs -text "Preference" -style Toolbutton -underline 0 -width -1 -command "$w.op_panel.charts select 2"
         bind . <Control-p> "focus $w.notemenu.options.prefs; $w.notemenu.options.prefs invoke; "
     grid $w.notemenu.options.prefs -padx {0 0} -sticky w

	 ## Populate account profile pane
	 ttk::frame $w.notemenu.profile
     $w.notemenu add $w.notemenu.profile -text "  Account Profile  " -underline 2 -padding 2
	 grid columnconfigure $w.notemenu.profile {0 1 2} -pad 10
	     # Tacking
	     ttk::button $w.notemenu.profile.track -text "Tracking" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-l> "focus $w.notemenu.profile.track; $w.notemenu.profile.track invoke; $w.op_panel.charts select 1"
         # Strategy
	     ttk::button $w.notemenu.profile.strategy -text "Strategy" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-s> "focus $w.notemenu.profile.strategy; $w.notemenu.profile.strategy invoke"
     grid $w.notemenu.profile.track $w.notemenu.profile.strategy -padx {0 0} -sticky w

     ## Populate general market pane
	 ttk::frame $w.notemenu.market
     $w.notemenu add $w.notemenu.market -text "  Market Trends " -underline 2 -padding 2
	 grid columnconfigure $w.notemenu.market {0 1 2} -pad 10
	     # General Market
	     ttk::button $w.notemenu.market.general -text "General Market" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-l> "focus $w.notemenu.market.general; $w.notemenu.market.general invoke; $w.op_panel.charts select 1"
         # Sectors & Industry groups
	     ttk::button $w.notemenu.market.sector -text "Sectors & Industry Groups" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-s> "focus $w.notemenu.market.sector; $w.notemenu.market.sector invoke"
	     # Institution Sponsor
	     ttk::button $w.notemenu.market.sponsor -text "Institution" -style Toolbutton -underline 0 -width -1 
         bind $w <Control-l> "focus $w.notemenu.market.sponsor; $w.notemenu.market.sponsor invoke; $w.op_panel.charts select 1"
     grid $w.notemenu.market.general $w.notemenu.market.sector $w.notemenu.market.sponsor -padx {0 0} -sticky w

	 ## Populate Intraday trading pne
	 ttk::frame $w.notemenu.intraday
     $w.notemenu add $w.notemenu.intraday -text "  Intraday  " -underline 2 -padding 2

	 ## Populate commodity pane
	 ttk::frame $w.notemenu.future
     $w.notemenu add $w.notemenu.future -text "  Future  " -underline 2 -padding 2

	 ## Populate help pane
	 ttk::frame $w.notemenu.manual
     $w.notemenu add $w.notemenu.manual -text "  Manual  " -underline 2 -padding 2
}

proc create_op_panel {w} {
     ttk::frame $w.op_panel 
     pack $w.op_panel -fill both -expand 1 
     set panels $w.op_panel

	 # fill the Tool pane
	 ttk::frame $panels.tool 
     ttk::labelframe $panels.tool.title -text "| Utils |" -labelanchor n
     ttk::button $panels.tool.draw -text "D" -command {set ::enable_draw true} -width -1
	 pack $panels.tool.title -fill both -expand 1 
	 pack $panels.tool.draw -padx 2 -pady 5 -in $panels.tool.title

	 ttk::panedwindow $panels.outer -orient horizontal
	 $panels.outer add [ttk::panedwindow $panels.outer.main -orient vertical -width 1280 -height 1000] -weight 1 
     $panels.outer add [ttk::panedwindow $panels.outer.info  -orient vertical -width 400  -height 1000] -weight 0

	 # fill the main pane
     $panels.outer.main add [ttk::labelframe $panels.outer.main.title -text "| Report & Chart |" -labelanchor n]
     ttk::notebook $panels.main
     pack $panels.main -side top -fill x -expand 1 -in $panels.outer.main.title

	 ## Chart pane
     ttk::frame $panels.main.chart -padding 2 
     $panels.main add $panels.main.chart -text " Chart " -underline 1 -padding 2 
	 init_canvas $panels.sketchpad 1280 1000 $panels.main.chart

     # fill the Information pane
     $panels.outer.info add [ttk::labelframe $panels.outer.info.title -text "| Information Panel |" -labelanchor n]
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
