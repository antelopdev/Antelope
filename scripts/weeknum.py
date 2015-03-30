import math

class ISO:
    DAYS_A_YEAR                = 365
    DAYS_A_LEAP_YEAR           = 366
    DAYS_A_WEEK                = 7
    MONTHS_A_YEAR              = 12
    DAYS_IN_FEBRUARY           = 28
    LEAP_YEAR_DAYS_IN_FEBRUARY = 29
    FIRST_MONTH_IN_YEAR        = 1

def GetDayAndMonthFromWeekInYear(year, weekInYear):
    month = ISO.FIRST_MONTH_IN_YEAR
    hasChanged = False
    weeksInYear = GetNumberOfWeeksInYear(year)
    if weekInYear > weeksInYear :
        weekInYear -= weeksInYear
        year += 1
        hasChanged = True
    while hasChanged :
        hasChanged = False
        weeksInYear = GetNumberOfWeeksInYear(year)
        if weekInYear > weeksInYear :
            weekInYear -= weeksInYear
            year += 1
            hasChanged = True
    dayInYear = (weekInYear-1) * ISO.DAYS_A_WEEK + 1
    t = [0, 0, -1, -2, -3, 3, 2, 1]
    jan1DayOfWeek = GetDayOfTheWeek(year, 1, 1) 
    dayInYear += t[jan1DayOfWeek]
    if dayInYear <= 0 :
        year -= 1
        dayInYear += GetDaysInYear(year)
    else :
        daysInYear = GetDaysInYear(year)
        if dayInYear > daysInYear :
            year += 1
            dayInYear -= daysInYear
    temp       = GetDayAndMonthFromDayInYear(year, dayInYear)
    month      = temp[1]
    dayInMonth = temp[2]
    if (weekInYear==0) and (GetNumberOfWeeksInYear(year-1)==52) : 
        return [0, 0, 0]
    else :
        return [year, month, dayInMonth]

def IsALeapYear(year):
    return ((not (year % 4)) and (year % 100)) or (not (year % 400))

def GetDaysInYear(year):
    return  ISO.DAYS_A_LEAP_YEAR if (IsALeapYear(year)) else ISO.DAYS_A_YEAR

def GetDaysInMonth(year, month):
    return {
        2  : ISO.LEAP_YEAR_DAYS_IN_FEBRUARY if (IsALeapYear(year)) else ISO.DAYS_IN_FEBRUARY,
        4  : 30,
        6  : 30,
        9  : 30,
        11 : 30,
        }.get(int(month), 31)

def GetDayAndMonthFromDayInYear(year, dayInYear):
    month = ISO.FIRST_MONTH_IN_YEAR
    for i in range(ISO.FIRST_MONTH_IN_YEAR, ISO.MONTHS_A_YEAR+1):
        daysInMonth = GetDaysInMonth(year, i)
        if dayInYear <= daysInMonth : break
        month += 1
        dayInYear -= daysInMonth
    dayInMonth = int(dayInYear)
    if month>12 :
        month = (month % 12)
        year += 1
    return [year, month, dayInMonth]

def GetNumberOfWeeksInYear(year): 
    jan1DayOfWeek = GetDayOfTheWeek(year, 1, 1)                    
    return 53 if ((jan1DayOfWeek == 4) or (jan1DayOfWeek == 3 and (IsALeapYear(year)))) else 52

def GetDayOfTheWeek(year, month, day):
    month = int(month)
    day   = int(day)
    t = [0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4]
    year -= (month < 3)
    result = int(year + year/4 - year/100 + year/400 + t[month-1] + day) % 7
    if result == 0: 
        result=7
    return result

def GetDayOfTheYear(year, month, day):
    month = int(month)
    day   = int(day)
    ordinal_day = 0
    for i in range(1, month): 
        ordinal_day += GetDaysInMonth(year, i)
    ordinal_day += day
    return ordinal_day

def GetWeekOfTheYear(year, month, day):
    month = int(month)
    day   = int(day)
    weeknum = int(math.floor((GetDayOfTheYear(year, month, day) - GetDayOfTheWeek(year, month, day) + 10)/7))
    return weeknum

def GetDayDelta(start_year, start_month, start_day, end_year, end_month, end_day):
    start_DoY = GetDayOfTheYear(start_year, start_month, start_day)
    end_DoY   = GetDayOfTheYear(end_year, end_month, end_day)
    start     = min(start_year, end_year)
    end       = max(start_year, end_year)
    delta_day = 0 
    for i in range(start, end): 
        delta_day += GetDaysInYear(i)
    if start_year == start :
        delta_day += end_DoY - start_DoY
        return delta_day
    else :
        delta_day += start_DoY - end_DoY
        return -delta_day

def GetDeltaDay(start_year, start_month, start_day, delta):
    start_DoY = GetDayOfTheYear(start_year, start_month, start_day)
    if delta>=0 :
        day_left = GetDaysInYear(start_year) - start_DoY 
        end_year = start_year
        day_cnt = day_left  
        i = 0
        while (day_cnt < delta):
            i += 1
            day_cnt += GetDaysInYear(start_year + i)
        end_year = start_year + i
        day_left = GetDaysInYear(end_year) - (day_cnt-delta)
    else :
        day_left = -start_DoY 
        end_year = start_year -1
        day_cnt  = day_left  
        i = 0
        while (day_cnt >= delta):
            i += 1
            day_cnt -= GetDaysInYear(start_year - i)
        end_year = start_year - i
        day_left = -(day_cnt-delta)
    temp = GetDayAndMonthFromDayInYear(end_year, day_left)
    end_month = temp[1]
    end_day = temp[2]
    end_week = GetWeekOfTheYear(end_year, end_month, end_day)
    return [end_year, end_month, end_day, end_week]

def GetNextWeek(start_year, start_week, delta):
    total_week = GetNumberOfWeeksInYear(start_year)
    week_exceed = start_week + delta - total_week
    end_week = week_exceed if (week_exceed>0) else (start_week+delta)
    end_year = start_year + (week_exceed>0)
    return [end_year, end_week]

def GetNextDay(start_year, start_month, start_day, delta):
    total_day = GetDaysInMonth(start_year, start_month)
    day_exceed = start_day + delta - total_day
    end_day = day_exceed if (day_exceed>0) else (start_day+delta)
    end_month = 1 if ((start_month==12) and (day_exceed>0)) else (start_month+(day_exceed>0))
    end_year = start_year if (end_month>=start_month) else (start_year+1)
    return [end_year, end_month, end_day]

