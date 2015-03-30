import tkinter     as tk
import tkinter.ttk as ttk 
import math, re
from scripts.weeknum import *
from datetime import *
now = datetime.now()

# --------------------------
class CHART(ttk.Frame):
    global now
    def __init__(self, parent, *args, **kwargs):
        ttk.Frame.__init__(self, parent, *args, **kwargs)
        self.parent = parent
        self.InitVar()
        # timeline
        self.tline   = TL(self, highlightthickness=0, borderwidth=0, background='white', width=self.origw, height=12)
        # price portion - placeholder/ruler/chart
        self.pholder = PH(self, highlightthickness=0, borderwidth=0, background='white', width=self.margin+1, height=12)
        self.pruler  = PR(self, highlightthickness=0, borderwidth=0, background='white', width=self.margin+1, height=self.origh*self.ratio)
        self.pchart  = PC(self, highlightcolor='#003366', highlightthickness=1, borderwidth=0, background='white', width=self.origw, height=self.origh*self.ratio)
        # volume portion - placeholder/ruler/chart
        self.vholder = VH(self, highlightthickness=0, borderwidth=0, background='white', width=self.margin+1, height=12)
        self.vruler  = VR(self, highlightthickness=0, borderwidth=0, background='white', width=self.margin+1, height=self.origh*(1-self.ratio))
        self.vchart  = VC(self, highlightcolor='#003366', highlightthickness=1, borderwidth=0, background='white', width=self.margin+1, height=self.origh*(1-self.ratio))

        # layout
        self.tline.grid(column=1, row=0, sticky="nsew")
        self.pholder.grid(column=0, row=0, sticky="nsew")
        self.pruler.grid(column=0, row=1, sticky="nsew")
        self.pchart.grid(column=1, row=1, sticky="nsew")
        self.vholder.grid(column=0, row=2, sticky="nsew")
        self.vruler.grid(column=0, row=3, sticky="nsew")
        self.vchart.grid(column=1, row=2, rowspan=2, sticky="nsew")
        self.grid_columnconfigure(1, weight=1)
        self.grid_rowconfigure(1, weight=1)

        # bindings
        self.pchart.bind('<Configure>',  self.OnConfig)
        self.pchart.bind('<Button-1>',   self.GetPointer)
        self.pchart.bind('<KeyPress>',   self.KeyAction)
        self.pchart.bind('<Motion>',     lambda event: {self.pchart.focus_set(), self.SetFocus('pchart'), self.DrawMarker(event.x, event.y)})
        self.pchart.bind('<B1-Motion>',  lambda event: {self.MoveItems(event.x), self.DrawMarker(event.x, event.y)})
        self.pchart.bind('<Button-4>',   lambda event: {self.ScaleItems(1,  event.x), self.DrawMarker(event.x, event.y)})
        self.pchart.bind('<Button-5>',   lambda event: {self.ScaleItems(-1, event.x), self.DrawMarker(event.x, event.y)})

        self.vchart.bind('<Button-1>',   self.GetPointer)
        self.vchart.bind('<KeyPress>',   self.KeyAction)
        self.vchart.bind('<Motion>',     lambda event: {self.vchart.focus_set(), self.SetFocus('vchart'), self.DrawMarker(event.x, event.y)})
        self.vchart.bind('<B1-Motion>',  lambda event: {self.MoveItems(event.x), self.DrawMarker(event.x, event.y)})
        self.vchart.bind('<Button-4>',   lambda event: {self.ScaleItems(1,  event.x), self.DrawMarker(event.x, event.y)})
        self.vchart.bind('<Button-5>',   lambda event: {self.ScaleItems(-1, event.x), self.DrawMarker(event.x, event.y)})

    def InitVar(self):
        self.width  = 1400
        self.height = 800
        self.origw = self.width
        self.origh = self.height
        self.xc = 0
        self.yc = 0               
        self.xoffset = 0.0
        self.yoffset = 0.0
        self.hscale = 1.0
        self.vscale = 1.0
        self.ratio = 3.8/5
        self.margin = 59
        self.marker_x = 0
        self.marker_y = 0
        self.scroll_offset = 0.0
        self.Qtotal_offset_old=10
        self.year_old = now.year
        self.i_old = 0
        self.lowest_price = 'INF'
        self.highest_price = 0
        self.highest_vol = 0
        self.stable = False
        self.enable_snap = True
        self.enable_todayline = True
        self.enable_daily = False

    def KeyAction(self, event):
        keyvalue = event.keysym
        self.xc = self.marker_x
        self.yc = self.marker_y 
        if keyvalue == 'equal' : 
            self.ScaleItems(1, self.marker_x),
        elif keyvalue == 'minus' : 
            self.ScaleItems(-1, self.marker_x),
        elif keyvalue == 'Up' :
            self.marker_y -= 10
            if self.marker_y < 0:
                self.marker_y += 10
        elif keyvalue == 'Down' :
            self.marker_y += 10
            if self.marker_y > self.pheight:
                self.marker_y -= 10
        elif keyvalue == 'Left' :
            self.marker_x -= 10
            if self.marker_x < 0:
                self.MoveItems(self.xc + 10)
                self.marker_x += 10
        elif keyvalue == 'Right' :
            self.marker_x += 10
            if self.marker_x > self.pwidth:
                self.MoveItems(self.xc - 10)
                self.marker_x -= 10
        elif keyvalue == 'f' :
            self.ResetView()
        elif keyvalue == 'p' :
            self.PrintVar()
        else :
            print("\n[ Key Value ] %s" % keyvalue)
        self.DrawMarker(self.marker_x, self.marker_y)

    def PrintVar(self):
        formatStr = "> %-20s %-10s"
        print("")
        print("Internal Variables:")
        print(formatStr % ("width",             self.width))
        print(formatStr % ("height",            self.height))
        print(formatStr % ("xc",                self.xc))
        print(formatStr % ("yc",                self.yc))
        print(formatStr % ("xoffset",           self.xoffset))
        print(formatStr % ("yoffset",           self.yoffset))
        print(formatStr % ("hscale",            self.hscale))
        print(formatStr % ("vscale",            self.vscale))
        print(formatStr % ("origw",             self.origw))
        print(formatStr % ("origh",             self.origh))
        print(formatStr % ("marker_x",          self.marker_x)) 
        print(formatStr % ("marker_y",          self.marker_y))
        print(formatStr % ("scroll_offset",     self.scroll_offset))
        print(formatStr % ("Qtotal_offset_old", self.Qtotal_offset_old))
        print(formatStr % ("year_old",          self.year_old))
        print(formatStr % ("i_old",             self.i_old))
        print(formatStr % ("lowest_price",      self.lowest_price))
        print(formatStr % ("highest_price",     self.highest_price))
        print(formatStr % ("highest_vol",       self.highest_vol))
        print(formatStr % ("stable",            self.stable))
        print(formatStr % ("enable_snap",       self.enable_snap))
        print(formatStr % ("enable_daily",      self.enable_daily))

    def OnConfig(self, event):
        self.width  = event.width
        self.height = event.height
        if (self.stable == True):
            self.origxoffset = (self.origw - self.width)/2.0
            self.origyoffset = (self.origh - self.height)/2.0
        self.origw = self.width
        self.origh = self.height
        self.stable = True
        self.xoffset = self.xoffset - self.scroll_offset
        self.BorderGen()
        self.RulerGen()
        self.MeshGen()
        self.CurveGen()
        self.xoffset = self.xoffset + self.scroll_offset

    def ResetView(self):
        self.origxoffset = (self.origw - self.width)/2.0
        self.origyoffset = (self.origh - self.height)/2.0
        self.pchart.scale('all', self.width/2.0, self.height/2.0, 1.0/self.hscale, 1.0/self.vscale)
        self.pchart.move('all', -self.xoffset+self.scroll_offset, -self.yoffset) 
        self.xoffset = 0.0
        self.yoffset = 0.0
        self.scroll_offset = 0.0
        self.hscale = 1.0
        self.vscale = 1.0
        self.origw = self.width
        self.origh = self.height
        self.enable_daily = False
        self.Qtotal_offset_old = 10
        self.year_old = now.year
        self.i_old = 0
        self.BorderGen()
        self.RulerGen()
        self.MeshGen()
        self.CurveGen()

    def MoveItems(self, x):
        self.xoffset += (x-self.xc)/self.hscale
        self.xc = x
        self.xoffset -= self.scroll_offset
        self.BorderGen()
        self.RulerGen()
        self.MeshGen()
        self.CurveGen()
        self.xoffset += self.scroll_offset

    def ScaleItems(self, direction, x):
        if (direction > 0) and (self.hscale <= 2**5):
            self.scroll_offset += (x-self.width/2.0)/self.hscale*(1-(2**0.5)/2.0)
            self.hscale = self.hscale*(2**0.5)
            self.pchart.scale('all', x, self.height/2.0, (2**0.5), 1.0)
        elif (direction < 0) and (self.hscale >= (2**0.5)):
            self.scroll_offset += (x-self.width/2.0)/self.hscale*(1-(2**0.5))
            self.hscale = self.hscale/(2**0.5)
            self.pchart.scale('all', x, self.height/2.0, 1.0/(2**0.5), 1.0)
        else:
            return
        if (self.hscale < 2**3.5):
            self.enable_daily = False
        else:
            self.enable_daily = True
        self.xoffset -= self.scroll_offset
        self.BorderGen()
        self.RulerGen()
        self.MeshGen()
        self.CurveGen()
        self.xoffset += self.scroll_offset

    def SetFocus(self, chart):
        self.focus = chart

    def GetPointer(self, event):
        self.xc = event.x
        self.yc = event.y

    def GetCursorDate(self, x):
        reference_loc  = self.Qtotal_offset_old*self.hscale+self.start_offset
        delta_week = round(((x-reference_loc)/self.hscale-(self.xoffset-self.scroll_offset))/10.0-0.49)
        delta_day  = round(((x-reference_loc)/self.hscale-(self.xoffset-self.scroll_offset))/2.0-delta_week*5)
        week_range = 0
        i = self.i_old
        if delta_week >= 0:
            while week_range < delta_week:
                i += 1
                week_range += GetNumberOfWeeksInYear(now.year + i)
            display_year = now.year+i
            display_week = GetNumberOfWeeksInYear(now.year+i)-(week_range-delta_week)
        else :
            while week_range >= delta_week:
                week_range -= GetNumberOfWeeksInYear(now.year + i)
                i -= 1
            display_year = now.year+i+1
            display_week = -(week_range-delta_week)
        display_week = round(display_week)
        if display_week==0: 
            display_week = GetNumberOfWeeksInYear(display_year)
        display_start = GetDayAndMonthFromWeekInYear(display_year, display_week)
        display_end   = GetDayAndMonthFromDayInYear(display_start[0], GetDayOfTheYear(display_start[0], display_start[1], display_start[2])+6)
        display_day   = GetDayAndMonthFromDayInYear(display_start[0], GetDayOfTheYear(display_start[0], display_start[1], display_start[2])+delta_day)
        return [display_year, display_week, display_day, display_start, display_end]

    def DrawMarker(self, x, y):
        self.pchart.delete('verticalMarker')
        self.pchart.delete('horizontalMarker')
        self.pchart.delete('coordMarker')
        self.pchart.delete('CrossZone')
        self.vchart.delete('verticalMarker')
        self.vchart.delete('horizontalMarker')
        self.vchart.delete('coordMarker')
        self.vchart.delete('CrossZone')
        # get snap coordinates
        if self.enable_snap and self.focus == 'pchart':
            radius = 5.5
            cross  = self.pchart.find_overlapping(x-radius, y-radius, x+radius, y+radius)
            snap_x = ""
            snap_y = ""
            for item in cross:
                tag = str(self.pchart.gettags(item))
                if re.search('verticalMeshLine', tag):
                    bbox = self.pchart.coords(item)
                    snap_x = bbox[0]
                if re.search('horizontalMeshLine', tag):
                    bbox = self.pchart.coords(item)
                    snap_y = bbox[1]
            if snap_x != "" and snap_y != "":
                self.pchart.config(cursor=('none'))
                self.pchart.create_line(math.ceil(snap_x-radius-3), snap_y-3, snap_x-3, snap_y-3, snap_x-3, math.ceil(snap_y-radius-3), fill='blue', tag='CrossZone')
                self.pchart.create_line(math.ceil(snap_x+radius+3), snap_y-3, snap_x+3, snap_y-3, snap_x+3, math.ceil(snap_y-radius-3), fill='blue', tag='CrossZone') 
                self.pchart.create_line(math.ceil(snap_x-radius-3), snap_y+3, snap_x-3, snap_y+3, snap_x-3, math.ceil(snap_y+radius+3), fill='blue', tag='CrossZone') 
                self.pchart.create_line(math.ceil(snap_x+radius+3), snap_y+3, snap_x+3, snap_y+3, snap_x+3, math.ceil(snap_y+radius+3), fill='blue', tag='CrossZone') 
                x = snap_x
                y = snap_y
        else:
            self.pchart.config(cursor="")
        # acquire cursor date
        CursorDate = self.GetCursorDate(x)
        display_year  = CursorDate[0]
        display_week  = CursorDate[1]
        display_day   = CursorDate[2]
        display_start = CursorDate[3]
        display_end   = CursorDate[4]
        # create line for cursor indicator
        self.pchart.create_line(x, 0, x, self.pheight, width=0, fill='blue', tag='verticalMarker')
        self.vchart.create_line(x, 0, x, self.vheight, width=0, fill='blue', tag='verticalMarker')
        if self.focus == 'pchart': self.pchart.create_line(0, y, self.pwidth, y, width=0, fill='blue', tag='horizontalMarker')
        if self.focus == 'vchart': self.vchart.create_line(0, y, self.vwidth, y, width=0, fill='blue', tag='horizontalMarker')
        if self.enable_daily: 
            if self.focus == 'pchart': 
                self.pchart.create_text(x+10, y+10, text=" | Day %s-%s-%s @ Week #%s {%s-%s-%s, %s-%s-%s}" % \
                (display_day[0],   display_day[1],   display_day[2], display_week, \
                 display_start[0], display_start[1], display_start[2], \
                 display_end[0],   display_end[1],   display_end[2]), fill='blue', anchor='nw', tag='coordMarker')
            if self.focus == 'vchart': 
                self.vchart.create_text(x+10, y+10, text=" | Day %s-%s-%s @ Week #%s {%s-%s-%s, %s-%s-%s}" % \
                (display_day[0],   display_day[1],   display_day[2], display_week, \
                 display_start[0], display_start[1], display_start[2], \
                 display_end[0],   display_end[1],   display_end[2]), fill='blue', anchor='nw', tag='coordMarker')
        else:
            if self.focus == 'pchart': 
                self.pchart.create_text(x+10, y+10, text=" | @ Week #%s {%s-%s-%s, %s-%s-%s}" % \
                (display_week, display_start[0], display_start[1], display_start[2], \
                 display_end[0], display_end[1], display_end[2]), fill='blue', anchor='nw', tag='coordMarker')
            if self.focus == 'vchart': 
                self.vchart.create_text(x+10, y+10, text=" | @ Week #%s {%s-%s-%s, %s-%s-%s}" % \
                (display_week, display_start[0], display_start[1], display_start[2], \
                 display_end[0], display_end[1], display_end[2]), fill='blue', anchor='nw', tag='coordMarker')
        self.marker_x = x
        self.marker_y = y

    def BorderGen(self):
        self.tline.BorderGen()
        self.pholder.BorderGen()
        self.pruler.BorderGen()
        self.vholder.BorderGen()
        self.vruler.BorderGen()

    def RulerGen(self):
        self.pruler.RulerGen()
        self.vruler.RulerGen()

    def CurveGen(self):
        if self.enable_todayline:
            self.pchart.create_line(self.today_loc + self.xoffset*self.hscale, 0, self.today_loc + self.xoffset*self.hscale, self.pheight, width=1, fill='#123582', tag='todayLine')

    def MeshGen(self):
        self.tline.delete('TimeLine')
        self.pchart.delete('verticalMeshLine')
        self.pchart.delete('horizontalMeshLine')
        self.pchart.delete('todayLine')
        self.vchart.delete('verticalMeshLine')
        self.vchart.delete('todayLine')

        self.pwidth  = self.pchart.winfo_width()
        self.pheight = self.pchart.winfo_height()
        self.vwidth  = self.vchart.winfo_width()
        self.vheight = self.vchart.winfo_height()

        self.current_weeknumbers = GetNumberOfWeeksInYear(now.year)
        self.today_week = GetWeekOfTheYear(now.year, now.month, now.day)
        if self.today_week <=13:
            self.today_quarter = 1
        elif self.today_week <=26:
            self.today_quarter = 2
        elif self.today_week <=39:
            self.today_quarter = 3
        else:
            self.today_quarter = 4

        if (self.current_weeknumbers==53) and (self.today_week>39):
            self.today_loc = self.pwidth/2.0 + 14*10*self.hscale
            self.start_offset = self.pwidth/2+(14+53-self.today_week)*10*self.hscale
        else:
            self.today_loc = self.pwidth/2.0 + 13*10*self.hscale
            self.start_offset = self.pwidth/2+(13+self.current_weeknumbers-self.today_week)*10*self.hscale

        if self.enable_daily:
            DoW = GetDayOfTheWeek(now.year, now.month, now.day)
            if DoW>5: DoW = 5
            self.today_loc += (DoW-1)*2*self.hscale
        
        shrink_table = [10, 8, 6, 4, 4, 3, 3, 3, 3, 2, 2]
        idx = int(math.log(self.hscale, 2**0.5))
        center_quarter = int(-self.xoffset/(13*10))
        start_quarter =  center_quarter - shrink_table[idx]
        end_quarter   =  center_quarter + shrink_table[idx]
        
        for quarter_range in range(start_quarter, end_quarter+1):
            year_range = math.floor((self.today_quarter+quarter_range-1)/4)
            display_year = now.year + year_range
            weeknumbers = GetNumberOfWeeksInYear(display_year)
            Qtotal_offset = self.Qtotal_offset_old
            if display_year <= self.year_old :
                for i in range(self.i_old, year_range, -1):
                    Qtotal_offset -= GetNumberOfWeeksInYear(now.year+i)*10
            else:
                for i in range(self.i_old+1, year_range+1): 
                    Qtotal_offset += GetNumberOfWeeksInYear(now.year+i)*10
            if weeknumbers==53: 
                Q4_weeks = 14
            else:
                Q4_weeks = 13
            Q4_offset = Q4_weeks*10*self.hscale
            Q_offset = 13*10*self.hscale
            Quarter = (self.today_quarter+quarter_range)%4
            if Quarter==0: Quarter = 4 
            if Quarter==1:
                Qstart = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset-2*Q_offset 
                Qend   = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset-3*Q_offset
                cnt    = 13
            elif Quarter==2:
                Qstart = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset-Q_offset 
                Qend   = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset-2*Q_offset
                cnt    = 13
            elif Quarter==3:
                Qstart = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset 
                Qend   = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset-Q_offset
                cnt    = 13
            else:
                Qstart = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale 
                Qend   = self.start_offset+Qtotal_offset*self.hscale+self.xoffset*self.hscale-Q4_offset
                cnt    = Q4_weeks
            if (quarter_range==center_quarter) and (Quarter==4):
                self.Qtotal_offset_old = Qtotal_offset
                self.year_old = display_year
                self.i_old = year_range

            # Timeline 
            self.tline.create_line(Qstart, 0, Qstart, 11, width=1, fill='blue', tag='TimeLine')
            if self.enable_daily:
                for i in range(1, cnt+1): 
                    self.tline.create_line(Qend+(i-1)*10*self.hscale, 0, Qend+(i-1)*10*self.hscale, 11, width=1, fill='blue', tag='TimeLine')
                    self.tline.create_line(Qend+i*10*self.hscale, 0, Qend+i*10*self.hscale, 11, width=1, fill='blue', tag='TimeLine')
                    self.tline.create_text(Qend+(i-0.5)*10*self.hscale, 5.5, text="%s W%s" % (display_year, i+13*(Quarter-1)), anchor='center', font=("", 8), tag='TimeLine')
            else:
                self.tline.create_text((Qstart+Qend)/2.0, 5.5, text="%s Q%s" % (display_year, Quarter), anchor='center', font=("", 8), tag='TimeLine')

            # Price/Volume Chart
            self.pchart.create_line(Qstart, 0, Qstart, self.pheight, width=0, fill='#e6e6e6', tag='verticalMeshLine')
            self.vchart.create_line(Qstart, 0, Qstart, self.vheight, width=0, fill='#e6e6e6', tag='verticalMeshLine')
            if self.enable_daily: 
                for j in range(1, 5):
                    self.pchart.create_line(Qstart-j*2*self.hscale, 0, Qstart-j*2*self.hscale, self.pheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
                    self.vchart.create_line(Qstart-j*2*self.hscale, 0, Qstart-j*2*self.hscale, self.vheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
                for i in range(1, cnt):
                    self.pchart.create_line(Qstart-i*10*self.hscale, 0, Qstart-i*10*self.hscale, self.pheight, width=0, fill='#e6e6e6', tag='verticalMeshLine')
                    self.vchart.create_line(Qstart-i*10*self.hscale, 0, Qstart-i*10*self.hscale, self.vheight, width=0, fill='#e6e6e6', tag='verticalMeshLine')
                    for j in range(1, 5):
                        self.pchart.create_line(Qstart-i*10*self.hscale-j*2*self.hscale, 0, Qstart-i*10*self.hscale-j*2*self.hscale, self.pheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
                        self.vchart.create_line(Qstart-i*10*self.hscale-j*2*self.hscale, 0, Qstart-i*10*self.hscale-j*2*self.hscale, self.vheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
            else:
                for i in range(1, cnt):
                    self.pchart.create_line(Qstart-i*10*self.hscale, 0, Qstart-i*10*self.hscale, self.pheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
                    self.vchart.create_line(Qstart-i*10*self.hscale, 0, Qstart-i*10*self.hscale, self.vheight, width=0, dash=('.'), fill='#e6e6e6', tag='verticalMeshLine')
	# horizontal stripes
        spare_up = 15
        spare_dwn = 15
        hsegment = (self.pheight-spare_up-spare_dwn)/6.0
        yunit = hsegment/10.0
        for cnt in range(0, 7):
            y_pos = self.pheight-cnt*hsegment-spare_dwn
            self.pchart.create_line(0, y_pos, self.pwidth, y_pos, width=1, fill='#e6e6e6', tag='horizontalMeshLine')
            for i in range(0, 10):
                temp = y_pos-yunit*i
                self.pchart.create_line(0, temp, self.pwidth, temp, width=1, dash=('.'), fill='#e6e6e6', tag='horizontalMeshLine')
        self.pchart.lower('verticalMeshLine')
        self.pchart.lower('horizontalMeshLine')
        self.vchart.lower('verticalMeshLine')

class TL(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def BorderGen(self):
        width = self.parent.pchart.winfo_width()-1
        self.delete('TL_Border')
        self.create_line(1, 0, width, 0, width, 11, 1, 11, width=1, fill='black', tag='TL_Border')

class PH(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def BorderGen(self):
        self.delete('PR_Border')
        self.create_text(self.parent.margin/2.0, 5.5, text='Price', anchor='center', fill='blue', font=("", 8), tag='PR_Border')
        self.create_line(1, 0, 1, 11, width=1, fill='black', tag='PR_Border')
        self.create_line(1, 0, self.parent.margin, 0, width=1, fill='black', tag='PR_Border')
        self.create_line(1, 11, self.parent.margin, 11, width=1, fill='black', tag='PR_Border')
        self.create_line(self.parent.margin, 0, self.parent.margin, 11, width=1, fill='black', tag='PR_Border')

class PR(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def BorderGen(self):
        height = self.parent.pchart.winfo_height()
        self.delete('PR_Border')
        self.create_line(1, 0, 1, height, width=1, fill='black', tag='PR_Border')
        self.create_line(self.parent.margin, 0, self.parent.margin, height, width=1, fill='black', tag='PR_Border')

    def RulerGen(self):
        height = self.parent.pchart.winfo_height()
        spare_up  = 15
        spare_dwn = 15
        self.delete('PriceLine')
        segment = (height - spare_up - spare_dwn)/6.0
        yunit   = (segment/10.0)
        for cnt in range(0, 7):
            y_pos = height - cnt*segment - spare_dwn
            self.create_line(self.parent.margin*2.0/3.0 + 5, y_pos, self.parent.margin, y_pos, width=1, fill='blue', tag='PriceLine')
            if self.parent.lowest_price != "INF":
                self.create_text(self.parent.margin*2.0/3.0, y_pos, text="%0.2f" % (self.parent.lowest_price+((self.parent.highest_price-self.parent.lowest_price)/6)*cnt), anchor='e', font=("", 8), tag='PriceLine')
            else:
                self.create_text(self.parent.margin*2.0/3.0, y_pos, text="N/A", anchor='e', font=("", 8), tag='PriceLine')
            for i in range(1,10):
                temp = y_pos-yunit*i
                self.create_line(self.parent.margin*2.0/3.0 + 12, temp, self.parent.margin, temp, width=1, fill='black', tag='PriceLine')

class PC(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

class VH(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def BorderGen(self):
        self.delete('VR_Border')
        self.create_text(self.parent.margin/2.0, 5.5, text='Volume', anchor='center', fill='blue', font=("", 8), tag='VR_Border')
        self.create_line(1, 0, 1, 11, width=1, fill='black', tag='VR_Border')
        self.create_line(1, 0, self.parent.margin, 0, width=1, fill='black', tag='VR_Border')
        self.create_line(1, 11, self.parent.margin, 11, width=1, fill='black', tag='VR_Border')
        self.create_line(self.parent.margin, 0, self.parent.margin, 11, width=1, fill='black', tag='VR_Border')

class VR(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def BorderGen(self):
        self.delete('VR_Border')
        height = self.parent.vchart.winfo_height()
        self.create_line(1, 0, 1, height, width=1, fill='black', tag='VR_Border')
        self.create_line(self.parent.margin, 0, self.parent.margin, height, width=1, fill='black', tag='VR_Border')
        self.create_line(1, height-13, self.parent.margin, height-13, width=1, fill='black', tag='VR_Border')

    def RulerGen(self):
        height = self.parent.vchart.winfo_height() - 16
        comment_space = 30
        self.delete('VolumeLine') 
        segment = (height-comment_space)/5.0
        yunit = segment/5.0
        for cnt in range(0, 6):
            y_pos = height-cnt*segment
            self.create_line(self.parent.margin*2.0/3.0 + 5, y_pos, self.parent.margin, y_pos, width=1, fill='blue', tag='VolumeLine')
            if self.parent.highest_vol != 0 : 
                self.create_text(self.parent.margin*2.0/3.0, y_pos, text=int(self.parent.highest_vol/5)*cnt, anchor='e', font=("", 8), tag='VolumeLine')
            else:
                self.create_text(self.parent.margin*2.0/3.0, y_pos, text="N/A", anchor='e', font=("", 8), tag='VolumeLine')
            for i in range(1, 5): 
                temp = y_pos-yunit*i
                self.create_line(self.parent.margin*2.0/3.0 + 12, temp, self.parent.margin, temp, width=1, fill='black', tag='VolumeLine')

class VC(tk.Canvas):

    def __init__(self, parent, *args, **kwargs):
        tk.Canvas.__init__(self, parent, *args, **kwargs)
        self.parent = parent

    def ChartGen(self):
        self.delete('ZeroLine')
        width = self.winfo_width()
        height = self.winfo_height() - 16
        zero_pos = height + 12
        self.create_line(0, zero_pos, width, zero_pos, width=1, fill='red', tag='ZeroLine')


