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

# Narrower than is_touch_device(): a phone or tablet, as opposed to any device with a
# touchscreen. Touchscreen laptops stay out so they keep their keyboard instructions.
# "web_android"/"web_ios" are custom feature tags that no export preset sets, so the
# user agent is what actually identifies a phone browser.
static func is_mobile_platform() -> bool:
	if OS.has_feature("mobile") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return true
	if OS.has_feature("web"):
		return bool(JavaScriptBridge.eval("/Android|iPhone|iPad|iPod/i.test(navigator.userAgent)", true))
	return false
