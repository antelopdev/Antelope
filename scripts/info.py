import tkinter     as tk
import tkinter.ttk as ttk 
import TkTreectrl  as tctrl

# --------------------------
class INFO(tk.Frame):
    
    def __init__(self, parent, *args, **kwargs):
        tk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.InitVar()
        self.notemenu = ttk.Notebook(self)
        self.notemenu.enable_traversal()
        self.notemenu.favor = TREEFRAME(self, self.favor_list, padding=2)
        self.notemenu.funda = TREEFRAME(self, self.funda_list, padding=2)
        self.notemenu.tech  = TREEFRAME(self, self.tech_list,  padding=2)

        self.notemenu.add(self.notemenu.favor, text=" Favorite ", underline=1, padding=2)
        self.notemenu.add(self.notemenu.funda, text=" Fundamental ", underline=1, padding=2)
        self.notemenu.add(self.notemenu.tech,  text=" Technical ", underline=1, padding=2)
        self.notemenu.pack(side='top', fill='both', expand=1, padx=0, pady=0)

    def InitVar(self):

        self.favor_list = {}
        self.favor_list['A'] = ['Accounting Change', 'After-tax Margin'] 
        self.favor_list['C'] = ['Cash Ratio', 'Current Ratio']
        self.favor_list['D'] = ['Deferred Charges', 'Depreciation Expense']
        self.favor_list['T'] = ['Total Capital', 'Total Short-term Debt']

        self.funda_list = {}
        self.funda_list['A'] = ['Accounting Change', 'After-tax Margin'] 
        self.funda_list['C'] = ['Cash Ratio', 'Current Ratio']
        self.funda_list['D'] = ['Deferred Charges', 'Depreciation Expense']
        self.funda_list['T'] = ['Total Capital', 'Total Short-term Debt']
        
        self.tech_list = {}
        self.tech_list['A']  = ['Accumulation/Distribution']
        self.tech_list['B']  = ['Bollinger Bands']
        self.tech_list['E']  = ['Elliott Wave', 'Envelope']
        self.tech_list['M']  = ['Moving Average']

# --------------------------
class TREEFRAME(ttk.Frame):

    def __init__(self, parent, indexlist, *args, **kwargs):
        ttk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.indexlist = indexlist
        self.tree = tctrl.Treectrl(self, width=250, background='white', relief='flat', highlightcolor='red', showheader='yes', showroot='no', xscrollsmoothing='yes')
        self.tree.pack(side='top', expand='yes', fill='both')

        # Create Column
        self.tree.column_create(text='INDICATOR', width=180, textpadx=4, justify='left', tags='indicator', resize='false', squeeze='false', background='white', font=("", 8), expand='true', borderwidth=1, lock='left')
        self.tree.column_create(text='V', width=25, textpadx=4, justify='center', tags='view', resize='false', squeeze='false', background='white', font=("", 8), borderwidth=1, lock='left')
        self.tree.column_create(text='S', width=25, textpadx=4, justify='center', tags='select', resize='false', squeeze='false', background='white', font=("", 8), borderwidth=1, lock='left')
        self.tree.column_configure('tail', background='white', borderwidth=0)
        self.tree.state_define('CHECK')
	
        # Create Element
        self.tree.element_create(name='elemBorder', type='border')
        self.tree.element_create(name='elemText',  type='text')
        self.tree.element_create(name='elemBox1',  type='rect')
        self.tree.element_create(name='elemBox2',  type='rect')
        self.tree.element_create(name='elemCheck', type='image')
        self.tree.element_configure('elemBorder', draw=('true', ('open'), 'true', ('selected'), 'false', ('')), background=('#f2f5a9', ''), filled='yes', relief='flat', thickness=1)
        self.tree.element_configure('elemText', font=(("", 8), ''), fill=('#0b0b61', ('open'), 'black', ('')), width=120, line=1)
        self.tree.element_configure('elemCheck', image=(self.parent.parent.parent.icon['check'], 'CHECK'))
        self.tree.element_configure('elemBox1', outline='#0489b1', outlinewidth=1, width=12, height=12)
        self.tree.element_configure('elemBox2', outline='#a4a4a4', outlinewidth=1, width=12, height=12)

        # Create Style
        self.tree.style_create(name='sty_indicator')
        self.tree.style_elements('sty_indicator', 'elemBorder', 'elemText')
        self.tree.style_layout('sty_indicator', 'elemBorder', union=('elemText'), ipadx=4, ipady=4)
        self.tree.style_layout('sty_indicator', 'elemText')
        self.tree.style_create('sty_check1')
        self.tree.style_elements('sty_check1', 'elemBox1', 'elemCheck')
        self.tree.style_layout('sty_check1', 'elemBox1', detach='true', expand='nswe')
        self.tree.style_layout('sty_check1', 'elemCheck', expand='nswe') 
        self.tree.style_create('sty_check2')
        self.tree.style_elements('sty_check2', 'elemBox2', 'elemCheck')
        self.tree.style_layout('sty_check2', 'elemBox2', detach='true', expand='nswe')
        self.tree.style_layout('sty_check2', 'elemCheck', expand='nswe')

	    # Create Bindings
        self.tree.notify_bind('<Expand-before>', self.AddChildItems)
        self.tree.notify_bind('<Selection>', self.ChangeStatus)
        self.tree.bind('<ButtonPress-1>', self.TurnCheck) 
        self.tree.bindtags((self.tree, 'info', 'TreeCtrl', self.tree.winfo_toplevel(), 'all'))
        
        # Configure
        self.tree.configure(treecolumn='indicator')
        self.tree.subset = {}
        self.tree.vcheck = {}
        self.tree.scheck = {}
        self.tree.mapping = {}
        self.tree.topnode = {}
        for index in sorted(indexlist.keys()):
            indexID = self.tree.item_create(button='yes')
            self.tree.item_collapse(indexID)
            self.tree.itemstyle_set(indexID, 'indicator', 'sty_indicator', 'view', 'sty_check1', 'select', 'sty_check1')
            self.tree.itemelement_configure(indexID, 'indicator', 'elemText', text='[ '+index+' ]', font=(("", 8), ''))
            self.tree.item_lastchild('root', indexID)
            indexID = int(str(indexID).replace('(', '').replace(',', '').replace(')', ''))
            self.tree.subset[indexID] = []
            self.tree.vcheck[indexID] = False
            self.tree.scheck[indexID] = False
            self.tree.mapping[index]  = indexID

    def AddChildItems(self, event):
        item = event.item
        text = self.tree.itemelement_cget(item, 0, 'elemText', 'text').split()[1]
        if self.tree.item_numchildren(item):
            return
        try:
            indexlist = self.indexlist[text]
        except (OSError, IOError):
            indexlist = []
        for index in indexlist: 
            indexID = self.tree.item_create(button='no')
            self.tree.item_collapse(indexID)
            self.tree.itemstyle_set(indexID, 'indicator', 'sty_indicator', 'view', 'sty_check2', 'select', 'sty_check2')
            self.tree.itemelement_configure(indexID, 'indicator', 'elemText', text=index, font=(("", 8), ''))
            self.tree.item_lastchild(item, indexID)
            indexID = int(str(indexID).replace('(', '').replace(',', '').replace(')', ''))
            self.tree.subset[indexID] = []
            self.tree.subset[item].append(indexID)
            self.tree.topnode[indexID] = item
            self.tree.vcheck[indexID] = self.tree.vcheck[item]
            self.tree.scheck[indexID] = self.tree.scheck[item]
            if self.tree.vcheck[indexID] == True :
                event.widget.itemstate_forcolumn(indexID, 1, 'CHECK')
            else :
                event.widget.itemstate_forcolumn(indexID, 1, '!CHECK')
            if self.tree.scheck[indexID] == True :
                event.widget.itemstate_forcolumn(indexID, 2, 'CHECK')
            else :
                event.widget.itemstate_forcolumn(indexID, 2, '!CHECK')
            self.tree.mapping[index]  = indexID

    def ChangeStatus(self, event):
        item = event.selected
        text = self.tree.itemelement_cget(item, 0, 'elemText', 'text')
        self.parent.parent.parent.status.set(text) 

    def TurnCheck(self, event):
        try:
            id = event.widget.identify(event.x, event.y)
        except (OSError, IOError):
            id = []
        if len(id)== 6:
            what  = id[0]; item  = id[1]; where = id[2]; arg1  = id[3]; arg2  = id[4]; arg3  = id[5]
            if where == "column" :
                if event.widget.column_tag_expr(arg1, 'view') :
                    self.tree.vcheck[item] = not self.tree.vcheck[item]
                    if self.tree.vcheck[item] == True :
                        event.widget.itemstate_forcolumn(item, arg1, 'CHECK')
                        for idx in self.tree.subset[item] :
                            self.tree.vcheck[idx] = True
                            event.widget.itemstate_forcolumn(idx, arg1, 'CHECK')
                    else :
                        event.widget.itemstate_forcolumn(item, arg1, '!CHECK')
                        for idx in self.tree.subset[item] :
                            self.tree.vcheck[idx] = False
                            event.widget.itemstate_forcolumn(idx, arg1, '!CHECK')
                    try :        
                        topnode = self.tree.topnode[item]
                        status = False
                        for idx in self.tree.subset[topnode] :
                            status = status or self.tree.vcheck[idx]
                        if status == True :
                            self.tree.vcheck[topnode] = True
                            event.widget.itemstate_forcolumn(topnode, arg1, 'CHECK')
                        else :
                            self.tree.vcheck[topnode] = False
                            event.widget.itemstate_forcolumn(topnode, arg1, '!CHECK')
                    except :
                        return
                if event.widget.column_tag_expr(arg1, 'select') :
                    self.tree.scheck[item] = not self.tree.scheck[item]
                    if self.tree.scheck[item] == True :
                        event.widget.itemstate_forcolumn(item, arg1, 'CHECK')
                        for idx in self.tree.subset[item] :
                            self.tree.scheck[idx] = True
                            event.widget.itemstate_forcolumn(idx, arg1, 'CHECK')
                    else :
                        event.widget.itemstate_forcolumn(item, arg1, '!CHECK')
                        for idx in self.tree.subset[item] :
                            self.tree.scheck[idx] = False
                            event.widget.itemstate_forcolumn(idx, arg1, '!CHECK')
                    try :        
                        topnode = self.tree.topnode[item]
                        status = False
                        for idx in self.tree.subset[topnode] :
                            status = status or self.tree.scheck[idx]
                        if status == True :
                            self.tree.scheck[topnode] = True
                            event.widget.itemstate_forcolumn(topnode, arg1, 'CHECK')
                        else :
                            self.tree.scheck[topnode] = False
                            event.widget.itemstate_forcolumn(topnode, arg1, '!CHECK')
                    except :
                        return

        
