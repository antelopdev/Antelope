package provide toolbox 1.0

# canvas initialization
proc init_canvas {area area_width area_height enclosure} {
     global xc yc xoffset yoffset scalefactor orig_width orig_height
	 set xc 0
	 set yc 0
	 set xoffset 0.0
	 set yoffset 0.0
	 set scalefactor 1.0
     set orig_width  $area_width
	 set orig_height $area_height

	 set c [canvas $area -highlightthickness 0 -borderwidth 0 -width $area_width -height $area_height -background white] 
	 pack $c -fill both -expand 1 -in $enclosure
	 focus $c

     # Set up event bindings for canvas:
     bind $c <Control-KeyPress-plus>   "scaleItems $c + ; drawMarker $c  %x %y"
     bind $c <Control-KeyPress-minus>  "scaleItems $c - ; drawMarker $c  %x %y"
	 bind $c <Motion>                  "focus      $c   ; drawMarker $c  %x %y"
     bind $c <KeyPress-f>              "resetView  $c   ; drawMarker $c  %x %y"
     bind $c <ButtonPress-1>           "sketch_box_add  $c %x %y"
	 bind $c <B1-Motion>               "sketch_box_add  $c %x %y"

     # MMB move - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)] || [regexp "Windows" $::tcl_platform(os)]} {
    	bind $c <Button-2>                "set xc %x;  set yc %y; drawMarker $c  %x %y" 
        bind $c <B2-Motion>               "moveItems  $c   %x %y; drawMarker $c  %x %y"
     } else {
    	bind $c <Button-3>                "set xc %x;  set yc %y; drawMarker $c  %x %y" 
        bind $c <B3-Motion>               "moveItems  $c   %x %y; drawMarker $c  %x %y"
     }

     # MMB scroll zoom - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)]} {
    	bind $c <Button-4>                "scaleItems $c  1; drawMarker $c  %x %y"
        bind $c <Button-5>                "scaleItems $c -1; drawMarker $c  %x %y"
     } else {
        bind $c <MouseWheel>              "scaleItems $c %D; drawMarker $c  %x %y"
     }

	 # RMB zoom - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)] || [regexp "Windows" $::tcl_platform(os)]} {
	    bind $c <3>                       "zoomMark   $c   %x %y; drawMarker $c  %x %y"
        bind $c <B3-Motion>               "zoomStroke $c   %x %y; drawMarker $c  %x %y"
        bind $c <ButtonRelease-3>         "zoomArea   $c   %x %y; drawMarker $c  %x %y"
     } else {
	    bind $c <2>                       "zoomMark   $c   %x %y; drawMarker $c  %x %y"
        bind $c <B2-Motion>               "zoomStroke $c   %x %y; drawMarker $c  %x %y"
        bind $c <ButtonRelease-2>         "zoomArea   $c   %x %y; drawMarker $c  %x %y"
     }
	 return $c
}

proc drawMarker {c x y} {
     set width  [winfo width $c]
     set height [winfo height $c]
     $c delete verticalMarker
	 $c delete horizontalMarker
	 $c create line $x 0 $x $height -width 1 -dash {,} -fill red -tag verticalMarker
	 $c create line  0 $y $width $y -width 1 -dash {,} -fill red -tag horizontalMarker
}

proc resetView {c} {
	 global orig_width orig_height
     set width  [winfo width $c]
     set height [winfo height $c]
	 set xoffset_orig [expr ($orig_width -$width )/2.0] 
	 set yoffset_orig [expr ($orig_height-$height)/2.0] 
     global xoffset yoffset scalefactor
     $c scale all [expr $orig_width/2.0] [expr $orig_height/2.0] [expr 1.0/$scalefactor] [expr 1.0/$scalefactor]
	 $c move all [expr -$xoffset-$xoffset_orig] [expr -$yoffset-$yoffset_orig] 
	 set xoffset 0.0
	 set yoffset 0.0
	 set scalefactor 1.0
	 set orig_width  $width
	 set orig_height $height
}

proc moveItems {c x y } {
     global xc yc xoffset yoffset scalefactor
     $c move all [expr {$x-$xc}] [expr {$y-$yc}]
	 set xoffset [expr $xoffset + ($x-$xc)/$scalefactor]
	 set yoffset [expr $yoffset + ($y-$yc)/$scalefactor]
     set xc $x
     set yc $y
}

proc scaleItems {c type} {
	 global orig_width orig_height
     set width  [winfo width $c]
     set height [winfo height $c]
 	 set xoffset_orig [expr ($orig_width -$width )/2.0] 
	 set yoffset_orig [expr ($orig_height-$height)/2.0] 
	 global scalefactor
     if {[expr $type > 0]} {
		 set scalefactor [expr $scalefactor*sqrt(2.0)]
         $c scale all [expr $orig_width/2.0] [expr $orig_height/2.0] [expr {sqrt(2.0)}] [expr {sqrt(2.0)}]
     } else {
		 set scalefactor [expr $scalefactor/sqrt(2.0)]
         $c scale all [expr $orig_width/2.0] [expr $orig_height/2.0] [expr {1.0/sqrt(2.0)}] [expr {1.0/sqrt(2.0)}]
     } 
	 $c move all [expr -$xoffset_orig] [expr -$yoffset_orig]
 	 set orig_width  $width
	 set orig_height $height
}

proc zoomMark {c x y} {
    global zoomArea
    set zoomArea(x0) $x
    set zoomArea(y0) $y
    $c create rectangle $x $y $x $y -dash {.} -outline blue -tag zoomArea
}

proc zoomStroke {c x y} {
    global zoomArea
    set zoomArea(x1) $x
    set zoomArea(y1) $y
    $c coords zoomArea $zoomArea(x0) $zoomArea(y0) $zoomArea(x1) $zoomArea(y1)
}

proc zoomArea {c x y} {
    global zoomArea scalefactor xc yc xoffset yoffset 

    #--------------------------------------------------------
    #  Get the final coordinates.
    #  Remove area selection rectangle
    #--------------------------------------------------------
    set zoomArea(x1) $x
    set zoomArea(y1) $y
    $c delete zoomArea

    #--------------------------------------------------------
    #  Check for zero-size area
    #--------------------------------------------------------
    if {($zoomArea(x0)==$zoomArea(x1)) || ($zoomArea(y0)==$zoomArea(y1))} {
        return
    }

    #--------------------------------------------------------
    #  Determine size and center of selected area
    #--------------------------------------------------------
    set areaxlength [expr {abs($zoomArea(x1)-$zoomArea(x0))}]
    set areaylength [expr {abs($zoomArea(y1)-$zoomArea(y0))}]
    set xcenter [expr {($zoomArea(x0)+$zoomArea(x1))/2.0}]
    set ycenter [expr {($zoomArea(y0)+$zoomArea(y1))/2.0}]


    #--------------------------------------------------------
    #  Determine size of current window view
    #  Note that canvas scaling always changes the coordinates
    #  into pixel coordinates, so the size of the current
    #  viewport is always the canvas size in pixels.
    #  Since the canvas may have been resized, ask the
    #  window manager for the canvas dimensions.
    #--------------------------------------------------------
    set width  [winfo width $c]
    set height [winfo height $c]

    #--------------------------------------------------------
    #  Calculate scale factors, and choose smaller
    #--------------------------------------------------------
    set xscale [expr {1.0*$width/$areaxlength}]
    set yscale [expr {1.0*$height/$areaylength}]
    if { $xscale > $yscale } {
        set factor $yscale
    } else {
        set factor $xscale
    }
    set factor [expr $factor*$scalefactor]

    #--------------------------------------------------------
    #  Perform zoom operation
    #--------------------------------------------------------
	set xc [expr ($xcenter-$width /2.0)/$scalefactor-$xoffset]
	set yc [expr ($ycenter-$height/2.0)/$scalefactor-$yoffset]
	resetView $c 
	moveItems $c 0.0 0.0
	$c scale all [expr $width/2.0] [expr $height/2.0] [expr 1.0*$factor] [expr 1.0*$factor]
	set scalefactor $factor
}

proc sketch_box_add {c x y} {
	 set x0 [expr $x-1]
	 set x1 [expr $x+1]
	 set y0 [expr $y-1]
	 set y1 [expr $y+1]
	 if {$::enable_draw} {
	    $c create rectangle $x0 $y0 $x1 $y1 -outline "" -fill "black"
     }  
}


