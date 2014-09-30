package provide toolbox 1.0

proc init_info_panel {panel enclosure} {
     ttk::frame $panel
     ## Create the tree and set it up
     ttk::treeview $panel.tree -columns {fullpath type size} -displaycolumns {size} \
     	-yscroll "$panel.vsb set" -xscroll "$panel.hsb set"
     ttk::scrollbar $panel.vsb -orient vertical -command "$panel.tree yview"
     ttk::scrollbar $panel.hsb -orient horizontal -command "$panel.tree xview"
     $panel.tree heading \#0 -text "Directory"  
     $panel.tree column \#0 -stretch 0 -minwidth 10 -width 200 
     $panel.tree heading size -text "File Size"
     $panel.tree column size -stretch 1 -minwidth 10 -width 80 -anchor n 
     populateRoots $panel.tree
     bind $panel.tree <<TreeviewOpen>> {populateTree %W [%W focus]}
     
     ## Arrange the tree and its scrollbars in the toplevel
     lower [ttk::frame $panel.dummy]
     pack $panel.dummy -fill both -expand 1
     grid $panel.tree $panel.vsb -sticky nsew -in $panel.dummy
     grid $panel.hsb -sticky nsew -in $panel.dummy
     grid columnconfigure $panel.dummy 0 -weight 1
     grid rowconfigure $panel.dummy 0 -weight 1

	 pack $panel -fill both -expand 1 -in $enclosure
} 

## Code to populate the roots of the tree (can be more than one on Windows)
proc populateRoots {tree} {
     foreach dir [lsort -dictionary [file volumes]] {
	 populateTree $tree [$tree insert {} end -text $dir \
		 -values [list $dir directory]]
     } 
}

## Code to populate a node of the tree
proc populateTree {tree node} {
     if {[$tree set $node type] ne "directory"} {
	 return
     }
     set path [$tree set $node fullpath]
     $tree delete [$tree children $node]
     foreach f [lsort -dictionary [glob -nocomplain -dir $path *]] {
	 set type [file type $f]
	 set id [$tree insert $node end -text [file tail $f] \
	 	-values [list $f $type]]

	 if {$type eq "directory"} {
	     ## Make it so that this node is openable
	     $tree insert $id 0 -text dummy ;# a dummy
	     $tree item $id -text [file tail $f]/
	 } elseif {$type eq "file"} {
	     set size [file size $f]
	     ## Format the file size nicely
	     if {$size >= 1024*1024*1024} {
	     set size [format %.1f\ GB [expr {$size/1024/1024/1024.}]]
	     } elseif {$size >= 1024*1024} {
	     set size [format %.1f\ MB [expr {$size/1024/1024.}]]
	     } elseif {$size >= 1024} {
	     set size [format %.1f\ kB [expr {$size/1024.}]]
	     } else {
	     append size " bytes"
	     }
	     $tree set $id size $size
	   }
     }

     # Stop this code from rerunning on the current node
     $tree set $node type processedDirectory
}
