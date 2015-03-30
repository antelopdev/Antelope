import platform, sys, os
from datetime import *

# class
class color:
    purple = '\033[95m'
    cyan = '\033[96m'
    darkcyan = '\033[36m'
    blue = '\033[94m'
    green = '\033[92m'
    yellow = '\033[93m'
    red = '\033[91m'
    bold = '\033[1m'
    underline = '\033[4m'
    end = '\033[0m'

# functions 
def shell_conf():
    #os.system('clear')
    sys.ps1 = color.yellow + "% " + color.end
    os.environ['PYTHONINSPECT'] = 'True'

def verinfo():
    now = datetime.now()
    print("> ++ " + color.yellow + color.bold + "Antelope Studio" + color.end + " ++")
    print("> ++ Version 0.1 | Advanced Analyze System for Individual Inverstors | %s/%s/%s %s:%s:%s" % (now.month, now.day, now.year, now.hour, now.minute, now.second))
    print("> ++ Machine: %s | OS: %s | Platform: %s" % (platform.machine(), platform.release(), platform.system()))
    print("> ++ Python %s | Compiler %s" % (platform.python_version(), platform.python_compiler()))

def init_antelope():
    shell_conf()
    verinfo()

# quick sort
def qsort(arr): 
     if len(arr) <= 1:
          return arr
     else:
          return qsort([x for x in arr[1:] if x<arr[0]]) + [arr[0]] + qsort([x for x in arr[1:] if x>=arr[0]])

