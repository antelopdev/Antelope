#!/usr/bin/python3 -i
#############################################################################
#
# Antelope Studio
#
# Advanced Analyze System for Individual Investor
#
# Revisions
# 02/24/2015, Rebuilt by python, Last modified by Young
#############################################################################

## Import Modules 
from scripts.basic    import *
from scripts.analyzer import *

## global var
analyzer = None

## function
def open_analyzer():
    global analyzer

    # init toplevel
    root = tk.Tk()
    root.withdraw()

    # set ttk theme
    set_theme()

    # init main application
    analyzer = ANALYZER(root)

## Program Entry
init_antelope()

