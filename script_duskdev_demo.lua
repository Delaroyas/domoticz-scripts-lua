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

--print('Delaroyas a ecrit dans le log')

commandArray = {}
--device=getDevice()
        local device = ""
        for i, v in pairs(devicechanged) do
                if (#device == 0 or #i < #device) then device = i end
        end

status= devicechanged[device]
level= tonumber(otherdevices_svalues[device])
newlevel=100;


if (device=='Dimmer Olivia') then
	curdt=os.date('*t')
	midnightdt={year = curdt.year, month = curdt.month, day = curdt.day, hour = 0, min = 0, sec = 0}
	t=os.difftime(os.time(curdt),  os.time(midnightdt)) -- number of secconds since Midnight
	t=t/60/60 -- number of hours since midnight
	curfew=16
	delay=1/3
	
	delta=t-curfew
	if (delta>delay) then
		if not (status == 'Off') then
			commandArray['Dimmer Olivia']='Off'
		end
	elseif (delta>0) then
		newlevel = (1 - delta/delay)*100
	end

	print(device .. ' vaut '.. status..','..level ..' coucher: '.. delta)
	if (level > newlevel) then
		commandArray['Dimmer Olivia']='Set Level '..newlevel
	end
end
return commandArray


