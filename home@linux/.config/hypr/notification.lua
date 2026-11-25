---@alias Notification.method fun(text: string, timeout?: integer)
---@class Notification @Provides shortcuts for creating notifications with different icons
---@field none Notification.method @Creates a notification with no icon
---@field warning Notification.method @Creates a notification with the warning icon
---@field info Notification.method @Creates a notification with the info icon
---@field hint Notification.method @Creates a notification with the hint icon
---@field error Notification.method @Creates a notification with the error icon
---@field confused Notification.method @Creates a notification with the confused icon
---@field ok Notification.method @Creates a notification with the ok icon
---@field timeout integer @Default timeout for notifications
Notification = {
    timeout = 3000,
}

local Icons = {
    none = -1,
    warning = 0,
    info = 1,
    hint = 2,
    error = 3,
    confused = 4,
    ok = 5
}

for key, value in pairs(Icons) do
	Notification[key] = function(text, timeout)
		hl.notification.create({
			text = text,
			icon = value,
			timeout = timeout or Notification.timeout
		})
	end
end

---@alias ErrorFilter fun(err: string): boolean
---@param func function @Function to run with pcall
---@param err_filter? ErrorFilter @Function that returns whether to show the error notification
function Notification.try(func, err_filter)
    local ok, err = pcall(func)
    err_filter = err_filter or function () return true end

    if not ok and err_filter(err) then
        Notification.error(err, 2500)
    end
end