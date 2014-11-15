package provide toolbox 1.0

proc init_info_panel {panel enclosure} {
     ttk::frame $panel

     ## search bar
	 # fill the Tool pane
	 ttk::frame $panel.search 
     ttk::labelframe $panel.search.title -text "Search Ticker/Symbols" -labelanchor nw
	 ttk::entry $panel.search.text -justify left -textvariable search_text 
	 pack $panel.search.title -side top -fill both -expand 1 
	 pack $panel.search.text  -side top -fill both -expand 1 -padx 2 -pady 5 -in $panel.search.title
     pack $panel.search -side top -fill both -expand 0

     ## Need a Combobox to select date
     set years ""
     for {set i 2014} {$i>=1990} {incr i -1} {
	 lappend years $i
     }
     set months ""
     for {set i 12} {$i>=1} {incr i -1} {
	 lappend months $i
     }    
     set days ""
     for {set i 31} {$i>=1} {incr i -1} {
	 lappend days $i
     }

     ttk::frame $panel.date
     ttk::labelframe $panel.date.year -text "Year" -labelanchor nw
     ttk::combobox   $panel.date.year.value -width 10 -textvariable date_year -state readonly -values $years
     ttk::labelframe $panel.date.month -text "Month" -labelanchor nw
     ttk::combobox   $panel.date.month.value -width 10 -textvariable date_month -state readonly -values $months
     ttk::labelframe $panel.date.day -text "Day" -labelanchor nw
     ttk::combobox   $panel.date.day.value -width 10 -textvariable date_day -state readonly -values $days
     pack $panel.date.year        $panel.date.month $panel.date.day -side left -fill both -expand 1
     pack $panel.date.year.value  -fill both -expand 1
     pack $panel.date.month.value -fill both -expand 1
     pack $panel.date.day.value   -fill both -expand 1
     pack $panel.date -side top -fill both -expand 0

     ## Create the tree and set it up
     ttk::treeview $panel.tree -columns {fullpath type value} -displaycolumns {value} \
     	-yscroll "$panel.vsb set" -xscroll "$panel.hsb set" 
     ttk::scrollbar $panel.vsb -orient vertical -command "$panel.tree yview"
     ttk::scrollbar $panel.hsb -orient horizontal -command "$panel.tree xview"
     $panel.tree heading \#0 -text "INDEX"  
     $panel.tree column \#0 -stretch 0 -minwidth 10 -width 200 
     $panel.tree heading value -text "VALUE"
     $panel.tree column value -stretch 1 -minwidth 10 -width 80 -anchor n 
	 populateRoots $panel.tree

	 ## Arrange the tree and its scrollbars in the toplevel
     lower [ttk::frame $panel.dummy]
     pack $panel.dummy -side top -fill both -expand 1
     grid $panel.tree $panel.vsb -sticky nsew -in $panel.dummy
     grid $panel.hsb -sticky nsew -in $panel.dummy
     grid columnconfigure $panel.dummy 0 -weight 1
     grid rowconfigure $panel.dummy 0 -weight 1

	 pack $panel -fill both -expand 1 -in $enclosure
} 

## Code to populate the roots of the tree (can be more than one on Windows)
proc populateRoots {tree} {
     # generate the tree
     set hier(root)         [list Fundanmental Technical]
	 set hier(Fundanmental) [list a0 a1 a2]
	 set hier(Technical)    [list b0 b1 b2]

     set value(a0)  1.0
     set value(a1)  2.0
     set value(a2)  3.0
     set value(b0)  4.0
     set value(b1)  5.0
     set value(b2)  6.0

     foreach node $hier(root) {
	   set parent [$tree insert {} end -text $node -open true]
	   foreach subnode $hier($node) {
   	       set child [$tree insert $parent end -text $subnode]
           $tree set $child value $value($subnode)
       }
	   $tree set $parent value ""
     } 
}
