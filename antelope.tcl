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
#lappend auto_path /home/saywhite/antelope/dev/packages

#set release true
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
	 if {$::tcl_platform(os) eq "Linux"} {
 	    tclline
        register_alias
        fileevent stdin readable tclline
        vwait forever
        doExit
     }
}

proc verinfo {} {
	 set systemTime [clock seconds]
	 puts ">> +++ \033\[1;93mAntelope Studio\033\[0m +++"
	 puts ">> +++ \033\[1;91mVersion 0.1\033\[0m | Advanced Analyze System for Individual Inverstors | [clock format $systemTime -format {%D %H:%M:%S}]"
	 puts ">> +++ Machine: $::tcl_platform(machine) | OS: $::tcl_platform(os) $::tcl_platform(osVersion) | Platform: $::tcl_platform(platform)"
     if {$::tcl_platform(os) eq "Linux"} {puts ">> +++ Terminal enhancement feature is enabled."}
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

proc open_analyzer {} {
     package require Tk
#     package require BWidget

	 global globalFont
	 set globalFont [list -family system -size 9]

	 # Window title
     wm title . "Antelope Studio"

	 # Menu Bar Frame
	 frame .mbar -borderwidth 1 -relief raised 
	 pack .mbar -fill x -side top
	 topmenu_create .mbar left "File"            "Open Exit"
	 topmenu_create .mbar left "Options"         "Open Exit"
	 topmenu_create .mbar left "Account Profile" "Open Exit"
	 topmenu_create .mbar left "General Market"  "Open Exit"
	 topmenu_create .mbar left "Stock Category"  "Open Exit"
	 topmenu_create .mbar left "Short Term"      "Open Exit"
	 topmenu_create .mbar left "Commodity"       "Open Exit"
	 topmenu_create .mbar left "Manual"          "Open Exit"

	 # 2nd level menu bar
     frame .style -borderwidth 1 -relief sunken -relief flat
	 pack .style -fill x
	 label .style.readout -text "x: 0.00 y: 0.00" -font "$globalFont" 
	 pack .style.readout -side right

	 cmenu_create .style.color "Color" {set ::color}
     pack .style.color -side left  -ipadx 18 -ipady 2

     cmenu_create .style.bg "Background" {.sketchpad configure -bg}
	 pack .style.bg -side left  -ipadx 18 -ipady 2

     # Info Panel Frame
	 frame .infopanel -highlightthickness 0 -borderwidth 1 -relief flat -width 250 -bg white  

	 # Tool Panel
	 frame .toolpanel -highlightthickness 0 -borderwidth 1 -relief groove -width 40 -bg white  

	 pack  .infopanel .toolpanel -fill y -side left 

	 # Canvas
	 init_canvas .sketchpad 1280 900
     set ::color "black"

	 # display pen location
	 bind .sketchpad <Motion> {sketch_coords %x %y; drawMarker .sketchpad  %x %y}
     bind .sketchpad <ButtonPress-1> {sketch_box_add %x %y}
	 bind .sketchpad <B1-Motion>     {sketch_box_add %x %y}
}

# First Level Menu Bar
proc topmenu_create {parent side item {options ""}} {
	 global globalFont
	 set text $item
	 set item [string tolower $item]
	 menubutton ${parent}.${item} -text $text -font "$globalFont" -underline 0 -menu ${parent}.${item}.m
	 pack ${parent}.${item} -side $side -ipadx 18 -ipady 4
	 menu ${parent}.${item}.m -tearoff 0
	 foreach option $options {
		  ${parent}.${item}.m add command -label $option -underline 0 -font "$globalFont"
     }
}

# Secondary Menu

# Color Menu
proc cmenu_create {win title cmd} {
	 global globalFont
	 menubutton $win -text $title -font "$globalFont" -menu $win.m
	 menu $win.m
	 $win.m add command -label "Red"   -font "$globalFont" -command "$cmd red"
 	 $win.m add command -label "Blue"  -font "$globalFont" -command "$cmd blue"
	 $win.m add command -label "White" -font "$globalFont" -command "$cmd white"
	 $win.m add command -label "Black" -font "$globalFont" -command "$cmd black"
}

proc sketch_coords {x y} {
	 global globalFont
     set size [winfo fpixels .sketchpad 1i]
   	 set x [expr $x/$size]
	 set y [expr $y/$size]
     .style.readout configure -text [format "x: %6.2fi  y: %6.2fi" $x $y] -font "$globalFont" 
}

proc sketch_box_add {x y} {
	 set x0 [expr $x-1]
	 set x1 [expr $x+1]
	 set y0 [expr $y-1]
	 set y1 [expr $y+1]
	 .sketchpad create rectangle $x0 $y0 $x1 $y1 -outline "" -fill $::color
}

proc draw_stock {} {
     
}

init_antelope
