extends RefCounted

class_name DeviceInfo

# DisplayServer.is_touchscreen_available() also returns true when "emulate touch from
# mouse" is enabled, so it reports a touchscreen on every desktop and browser and cannot
# be used to detect a device. Ask the platform instead: the "mobile" feature tag on
# Android/iOS, and the browser itself on web.
static func is_touch_device() -> bool:
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("'ontouchstart' in window || (navigator.maxTouchPoints > 0)", true))
	return OS.has_feature("mobile")
