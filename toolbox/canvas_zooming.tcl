package provide toolbox 1.0

# canvas initialization
proc init_canvas {area area_width area_height enclosure} {
     global xc yc xoffset yoffset scalefactor scalefactor_PR orig_width orig_height pv_ratio h_margin scroll_offset scroll_offset_PR
	 global enable_snap
	 set xc 0
	 set yc 0
	 set xoffset 0.0
	 set yoffset 0.0
	 set scalefactor 1.0
	 set scalefactor_PR 1.0
     set orig_width  $area_width
	 set orig_height $area_height
     set pv_ratio [expr 3.8/5.0]
	 set h_margin 59
     set enable_snap 1
     set ::not_init 0
     set scroll_offset 0.0
     set scroll_offset_PR 0.0

     # place holder
   	 set PH [canvas $area.placeholder -highlightthickness 0 -borderwidth 0 -width [expr $h_margin+1] -height 12 -background white] 
	 #pack $PH -anchor nw -fill none -expand 0 -in $enclosure
     grid $PH -column 0 -row 0 -in $enclosure

	 # Timeline ruler
	 set TR [canvas $area.timeline -highlightthickness 0 -borderwidth 0 -width $area_width -height 12 -background white] 
     grid $TR -column 1 -row 0 -sticky nsew -in $enclosure

	 # Price/Volume line ruler
	 set PR [canvas $area.priceline -highlightthickness 0 -borderwidth 0 -width [expr $h_margin+1] -height [expr $area_height*$pv_ratio] -background white] 
     grid $PR -column 0 -row 1 -sticky nsew -in $enclosure

	 set VR [canvas $area.volumeline -highlightthickness 0 -borderwidth 0 -width [expr $h_margin+1] -height [expr $area_height*(1-$pv_ratio)] -background white] 
     grid $VR -column 0 -row 2 -sticky nsew -in $enclosure

	 # Main canvas
     set PC [canvas $area.pricechart -highlightthickness 0 -borderwidth 0 -width $area_width -height [expr $area_height*$pv_ratio] -background white] 
     grid $PC -column 1 -row 1 -sticky nsew -in $enclosure

     set VC [canvas $area.volumechart -highlightthickness 0 -borderwidth 0 -width $area_width -height [expr $area_height*(1-$pv_ratio)] -background white] 
     grid $VC -column 1 -row 2 -sticky nsew -in $enclosure

	 grid columnconfigure $enclosure 1 -weight 1
     grid rowconfigure    $enclosure "1 2" -weight 1

     # Set up event bindings for canvas:
     bind $PC <Control-KeyPress-plus>   "scaleItems $PC $VC $TR 1 %x %y; drawMarker $PC  %x %y"
     bind $PC <Control-KeyPress-minus>  "scaleItems $PC $VC $TR -1 %x %y; drawMarker $PC  %x %y"
	 bind $PC <Motion>                  "focus      $PC   ; drawMarker $PC  %x %y"
     bind $PC <KeyPress-f>              "resetView  $PC $VC $TR $PR $VR; drawMarker $PC  %x %y"
     bind $PC <ButtonPress-1>           "sketch_box_add  $PC %x %y"
	 bind $PC <B1-Motion>               "sketch_box_add  $PC %x %y"

     # MMB move - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)] || [regexp "Windows" $::tcl_platform(os)]} {
    	bind $PC <Button-2>                "set xc %x;  set yc %y; drawMarker $PC  %x %y" 
        bind $PC <B2-Motion>               "moveItems  $PC $VC $TR $PR %x %y; drawMarker $PC  %x %y"
     } else {
    	bind $PC <Button-3>                "set xc %x;  set yc %y; drawMarker $PC  %x %y" 
        bind $PC <B3-Motion>               "moveItems  $PC $VC $TR $PR %x %y; drawMarker $PC  %x %y"
     }

     # MMB scroll zoom - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)]} {
    	bind $PC <Button-4>                "scaleItems $PC $VC $TR 1 %x %y; drawMarker $PC  %x %y"
        bind $PC <Button-5>                "scaleItems $PC $VC $TR -1 %x %y; drawMarker $PC  %x %y"
    	bind $PR <Button-4>                "scaleItems_PR $PC $PR 1 %x %y"
        bind $PR <Button-5>                "scaleItems_PR $PC $PR -1 %x %y"
     } else {
        bind $PC <MouseWheel>              "scaleItems $PC $VC $TR %D %x %y; drawMarker $PC  %x %y"
     }

	 # RMB zoom - platform dependent
	 if {[regexp "Linux" $::tcl_platform(os)] || [regexp "Windows" $::tcl_platform(os)]} {
	    bind $PC <3>                       "zoomMark   $PC   %x %y; drawMarker $PC  %x %y"
        bind $PC <B3-Motion>               "zoomStroke $PC   %x %y; drawMarker $PC  %x %y"
        bind $PC <ButtonRelease-3>         "zoomArea   $PC $VC $TR $PR $VR %x %y; drawMarker $PC  %x %y"
     } else {
	    bind $PC <2>                       "zoomMark   $PC   %x %y; drawMarker $PC  %x %y"
        bind $PC <B2-Motion>               "zoomStroke $PC   %x %y; drawMarker $PC  %x %y"
        bind $PC <ButtonRelease-2>         "zoomArea   $PC $VC $TR $PR $VR %x %y; drawMarker $PC  %x %y"
     }

   	 bind $PC <Configure> "drawMarker $PC %x %y; onConfig $PC $VC $TR $PR $VR %w %h; "

	 # generate rulers and meshes
	 return [list $PC $VC $TR $PR $VR]
}

proc onConfig {c VC TR PR VR width height} {
     global xoffset yoffset scalefactor scalefactor_PR
	 global orig_width orig_height scroll_offset 
	 if {$::not_init} {
	    set xoffset_orig [expr ($orig_width -$width )/2.0] 
	    set yoffset_orig [expr ($orig_height-$height)/2.0] 
        $c  scale all [expr $width/2.0] [expr $height/2.0] [expr 1.0/$scalefactor] [expr 1.0/$scalefactor_PR]
	    $c  move all  [expr -$xoffset_orig/$scalefactor] [expr -$yoffset_orig/$scalefactor_PR]
        $c  scale all [expr $width/2.0] [expr $height/2.0] [expr $scalefactor] [expr $scalefactor_PR]
     }
	 set orig_width  $width
	 set orig_height $height
     incr ::not_init

	 set xoffset [expr $xoffset-$scroll_offset]
	 TR_bordergen $TR $width; TR_gen $TR $width;
	 PR_bordergen $PR $height; PR_gen $PR $height;
     VR_bordergen $VR $height; VR_gen $VR $height;
	 VC_bordergen $VC $width; 
	 mesh_gen     $c 14.0 $width $height;
   	 set xoffset [expr $xoffset+$scroll_offset]
     drawCross $c $width $height 20131209 96 90 94 
}

proc drawCross {c width height DATE HIGH LOW CLOSE} {
     $c delete Cross
	 set year  2014  ;# year 2014
	 set week  10    ;# 10th week in the year
	 set day   3     ;# 3rd  day in the week 

	 set current_date    [Calc_Quarter -1]
     set current_year    [lindex $current_date 0]
	 set current_quarter [lindex $current_date 1]
     #puts $current_year
     #puts $current_quarter

	 global scalefactor
 	 #set width  [winfo width $c]
     #set height [winfo height $c]

	 set segment [expr 13*14*$scalefactor]
     set week_offset [expr ($current_year-$year)*4*$segment+$current_quarter*$segment-$week*14*$scalefactor]
     #puts [expr ($current_year-$year)*4*$segment]
	 #puts [expr $current_quarter*$segment]
	 #puts [expr -$week*14*$scalefactor]
	 #puts $week_offset

	 set DATE [expr $width/2+$segment-$week_offset]
	 #puts $DATE
	 $c create line [expr $DATE-7] [expr 330] [expr $DATE+7] [expr 330] -width 2 -fill black -capstyle round -tag Cross
	 $c create line [expr $DATE] [expr 300] [expr $DATE] [expr 400] -width 2 -fill black -capstyle round -tag Cross
}

proc drawMarker {c x y} {
     global enable_snap scalefactor
	 set width  [winfo width $c]
     set height [winfo height $c]
     $c delete verticalMarker
	 $c delete horizontalMarker
	 $c delete coordMarker
     if {$enable_snap} {
	    set radius 5.5
	    set cross [$c find overlapping [expr $x-$radius] [expr $y-$radius] [expr $x+$radius] [expr $y+$radius]]
        set snap_x ""
	    set snap_y ""
	    foreach item $cross {
	        if {[$c itemcget $item -tag] == "verticalMeshLine" } {
                #puts [$c itemcget $item -tag]
	       	 set bbox [$c coords $item]
	       	 set snap_x [lindex $bbox 0]
            }
	        if {[$c itemcget $item -tag] == "horizontalMeshLine" } {
                #puts [$c itemcget $item -tag]
	       	 set bbox [$c coords $item]
	       	 set snap_y [lindex $bbox 1]
            }
        }
	    $c delete CrossZone
	    if {$snap_x!=""&&$snap_y!=""} {
	       $c conf -cursor {none}
	       #$c create rectangle [expr $snap_x-$radius] [expr $snap_y-$radius] [expr $snap_x+$radius] [expr $snap_y+$radius] -tag CrossZone
           $c create line [expr ceil($snap_x-$radius-3)] [expr ($snap_y-3)] [expr ($snap_x-3)] [expr ($snap_y-3)] [expr ($snap_x-3)] [expr ceil($snap_y-$radius-3)] -fill blue -tag CrossZone
           $c create line [expr ceil($snap_x+$radius+3)] [expr ($snap_y-3)] [expr ($snap_x+3)] [expr ($snap_y-3)] [expr ($snap_x+3)] [expr ceil($snap_y-$radius-3)] -fill blue -tag CrossZone 
           $c create line [expr ceil($snap_x-$radius-3)] [expr ($snap_y+3)] [expr ($snap_x-3)] [expr ($snap_y+3)] [expr ($snap_x-3)] [expr ceil($snap_y+$radius+3)] -fill blue -tag CrossZone 
           $c create line [expr ceil($snap_x+$radius+3)] [expr ($snap_y+3)] [expr ($snap_x+3)] [expr ($snap_y+3)] [expr ($snap_x+3)] [expr ceil($snap_y+$radius+3)] -fill blue -tag CrossZone 
	       set x $snap_x
	       set y $snap_y
        } else {
	       $c conf -cursor ""
        }
     }
	 $c create line $x 0 $x $height -width 0.1 -fill red -tag verticalMarker
	 $c create line  0 $y $width $y -width 0.1 -fill red -tag horizontalMarker
	 set segment [expr 13*14*$scalefactor]
	 set today_week [GetWeekOfTheYear $::date_year $::date_month $::date_day]
	 set delta_week [expr int(($width/2+$segment-$x)/(14*$scalefactor))]
	 set display_year [expr $::date_year+($today_week-$delta_week)/53]
	 set display_week [expr ($today_week-$delta_week)%53]
     set display [GetDayAndMonthFromWeekInYear $display_year $display_week]
     $c create text [expr $x+10] [expr $y+10] -text [format " @ $display\n \[Price %.1f\] | \[Volume %.1f\]" $x $y] -fill blue -anchor nw -tag coordMarker 
}

proc mesh_gen {c granularity width height {pos_x "[expr $width/2]"}} {
	 set width  [winfo width $c]
     set height [winfo height $c]
	 #set pos_x  [expr $width/2]
	 set pos_y  [expr $height/2]

	 global xoffset yoffset scalefactor scalefactor_PR
	 $c delete verticalMeshLine
	 $c delete horizontalMeshLine
     $c delete todayLine

     # vertical stripes
	 set vsegment    [expr $granularity*$scalefactor]
	 set vamount     [expr int($width/$vsegment)]
	 set vcnt_offset [expr int(floor($xoffset*$scalefactor/$vsegment))]
	 set today_week [GetWeekOfTheYear $::date_year $::date_month $::date_day]
	 set week_offset [expr (13 - $today_week%13)*14*$scalefactor]
	 for {set vcnt [expr -$vamount+$vcnt_offset]} {$vcnt < [expr $vamount+$vcnt_offset]} {incr vcnt} {
	     set x [expr $week_offset+$xoffset*$scalefactor+$pos_x-$vcnt*$vsegment]
		 if {![expr $vcnt%13]} {
	        $c create line $x 0 $x $height -width 1 -fill #cccccc -tag verticalMeshLine
	     } else {
            $c create line $x 0 $x $height -width 1 -dash {.} -fill #cccccc -tag verticalMeshLine
	     }
		 if {[expr $vcnt==-13]} {
			$c create line [expr $x-$week_offset] 0 [expr $x-$week_offset] $height -width 1 -fill green -tag todayLine
	     } 
     }
	 # horizontal stripes
	 set hsegment    [expr $granularity*$scalefactor_PR]
	 set hamount     [expr int($height/$hsegment)]
	 set hcnt_offset [expr int(floor($yoffset*$scalefactor_PR/$hsegment))]
	 for {set hcnt [expr -$hamount+$hcnt_offset]} {$hcnt < [expr $hamount+$hcnt_offset]} {incr hcnt} {
		 set y [expr $yoffset*$scalefactor_PR+$pos_y-($hcnt)*$hsegment]
         if {![expr $hcnt%5]} {
	        $c create line 0 $y $width $y -width 1 -dash {.} -fill #cccccc -tag horizontalMeshLine
		 } else {
	        $c create line 0 $y $width $y -width 1 -dash {.} -fill #cccccc -tag horizontalMeshLine
	     }
     }
	 $c lower verticalMeshLine
	 $c lower horizontalMeshLine
}

proc TR_bordergen {c width} {
     $c delete TR_Border
	 $c create line 0 11 0 0 $width 0 $width 11 -width 1 -fill black -tag TR_Border
     $c create line 0 11 $width 11 -width 1 -fill black -tag TR_Border
}

proc TR_gen {c width {pos "[expr $width/2]"}} {
	 global xoffset scalefactor
	 $c delete TimeLine
	 set segment    [expr 13*14*$scalefactor]
	 set amount     [expr int($width/$segment)]
	 set cnt_offset [expr int(floor($xoffset*$scalefactor/$segment))]
	 set today_week [GetWeekOfTheYear $::date_year $::date_month $::date_day]
     set week_offset [expr (13 - $today_week%13)*14*$scalefactor]
    # set cnt_offset 0 
	 for {set cnt [expr -$amount+$cnt_offset]} {$cnt < [expr $amount+$cnt_offset]} {incr cnt} {
         $c create line [expr $week_offset+$xoffset*$scalefactor+$pos-$cnt*$segment] 0 [expr $week_offset+$xoffset*$scalefactor+$pos-$cnt*$segment] 11 -width 1 -fill blue -tag TimeLine
		 $c create line [expr $week_offset+$xoffset*$scalefactor+$pos-$cnt*$segment-$segment] 0 [expr $week_offset+$xoffset*$scalefactor+$pos-$cnt*$segment-$segment] 11 -width 1 -fill blue -tag TimeLine
		 $c create text [expr $week_offset+$xoffset*$scalefactor+$pos-$cnt*$segment-$segment/2.0] 5.5 -text [Calc_Quarter $cnt] -anchor center -font {"" 8} -tag TimeLine
     }
} 

proc PR_bordergen {c height} {
     global h_margin
	 $c delete PR_border
	 $c create line $h_margin 0 0 0 0 [expr $height] $h_margin [expr $height] -width 1 -fill black -tag PR_border
	 $c create line $h_margin 0 $h_margin [expr $height] -width 1 -fill black -tag PR_border
     $c create text [expr $h_margin/2.0] 7 -text "Price" -anchor center -fill blue -font {"" 9} -tag PR_border
	 $c create line 0 14 $h_margin 14 -width 1 -fill blue -tag PR_border
}

proc VR_bordergen {c height} {
     global pv_ratio h_margin
     $c delete VR_border
	 $c create line $h_margin 0 0 0 0 [expr $height/$pv_ratio*(1-$pv_ratio)] $h_margin [expr $height/$pv_ratio*(1-$pv_ratio)] -width 1 -fill black -tag VR_border
 	 $c create line $h_margin 0 $h_margin [expr $height/$pv_ratio*(1-$pv_ratio)] -width 1 -fill black -tag VR_border
     $c create text [expr $h_margin/2.0] 7 -text "Volume" -anchor center -fill blue -font {"" 9} -tag VR_border
	 $c create line 0 14 $h_margin 14 -width 1 -fill blue -tag VR_border
}

proc VC_bordergen {c width} {
     $c delete VC_border
	 $c create line 0 0 $width 0 -width 1 -fill black -tag VC_border
}

# Price Ruler can be scaled and moved vertically
proc PR_gen {c height} {
     global h_margin
	 global yoffset
	 global scalefactor_PR
	 #disable scale for now
	 set scalefactor $scalefactor_PR 
	 set price_pos [expr $height/2]

	 $c delete PriceLine
	 set segment    [expr 100.0*$scalefactor]
     set delta      [expr $segment/10.0]
	 set amount     [expr int($height/$segment)]
	 set cnt_offset [expr int(floor($yoffset*$scalefactor/$segment))]
	 for {set cnt [expr -$amount+$cnt_offset]} {$cnt < [expr $amount+$cnt_offset]} {incr cnt} {
		 set y_pos [expr $yoffset*$scalefactor+$price_pos-($cnt+1)*$segment]
         if {[expr $y_pos>16]} {
		    $c create line [expr $h_margin*2.0/3.0 + 5] $y_pos $h_margin $y_pos -width 1 -fill blue -tag PriceLine
		    $c create text [expr $h_margin*2.0/3.0] $y_pos -text [expr 100+10*$cnt] -anchor e -font {"" 8} -tag PriceLine
		 }
		 for {set i 0} {$i<10} {incr i} {
		    set temp [expr $y_pos+$delta*$i]
			if {[expr $temp>16]} {
			    $c create line [expr $h_margin*2.0/3.0 + 12] $temp $h_margin $temp -width 1 -fill black -tag PriceLine
			}
         }
     }
}

# Volume Ruler can only be scaled vertically
proc VR_gen {c height} {
     global pv_ratio h_margin
	 global yoffset 

	 set scalefactor 1.0 

	 set height [expr $height/$pv_ratio*(1-$pv_ratio)]

	 set volume_pos 300
	 $c delete VolumeLine
	 set segment    [expr 100.0*$scalefactor]
     set delta      [expr $segment/2.0]
	 set amount     [expr int($height/$segment)]
	 set cnt_offset [expr int(floor($yoffset*$scalefactor/$segment))]
	 for {set cnt [expr -$amount+$cnt_offset]} {$cnt < [expr $amount+$cnt_offset]} {incr cnt} {
		 set y_pos [expr $yoffset*$scalefactor+$volume_pos-$cnt*$segment-$segment/2.0]
		 if {[expr $y_pos>16]} {
			$c create line [expr $h_margin*2.0/3.0 + 5] $y_pos $h_margin $y_pos -width 1 -fill blue -tag VolumeLine
		    $c create text [expr $h_margin*2.0/3.0] $y_pos -text [expr 5000+100*$cnt] -anchor e -font {"" 8} -tag VolumeLine
		 }
		 for {set i 0} {$i<2} {incr i} {
		    set temp [expr $y_pos+$delta*$i]
			if {[expr $temp>16]} {
			    $c create line [expr $h_margin*2.0/3.0 + 12] $temp $h_margin $temp -width 1 -fill black -tag VolumeLine
			}
         }
     }
}

proc Calc_Quarter {cnt} {
	 set cnt [expr 3*($cnt+1)]
	 set quarter ""
	 set overtime [expr $::date_month-1-$cnt]
     set year [expr $::date_year+$overtime/12]
     set month [expr $overtime%12]

	 if {[expr $month >=3 && $month <6]} {
	    set quarter "2"
     } elseif {[expr $month >=6 && $month <9]} {
        set quarter "3"
     } elseif {[expr $month >=9 && $month <12]} {
        set quarter "4"
     } else {
        set quarter "1"
     }
	 return "$year $quarter"
}

proc resetView {c VC TR PR VR} {
	 global orig_width orig_height scroll_offset scroll_offset_PR
     set width  [winfo width $c]
     set height [winfo height $c]
	 set xoffset_orig [expr ($orig_width -$width )/2.0] 
	 set yoffset_orig [expr ($orig_height-$height)/2.0] 
     global xoffset yoffset scalefactor scalefactor_PR
     $c  scale all [expr $width/2.0] [expr $height/2.0] [expr 1.0/$scalefactor] [expr 1.0/$scalefactor_PR]
	 $c  move all  [expr -$xoffset+$scroll_offset] [expr -$yoffset+$scroll_offset_PR] 
	 set xoffset 0.0
	 set yoffset 0.0
	 set scroll_offset 0.0
	 set scroll_offset_PR 0.0
	 set scalefactor 1.0
	 set scalefactor_PR 1.0
	 set orig_width  $width
	 set orig_height $height
     TR_gen $TR $width 
     PR_gen $PR $height
     VR_gen $VR $height
	 mesh_gen $c 14.0 $width $height
}

proc moveItems {c VC TR PR x y } {
     set width [winfo width $c]
	 set height [winfo height $c]
	 global xc yc xoffset yoffset scroll_offset scalefactor scalefactor_PR 
	 $c move all [expr {$x-$xc}] [expr {$y-$yc}]
	 set xoffset [expr $xoffset + ($x-$xc)/$scalefactor]
	 set yoffset [expr $yoffset + ($y-$yc)/$scalefactor_PR]
	 set xc $x
     set yc $y
	 set xoffset [expr $xoffset-$scroll_offset]
	 TR_gen $TR $width 
     PR_gen $PR $height
	 mesh_gen $c 14.0 $width $height
  	 set xoffset [expr $xoffset+$scroll_offset]
}

proc scaleItems {c VC TR type pos_x pos_y} {
	 global orig_width orig_height xoffset yoffset scroll_offset 
     set width  [winfo width $c]
     set height [winfo height $c]
 	 set xoffset_orig [expr ($orig_width -$width )/2.0] 
	 set yoffset_orig [expr ($orig_height-$height)/2.0] 
	 global scalefactor
	 if {[expr $type > 0]} {
         if {[expr $scalefactor <= pow(sqrt(2.0),6)]} {
           	 set scroll_offset [expr $scroll_offset+($pos_x-$width/2.0)/$scalefactor*(1-sqrt(2.0)/2.0)]
			 set scalefactor [expr $scalefactor*sqrt(2.0)]
 	         $c scale all [expr $pos_x] [expr $height/2.0] [expr 1.0*sqrt(2.0)] 1.0
         }
       } else {
	     if {[expr $scalefactor >= sqrt(2.0)]} {
          	 set scroll_offset [expr $scroll_offset+($pos_x-$width/2.0)/$scalefactor*(1-sqrt(2.0))]
			 set scalefactor [expr $scalefactor/sqrt(2.0)]
			 $c scale all [expr $pos_x] [expr $height/2.0] [expr 1.0/sqrt(2.0)] 1.0
	     }
     }
 	 set orig_width  $width
	 set orig_height $height
	 set xoffset [expr $xoffset-$scroll_offset]
     TR_gen $TR $width 
	 mesh_gen $c 14.0 $width $height  
 	 set xoffset [expr $xoffset+$scroll_offset]
}

proc scaleItems_PR {c PR type pos_x pos_y} {
	 $c delete CrossZone
	 global orig_width orig_height xoffset yoffset scroll_offset scroll_offset_PR
     set width  [winfo width $c]
     set height [winfo height $c]
	 global scalefactor_PR
     if {[expr $type > 0]} {
         if {[expr $scalefactor_PR <= pow(sqrt(2.0),4)]} {
            set scroll_offset_PR [expr $scroll_offset_PR+($pos_y-$height/2.0)/$scalefactor_PR*(1-sqrt(2.0)/2.0)]
		    set scalefactor_PR [expr $scalefactor_PR*sqrt(2.0)]
            $c scale all [expr $width/2.0] [expr $pos_y] 1.0 [expr {sqrt(2.0)}] 
         }
       } else {
	     if {[expr $scalefactor_PR >= sqrt(2.0)]} {
		    set scroll_offset_PR [expr $scroll_offset_PR+($pos_y-$height/2.0)/$scalefactor_PR*(1-sqrt(2.0))]
		    set scalefactor_PR [expr $scalefactor_PR/sqrt(2.0)]
            $c scale all [expr $width/2.0] [expr $pos_y] 1.0 [expr {1.0/sqrt(2.0)}] 
	     }
     } 
 	 set orig_width  $width
	 set orig_height $height
	 set xoffset [expr $xoffset-$scroll_offset]
	 set yoffset [expr $yoffset-$scroll_offset_PR]
	 PR_gen $PR $height
	 mesh_gen $c 14.0 $width $height
	 set xoffset [expr $xoffset+$scroll_offset]
 	 set yoffset [expr $yoffset+$scroll_offset_PR]
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

proc zoomArea {c VC TR PR VR x y} {
    global zoomArea scalefactor scalefactor_PR xc yc xoffset yoffset 

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
#    if { $xscale > $yscale } {
#        set factor $yscale
#    } else {
#        set factor $xscale
#    }
    set xfactor [expr $xscale*$scalefactor]
    set yfactor [expr $yscale*$scalefactor]

    if {[expr $xfactor > pow(sqrt(2.0),7)]} {
		 set xfactor [expr pow(sqrt(2.0),7)]
    }
    if {[expr $yfactor > pow(sqrt(2.0),5)]} {
		 set yfactor [expr pow(sqrt(2.0),5)]
    }

    #--------------------------------------------------------
    #  Perform zoom operation
    #--------------------------------------------------------
	set xc [expr ($xcenter-$width /2.0)/$scalefactor-$xoffset]
	set yc [expr ($ycenter-$height/2.0)/$scalefactor_PR-$yoffset]
	resetView $c $VC $TR $PR $VR 
    moveItems $c $VC $TR $PR 0 0 
	$c scale all [expr $width/2.0] [expr $height/2.0] [expr 1.0*$xfactor] [expr 1.0*$yfactor]
	set scalefactor $xfactor
	set scalefactor_PR $yfactor
    TR_gen $TR $width
	PR_gen $PR $height
    VR_gen $VR $height
	mesh_gen $c 14.0 $width $height
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

# ISO number of days in a year 
set ::ISO_DAYS_A_YEAR 365

# ISO number of days in a leap year 
set ::ISO_DAYS_A_LEAP_YEAR 366

# Number of ISO days a week 
set ::ISO_DAYS_A_WEEK 7

# Number of ISO days a week 
set ::ISO_MONTHS_A_YEAR 12

# ISO number of days in February 
set ::ISO_DAYS_IN_FEBRUARY 28

# ISO number of days in February in a leap year 
set ::ISO_LEAP_YEAR_DAYS_IN_FEBRUARY 29

# First month number in a ISO year 
set ::ISO_FIRST_MONTH_IN_YEAR 1

# GetDayAndMonthFromWeekInYear  - return the Monday of that week
# GetDayAndMonthFromDayInYear   - Jan 1st is the first day
# GetDayOfTheWeek               - return {Monday(1) .. Sunday(0)}  
# GetDayOfTheYear               - Jan 1st is the first day
# GetWeekOfTheYear              - return the week number. The first week starts from the first day of the month

proc GetDayAndMonthFromWeekInYear {year weekInYear} {
    set month $::ISO_FIRST_MONTH_IN_YEAR
    set hasChanged 0
    set weeksInYear [GetNumberOfWeeksInYear $year]
    if {[expr $weekInYear > $weeksInYear]} {
        set weekInYear [expr $weekInYear - $weeksInYear]
        incr year
        set hasChanged 1
    }
	while $hasChanged {
        set hasChanged 0
        set weeksInYear [GetNumberOfWeeksInYear $year]
        if {[expr $weekInYear > $weeksInYear]} {
            set weekInYear [expr $weekInYear - $weeksInYear]
            incr year
            set hasChanged 1
        }
    }
    set dayInYear [expr ($weekInYear-1)*$::ISO_DAYS_A_WEEK+1]
    # Since the first day of week 1 in a year in the Gregorian calendar is not usually January 1st we need to handle the offset
    set t [list 0 0 -1 -2 -3 3 2 1]
    set jan1DayOfWeek [GetDayOfTheWeek $year 1 1] 
    set dayInYear [expr $dayInYear + [lindex $t $jan1DayOfWeek]]
    if {[expr $dayInYear <= 0]} {
        # dayInYear is in the previous year
        incr year -1
        set dayInYear [expr $dayInYear + [GetDaysInYear $year]]
    } else {
        set daysInYear [GetDaysInYear $year]
        if {[expr $dayInYear > $daysInYear]} {
            # dayInYear is in the next year
            incr year
            set dayInYear [expr $dayInYear - $daysInYear];
        }
    }
    set temp [GetDayAndMonthFromDayInYear $year $dayInYear]
	set month [lindex $temp 0]
	set dayInMonth [expr [lindex $temp 1] - 1]
    #return [list $year $month $dayInMonth]
    set names [list dummy Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec]
	return "$year / [lindex $names $month] / $dayInMonth"
}

proc IsALeapYear {year} {
    return [expr (!($year % 4) && ($year % 100)) || !($year % 400)]
}

proc GetDaysInYear {year} { 
    return [expr [IsALeapYear $year] ? $::ISO_DAYS_A_LEAP_YEAR : $::ISO_DAYS_A_YEAR]
}

proc GetDaysInMonth {year month} { 
    switch $month {
        2 {
            set daysInMonth [expr [IsALeapYear $year] ? $::ISO_LEAP_YEAR_DAYS_IN_FEBRUARY : $::ISO_DAYS_IN_FEBRUARY]
		}
        4 -
        6 -
        9 -
        11 {
            set daysInMonth 30
		}
        default {
            set daysInMonth 31
		}
    }
    return $daysInMonth
}

proc GetDayAndMonthFromDayInYear {year dayInYear} {
    set month $::ISO_FIRST_MONTH_IN_YEAR
    for {set i $::ISO_FIRST_MONTH_IN_YEAR} {$i <= $::ISO_MONTHS_A_YEAR} {incr i} {
        set daysInMonth [GetDaysInMonth $year $i]
        if {[expr $dayInYear <= $daysInMonth]} {break}
        incr month
        set dayInYear [expr $dayInYear - $daysInMonth]
    }
    set dayInMonth [expr int($dayInYear)]
    return [list $month $dayInMonth]
}

proc GetNumberOfWeeksInYear {year} { 
    set jan1DayOfWeek [GetDayOfTheWeek $year 1 1]                    
    return [expr ($jan1DayOfWeek== 4 || ($jan1DayOfWeek == 3 && [IsALeapYear $year])) ? 53 : 52]
}

proc GetDayOfTheWeek {year month day} { 
   set t [list 0 3 2 5 0 3 5 1 4 6 2 4]
   set year [expr $year-($month < 3)]
   return [expr ($year + $year/4 - $year/100 + $year/400 + [lindex $t [expr $month-1]] + $day) % 7]
}

proc GetDayOfTheYear {year month day} {
   set ordinal_day 0
   for {set i 1} {$i<$month} {incr i} {
        set ordinal_day [expr $ordinal_day+[GetDaysInMonth $year $i]]
   }
   set ordinal_day [expr $ordinal_day + $day]
   return $ordinal_day
}

proc GetWeekOfTheYear {year month day} {
   set weeknum [expr int(floor(([GetDayOfTheYear $year $month $day]-[GetDayOfTheWeek $year $month $day]+10)/7))]
   return $weeknum
}
