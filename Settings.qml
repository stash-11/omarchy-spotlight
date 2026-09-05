import QtQuick
import qs.Commons

QtObject {
  id: settings

  // Edit these defaults. IPC overrides are stored inline in shell.json.
  // `omarchy-shell spotlight reset` clears overrides to use these defaults.
  readonly property var defaults: ({
    width: 720,
    radius: 14,
    padding: 6,
    headerHeight: 56,
    rowHeight: 48,
    detailRowHeight: 60,
    rowSpacing: 2,
    maxResultsHeight: 340,
    resultBehavior: "expanded",
    fontFamily: "Adwaita Sans",
    searchFontSize: 22,
    resultFontSize: 15,
    detailFontSize: 12,
    iconSize: 28,
    searchIconSize: 22,
    resultSideInset: 0,
    resultInnerPadding: 6,
    selectionRadius: 9,
    showIcons: true,
    colorMode: "monochrome",
    transparency: 14,
    placeholder: "Search Everything",
    background: "#dc2f3033",
    foreground: "#f5f5f7",
    borderColor: "#606f7075",
    selectionColor: "#50727378",
    selectionTextColor: "#ffffff",
    selectionBorderColor: "#00000000"
  })

  property var overrides: ({})
  readonly property var limits: ({
    width: [320, 1200], radius: [0, 32], padding: [4, 32],
    headerHeight: [48, 96], rowHeight: [36, 80], detailRowHeight: [48, 100],
    rowSpacing: [0, 16], maxResultsHeight: [120, 800],
    searchFontSize: [14, 32], resultFontSize: [10, 22],
    detailFontSize: [9, 18], iconSize: [16, 48], searchIconSize: [18, 42],
    resultSideInset: [0, 32], resultInnerPadding: [4, 32], selectionRadius: [0, 28],
    transparency: [0, 80]
  })

  function validate(patch) {
    if (!patch || typeof patch !== "object" || Array.isArray(patch)) return "Expected a JSON object"
    for (var key in patch) {
      if (!Object.prototype.hasOwnProperty.call(defaults, key)) return "Unknown setting: " + key
      var v = patch[key]
      if (typeof v !== typeof defaults[key]) return "Wrong type for " + key
      if (key === "colorMode" && ["wallpaper", "monochrome", "grey"].indexOf(v) < 0)
        return "colorMode must be wallpaper, monochrome, or grey"
      if (key === "resultBehavior" && ["expanded", "collapsed"].indexOf(v) < 0)
        return "resultBehavior must be expanded or collapsed"
      if (limits[key] && (!isFinite(v) || Math.floor(v) !== v || v < limits[key][0] || v > limits[key][1]))
        return key + " must be an integer from " + limits[key][0] + " to " + limits[key][1]
      if (/^(background|foreground|borderColor|selectionColor|selectionTextColor|selectionBorderColor)$/.test(key)
          && !/^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(v)) return key + " requires #RRGGBB or #AARRGGBB"
      if (typeof v === "string" && (!v.trim() || v.length > 100)) return "Invalid text for " + key
    }
    return ""
  }

  function value(key) {
    if (!Object.prototype.hasOwnProperty.call(overrides, key)) return defaults[key]
    var one = {}; one[key] = overrides[key]
    return validate(one) ? defaults[key] : overrides[key]
  }

  function snapshot() {
    var result = {}
    for (var key in defaults) result[key] = value(key)
    result.background = backgroundColor()
    result.selectionColor = selectionBackgroundColor()
    result.selectionTextColor = selectionTextColorValue()
    result.foreground = foregroundColorValue()
    result.borderColor = borderColorValue()
    result.selectionBorderColor = selectionBorderColorValue()
    return result
  }

  function selectionBackgroundColor() {
    if (Object.prototype.hasOwnProperty.call(overrides, "selectionColor"))
      return value("selectionColor")
    return Color.menu.selectedBackground
  }

  function selectionTextColorValue() {
    if (Object.prototype.hasOwnProperty.call(overrides, "selectionTextColor")) return value("selectionTextColor")
    return Color.foreground
  }

  function foregroundColorValue() {
    if (Object.prototype.hasOwnProperty.call(overrides, "foreground")) return value("foreground")
    return Color.foreground
  }

  function borderColorValue() {
    if (Object.prototype.hasOwnProperty.call(overrides, "borderColor")) return value("borderColor")
    var mode = value("colorMode")
    if (mode === "wallpaper") return "#35ffffff"
    if (mode === "grey") return "#606c6d72"
    return "#605f6062"
  }

  function selectionBorderColorValue() {
    if (Object.prototype.hasOwnProperty.call(overrides, "selectionBorderColor")) return value("selectionBorderColor")
    return "#00000000"
  }

  function backgroundColor() {
    var mode = value("colorMode")
    var alpha = 1 - Number(value("transparency")) / 100
    var a = ("0" + Math.round(alpha * 255).toString(16)).slice(-2)
    if (mode === "wallpaper") return Qt.rgba(Color.menu.background.r, Color.menu.background.g, Color.menu.background.b, alpha)
    if (mode === "grey") return "#" + a + "3a3b3f"
    var gray = Math.round((Color.background.r * 0.299 + Color.background.g * 0.587 + Color.background.b * 0.114) * 255)
    var channel = ("0" + gray.toString(16)).slice(-2)
    return "#" + a + channel + channel + channel
  }
}
