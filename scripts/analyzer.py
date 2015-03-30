import tkinter     as tk
import tkinter.ttk as ttk 
import glob

# custom modules
from scripts.info  import *
from scripts.chart import *

# --------------------------
# Classes
# --------------------------

class ANALYZER(tk.Toplevel):

    def __init__(self, parent, *args, **kwargs):
        tk.Toplevel.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.title("Antelope Studio")
        self.InitIcon()
        self.InitVar()
        
        self.tools = TOOL(self, width=50, highlightthickness=0, borderwidth=0, background="#f1f3f6")
        self.monitor = MONITOR(self, background="white")
        self.setting = SETTING(self)

        self.tools.grid(column=0, row=0, sticky="nsew")
        self.monitor.grid(column=1, row=0, sticky="nsew")
        self.setting.grid(column=2, row=0, sticky="nsew")
        
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

    def InitIcon(self):
        self.icon = {}
        for pic in glob.glob("icons/*png*"):
            img = pic.split('/')[-1].split('.')[0]
            self.icon[img]  = tk.PhotoImage(file=pic)
            self.icon[img+'0'] = tk.PhotoImage(file=pic, format="png -alpha 0.5")

    def InitVar(self):
        self.status = tk.StringVar()
        self.status.set("Analyzer")

# ---------------------------
class TOOL(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.PlaceIcon()

    def PlaceIcon(self):
        idx = 0
        start = 20
        spacing = 40
        self.create_image(25, start+idx*spacing, tag='screen', image=self.parent.icon['screen'])
        for icon in ['pen', 'compass', 'connection', 'tour', 'cut', 'view', 'ascendant']:
            idx += 1
            self.create_image(25, start+idx*spacing, tag=icon, image=self.parent.icon[icon+'0'], active=self.parent.icon[icon])

class SETTING(tk.Frame):

    def __init__(self, parent, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.info = INFO(self, width=250, background='white')
        self.ctrl = CONTROL(self, width=45, highlightthickness=0, borderwidth=0, background='#f1f3f6')
        self.info.grid(column=0, row=0, sticky="nsew")
        self.ctrl.grid(column=1, row=0, sticky='nsew')
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(0, weight=1)
        
        self.toggle = 1
        self.ctrl.tag_bind('setting', '<Button-1>', lambda event, panel=self.info: self.HidePanel(panel))

    def HidePanel(self, panel):
        if (self.toggle == 1):
            panel.grid_remove()
            self.toggle = 0
        else:
            panel.grid(column=0, row=0, sticky='nsew')
            self.ctrl.grid(column=1,row=0,sticky='nsew')
            self.toggle = 1

# --------------------------
class CONTROL(tk.Canvas):
    
    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.PlaceIcon()

    def PlaceIcon(self):
        idx = 0
        start = 20
        spacing = 50
        self.create_image(22.5, start+idx*spacing, tag='setting_panel', image=self.parent.parent.icon['screwdriver'])
        for icon in ['setting']:
            self.create_line(0, start+idx*spacing+spacing/2.0, 45, start+idx*spacing+spacing/2.0, fill='#a4a4a4')
            idx += 1
            self.create_image(22.5, start+idx*spacing, tag=icon, image=self.parent.parent.icon[icon+'0'], active=self.parent.parent.icon[icon])

# --------------------------
class MONITOR(tk.Frame):

    def __init__(self, parent, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        
        self.option = OPTION(self, height=28, highlightthickness=0, borderwidth=0, background='white')
        self.chart  = CHART(self, width=1400, height=800, padding=1)
        self.status = STATUS(self, padding=0)

        self.option.grid(column=0, row=0, sticky="nsew")
        self.chart.grid(column=0, row=1, sticky="nsew")
        self.status.grid(column=0, row=2, sticky="nsew")
        
        self.grid_columnconfigure(0, weight=1)
        self.grid_rowconfigure(1, weight=1)

# --------------------------
class OPTION(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

# --------------------------
class STATUS(ttk.Frame):
   
    def __init__(self, parent, *args, **kwargs):
        ttk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.placeholder = tk.Label(self, text="% ", relief='flat', anchor='w', font=("", 9), background='white')
        self.statusbar   = tk.Label(self, textvariable=self.parent.parent.status, relief='flat', anchor='w', font=("", 8), background='white')
        self.placeholder.grid(column=0, row=0, sticky="nsew")
        self.statusbar.grid(column=1, row=0, sticky="nsew")
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(0, weight=1)

# --------------------------
# Functions
# --------------------------

def set_theme():
    style = ttk.Style()
    style.theme_use('default')

    # Notebook
    style.configure('Tab', focuscolor='white')
    style.configure('TNotebook', background='white')
    style.configure('TNotebook.Tab', font=("", 8), background='white')
    style.map('TNotebook.Tab', background=[('selected','white'), ('active','white'), ('disabled','white')], foreground=[('selected','blue'), ('active','red'), ('disabled','black')])

    # Frame
    style.configure('TFrame', background='#f1f3f6', borderwidth=1, relief='flat', font=("", 8))
