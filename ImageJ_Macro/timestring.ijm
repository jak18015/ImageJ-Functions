macro "timestring" {
	// get date for organization
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timestring = ""+year+"";
	if (month < 10) {
		timestring = timestring+"-0"+(month+1);
	} else {timestring = timestring+"-"+(month+1);
	}
	
	if (dayOfMonth<10) {
		timestring = timestring+"-0"+dayOfMonth;
	} else {timestring = timestring+"-"+dayOfMonth;
	}
return timestring;
}