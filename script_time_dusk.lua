-- demo device script
-- script names have three name components: script_trigger_name.lua
-- trigger can be 'time' or 'device', name can be any string
-- domoticz will execute all time and device triggers when the relevant trigger occurs
-- 
-- copy this script and change the "name" part, all scripts named "demo" are ignored. 
--
-- Make sure the encoding is UTF8 of the file
--
-- ingests tables: devicechanged, otherdevices,otherdevices_svalues
--
-- device changed contains state and svalues for the device that changed.
--   devicechanged['yourdevicename']=state 
--   devicechanged['svalues']=svalues string 
--
-- otherdevices and otherdevices_svalues are arrays for all devices: 
--   otherdevices['yourotherdevicename']="On"
--	otherdevices_svalues['yourotherthermometer'] = string of svalues
--
-- Based on your logic, fill the commandArray with device commands. Device name is case sensitive. 
--
-- Always, and I repeat ALWAYS start by checking for the state of the changed device.
-- If you would only specify commandArray['AnotherDevice']='On', every device trigger will switch AnotherDevice on, which will trigger a device event, which will switch AnotherDevice on, etc. 
--
-- The print command will output lua print statements to the domoticz log for debugging.
-- List all otherdevices states for debugging: 
--   for i, v in pairs(otherdevices) do print(i, v) end
-- List all otherdevices svalues for debugging: 
--   for i, v in pairs(otherdevices_svalues) do print(i, v) end
--
-- TBD: nice time example, for instance get temp from svalue string, if time is past 22.00 and before 00:00 and temp is bloody hot turn on fan. 


commandArray = {}


-- Get curent status 'On' 'Off' 'Set Level'

dimmers={}

dimmers['Dimmer Olivia']={}
dimmers['Dimmer Olivia'].curfew=20.833333333
dimmers['Dimmer Olivia'].delay=20/60
dimmers['Dimmer Olivia'].wakeup=8.50
dimmers['Dimmer Olivia'].max=100

dimmers['Dimmer Parents']={}
dimmers['Dimmer Parents'].curfew=25
dimmers['Dimmer Parents'].delay=4/60
dimmers['Dimmer Parents'].wakeup=12+35/60
dimmers['Dimmer Parents'].max=50


-- Get time in hours since 00:00
	curdt=os.date('*t') --now
	midnightdt={year = curdt.year, month = curdt.month, day = curdt.day, hour = 0, min = 0, sec = 0}
	t=os.difftime(os.time(curdt),  os.time(midnightdt)) -- number of seconds since Midnight
	t=t/60/60 -- number of hours since midnight

for device,props in pairs(dimmers) do 
	status= otherdevices[device]
	level= tonumber(otherdevices_svalues[device])

	-- Measure time since curfiew
	delta=t-props.curfew

	-- Measure time since wakeup
	deltaW=t-props.wakeup

	-- If it is sill early
	if (deltaW<0) then
		--still nighttime, do notthing
	elseif (deltaW<props.delay) then
		newlevel = (deltaW/props.delay)*props.max
		-- Increase light if needed
		if (level < newlevel) then
			commandArray[device]='Set Level '..newlevel
		end
	--elseif (deltaW>delay) then
		
	
	-- If lightout time is passed
	elseif (delta>props.delay) then
		-- Turn off light if needed
		if not (status == 'Off') then
			commandArray[device]='Off'
		end
	-- If curfew is passed
	elseif (delta>0) then
		-- Measure expected level
		newlevel = (1 - delta/props.delay)*props.max
		-- Dimm light if needed
		if (level > newlevel) then
			commandArray[device]='Set Level '..newlevel
		end
	end
	
	
   --print(device .. ' vaut '.. status..':'..level ..', heure: '.. t ..', lever: '.. deltaW..', coucher: '.. delta)

end
return commandArray

