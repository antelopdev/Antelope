
# ttk::button 

ttk::style configure TButton -background color
ttk::style configure TButton -foreground color
ttk::style configure TButton -font namedfont
ttk::style map TButton -background \
    [list active color disabled color readonly color]
ttk::style map TButton -foreground \
    [list active color disabled color readonly color]

# ttk::checkbutton 

ttk::style configure TCheckbutton -background color
ttk::style configure TCheckbutton -foreground color
ttk::style configure TCheckbutton -font namedfont
ttk::style map TCheckbutton -background \
    [list active color disabled color readonly color]
ttk::style map TCheckbutton -foreground \
    [list active color disabled color readonly color]
ttk::style configure TCheckbutton -indicatorcolor color
ttk::style map TCheckbutton -indicatorcolor \
    [list selected color pressed color]

# The base 'indicatorcolor' is the color when the checkbutton is not selected.
# The 'selected' value is the color of the indicator when the checkbutton is selected.
# The 'pressed' value is the indicator color when the checkbutton is pressed. This does not combine with 'active'.
# The indicator's color also supports disabled, active and readonly, but these are meaningless and confusing as they only show up when the checkbutton is not selected."

# ttk::combobox  

ttk::style configure TCombobox -background color
ttk::style configure TCombobox -foreground color
ttk::style configure TCombobox -fieldbackground color
ttk::style configure TCombobox -selectbackground color
ttk::style configure TCombobox -selectforeground color
ttk::style map TCombobox -background \
    [list disabled color readonly color]
ttk::style map TCombobox -foreground \
    [list disabled color readonly color]
ttk::style map TCombobox -fieldbackground \
    [list disabled color readonly color]
option add *TCombobox*Listbox.background color
option add *TCombobox*Listbox.foreground color
option add *TCombobox*Listbox.selectBackground color
option add *TCombobox*Listbox.selectForeground color

# The combobox widget leverages the pre-ttk Listbox for its dropdown element and as such the 'option' command is currently required to set the listbox options.
# Whereas '-selectbackground' and '-selectforeground' (which apply to 'selected' text) can be used with the configure command, in using the options database for the associated listbox, we must use the appropriate database names of 'selectBackground' and 'selectForeground' respectively, and note that database names appear to be case sensitive (see http://www.tcl.tk/man/tcl8.6/TkCmd/options.html for the full list).
# The above 'selectForeground' and 'selectBackground' options of the associated listbox are used to implement the standard 'hover' effect when selecting via mouse pointer.
# The 'active' option works, but is pointless, as only the color of the drop down selector changes.
# With respect to font settings, for the 'entry/field' font, the usual configuration of the global style ('TComboBox' here)
# ttk::style configure TCombobox -font namedfont
# fails. Less globally, for your specific window (read 'widget instance', e.g. '.combo') you can use
# .combo configure -font namedfont
# or otherwise revert to use the options database:
# option add *TCombobox.font namedfont
# The listbox items font is set similarly
# option add *TCombobox*Listbox.font namedfont

# ttk::entry  edit

ttk::style configure TEntry -background color
ttk::style configure TEntry -foreground color
ttk::style configure TEntry -fieldbackground color
ttk::style configure TEntry -selectbackground color
ttk::style configure TEntry -selectforeground color
ttk::style map TEntry -background \
    [list disabled color readonly color]
ttk::style map TEntry -foreground \
    [list disabled color readonly color]
ttk::style map TEntry -fieldbackground \
    [list disabled color readonly color]
.entry configure -font namedfont

# This:
# ttk::style configure TEntry -font namedfont
# does not work.

# ttk::frame  edit

ttk::style configure TFrame -background color
# Frames only have a background color. Note that to set your top-level window's background color, you need to do:
# . configure -background color

# ttk::label  edit

ttk::style configure TLabel -background color
ttk::style configure TLabel -foreground color
ttk::style configure TLabel -font namedfont
ttk::style map TLabel -background \
    [list disabled color readonly color]
ttk::style map TLabel -foreground \
    [list disabled color readonly color]

# ttk::labelframe  edit

ttk::style configure TLabelframe -background color
ttk::style configure TLabelframe.Label -background color
ttk::style configure TLabelframe.Label -foreground color
ttk::style configure TLabelframe.Label -font namedfont

# menu  edit

.menu configure -background color
.menu configure -foreground color
.menu configure -activebackground color
.menu configure -activeforeground color
.menu configure -disabledforeground color
.menu configure -font namedfont
.menu configure -selectcolor color
# 'selectcolor' is the color of the dot or checkmark for radiobutton and checkbutton menu types.

# ttk::menubutton  edit

ttk::style configure TMenubutton -background color
ttk::style configure TMenubutton -foreground color
ttk::style configure TMenubutton -font namedfont
ttk::style map TMenubutton -background \
    [list active color disabled color]
ttk::style map TMenubutton -foreground \
    [list active color disabled color]

# ttk::notebook  edit

ttk::style configure TNotebook -background color
ttk::style configure TNotebook.Tab -background color
ttk::style configure TNotebook.Tab -foreground color
ttk::style map TNotebook.Tab -background \
    [list selected color active color disabled color]
ttk::style map TNotebook.Tab -foreground \
    [list selected color active color disabled color]
ttk::style configure TNotebook.Tab -font namedfont
# 'selected' is the current tab.
# 'active' is the color displayed when hovering over an unselected tab.
# 'disabled' colors are used when the tab is disabled.

# ttk::panedwindow  edit

ttk::style configure TPanedwindow -background color
ttk::style configure Sash -sashthickness 5
# Paned windows only have a background. Note that there is no visible sash, and you may want to have the paned window's background be a different color than the contained frames.

# ttk::progressbar  edit

ttk::style configure TProgressbar -background color
ttk::style configure TProgressbar -troughcolor color
Progress bars are either horizontal or vertical and when you create your own style name, you must have MyStyle.Horizontal.TProgressbar.

# ttk::radiobutton  edit

ttk::style configure TRadiobutton -background color
ttk::style configure TRadiobutton -foreground color
ttk::style configure TRadiobutton -font namedfont
ttk::style map TRadiobutton -background \
    [list active color disabled color readonly color]
ttk::style map TRadiobutton -foreground \
    [list active color disabled color readonly color]
ttk::style configure TRadiobutton -indicatorcolor color
ttk::style map TRadiobutton -indicatorcolor \
    [list selected color pressed color]
# The base 'indicatorcolor' is the color when the radiobutton is not selected.
# The 'selected' value is the indicator color when the radiobutton is selected.
# The 'pressed' value is the indicator color when the radiobutton is pressed. This does not combine with 'active'.
# The indicator's color also supports disabled, active and readonly, but these are meaningless and confusing as they only show up when the radiobutton is not selected.

# ttk::scale  edit

ttk::style configure TScale -background color
ttk::style configure TScale -troughcolor color
ttk::style map TScale -background \
    [list active color]
'active' is the slider color when the pointer is over the slider or pressing the slider.
Scales are either horizontal or vertical and when you create your own style name, you must have MyStyle.Horizontal.TScale or MyStyle.Vertical.TScale.

# ttk::scrollbar  edit

ttk::style configure TScrollbar -background color
ttk::style configure TScrollbar -troughcolor color
ttk::style configure TScrollbar -arrowcolor color
ttk::style map TScrollbar -background \
    [list active color disabled color]
ttk::style map TScrollbar -foreground \
    [list active color disabled color]
ttk::style map TScrollbar -arrowcolor \
    [list disabled color]
# 'active' is used when the mouse is over the scroll bar or the scroll bar is selected.
# The scrollbar is disabled when the entire field of view is shown.

# ttk::separator  edit

ttk::style configure TSeparator -background color
# Separators are either horizontal or vertical and when you create your own style name, you must have MyStyle.Vertical.TSeparator.

# ttk::sizegrip  edit

ttk::style configure TSizegrip -background color

# ttk::spinbox  edit

ttk::style configure TSpinbox -background color
ttk::style configure TSpinbox -foreground color
ttk::style configure TSpinbox -fieldbackground color
ttk::style configure TSpinbox -selectbackground color
ttk::style configure TSpinbox -selectforeground color
ttk::style configure TSpinbox -arrowcolor color
ttk::style map TSpinbox -background \
    [list active color disabled color readonly color]
ttk::style map TSpinbox -foreground \
    [list active color disabled color readonly color]
ttk::style map TSpinbox -fieldbackground \
    [list active color disabled color readonly color]
ttk::style map TScrollbar -arrowcolor \
    [list disabled color]
.spinbox configure -font namedfont
# This:
# ttk::style configure TSpinbox -font namedfont
# does not work.

# text  edit

.text configure -background color
.text configure -foreground color
.text configure -selectforeground color
.text configure -selectbackground color
.text configure -inactiveselectbackground color
.text configure -insertbackground color
.text configure -font namedfont
# 'insertbackground' is the color behind the cursor.
# 'inactiveselectbackground' is the color of selected text when the text widget does not have focus.

# ttk::treeview  edit

ttk::style configure Treeview -background color
ttk::style configure Treeview -foreground color
ttk::style configure Treeview -font namedfont
ttk::style configure Treeview -fieldbackground color
ttk::style map Treeview -background \
    [list selected color]
ttk::style map Treeview -foreground \
    [list selected color]
ttk::style configure Heading -font namedfont
ttk::style configure Heading -background color
ttk::style configure Heading -foreground color
