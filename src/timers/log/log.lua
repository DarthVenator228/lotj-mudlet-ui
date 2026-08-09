if not lotj.settings.logTimer then return end
local name, port, connected = getConnectionInfo()
if not connected then return end

local time = getTime()

if time.hour == 0 then
  eventEndLogging()
  eventStartLogging()
end
