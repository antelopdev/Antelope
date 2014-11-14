#!/usr/bin/wish

# Experiment with scale/move items in a canvas
#
proc moveItems { x y } {
    global xc yc
    
    if { [info exists ::xc] } {
        .c move all [expr {$x-$xc}] [expr {$y-$yc}]
    }   
    set xc $x
    set yc $y
}

proc scaleItems { type x y } {
  
    if { $type eq "+" } {
        .c scale all $x $y [expr {sqrt(2.0)}] [expr {sqrt(2.0)}]
    } else {
        .c scale all $x $y [expr {1.0/sqrt(2.0)}] [expr {1.0/sqrt(2.0)}]
    }  
}

pack [canvas .c -bg white] -fill both

.c create oval        0   0 100 100 -fill red   -outline black -width 4
.c create rectangle 200 200 300 300 -fill green -outline yellow
.c create line 0  200  200 0 -fill black -width 10
.c create line 0 -200 -200 0 -fill blue  -width 6

set xc 0
set yc 0
focus .c 
bind .c <Button-2>                {set xc %x; set yc %y} 
bind .c <B2-Motion>               {moveItems    %x %y}
bind .c <Button-4>                {scaleItems + %x %y}
bind .c <Button-5>                {scaleItems - %x %y}
#bind .c <KeyPress-a>             {scaleItems + %x %y}
#bind .c <KeyPress-b>             {scaleItems - %x %y}
bind .c <Control-KeyPress-plus>   {scaleItems + %x %y}
bind .c <Control-KeyPress-minus>  {scaleItems - %x %y}
