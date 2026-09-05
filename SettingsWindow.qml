pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Material
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

ApplicationWindow {
  id: window
  title: "Spotlight Settings"
  width: 1080
  height: 760
  minimumWidth: 900
  minimumHeight: 480
  visible: false
  transientParent: null
  flags: Qt.Dialog | Qt.WindowTitleHint | Qt.WindowCloseButtonHint
  color: "#202124"
  Material.theme: Material.Dark
  Material.primary: "#9aaec8"
  Material.accent: "#b8c8df"
  Material.foreground: "#f1f3f7"
  Material.background: "#202124"
  font.family: "Adwaita Sans"
  font.pixelSize: 14
  palette.window: "#202124"
  palette.windowText: "#f5f5f7"
  palette.base: "#303136"
  palette.alternateBase: "#28292e"
  palette.text: "#f5f5f7"
  palette.button: "#393a40"
  palette.buttonText: "#f5f5f7"
  palette.highlight: "#62666f"
  palette.highlightedText: "#ffffff"

  property var settingsModel
  property string status: "Changes save automatically"
  property bool failed: false
  property int sectionIndex: 0
  signal updateRequested(var patch)
  signal resetRequested()
  signal previewRequested()
  readonly property var values: settingsModel ? settingsModel.snapshot() : ({})

  function openSettings() {
    visible = true
    raise()
    requestActivate()
  }
  function save(key, value) {
    var patch = {}; patch[key] = value
    updateRequested(patch)
  }
  function report(json) {
    var result = JSON.parse(json)
    failed = !result.ok
    status = result.ok ? "Saved" : result.error
  }

  Shortcut { sequence: "Escape"; onActivated: window.close() }

  ColorDialog {
    id: colorPicker
    property string settingKey: ""
    title: "Choose a color"
    options: ColorDialog.ShowAlphaChannel
    onAccepted: window.save(settingKey, selectedColor.toString())
  }

  component SliderRow: ColumnLayout {
    id: sliderRow
    property string settingKey
    property string label
    property string suffix: ""
    Layout.fillWidth: true
    spacing: 5

    RowLayout {
      Layout.fillWidth: true
      Label { text: sliderRow.label; Layout.fillWidth: true }
      Label {
        text: Math.round(slider.value) + sliderRow.suffix
        color: "#aeb3bf"
        horizontalAlignment: Text.AlignRight
        Layout.minimumWidth: 58
      }
    }

    Slider {
      id: slider
      Layout.fillWidth: true
      Accessible.name: sliderRow.label
      from: window.settingsModel ? window.settingsModel.limits[sliderRow.settingKey][0] : 0
      to: window.settingsModel ? window.settingsModel.limits[sliderRow.settingKey][1] : 100
      stepSize: 1
      value: window.values[sliderRow.settingKey] || 0
      live: true
      background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 6
        radius: 3
        color: "#343841"
        Rectangle {
          width: slider.visualPosition * parent.width
          height: parent.height
          radius: 3
          color: "#b9c7da"
        }
      }
      handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 20
        height: 20
        radius: 10
        color: slider.pressed ? "#ffffff" : "#e5ebf5"
        border.color: "#8d99ad"
        border.width: 1
      }
      onMoved: window.save(sliderRow.settingKey, Math.round(value))
    }
  }

  component TextRow: ColumnLayout {
    id: textRow
    property string settingKey
    property string label
    Layout.fillWidth: true
    spacing: 6
    Label { text: textRow.label }
    TextField {
      Layout.fillWidth: true
      Accessible.name: textRow.label
      text: window.values[textRow.settingKey] || ""
      selectByMouse: true
      maximumLength: 100
      onEditingFinished: if (text !== window.values[textRow.settingKey]) window.save(textRow.settingKey, text)
    }
  }

  component ColorRow: RowLayout {
    id: colorRow
    property string settingKey
    property string label
    Layout.fillWidth: true
    spacing: 12
    Label { text: colorRow.label; Layout.fillWidth: true }
    Button {
      Accessible.name: "Choose " + colorRow.label.toLowerCase()
      Layout.preferredWidth: 42
      Layout.preferredHeight: 34
      contentItem: Rectangle {
        radius: 5
        color: window.values[colorRow.settingKey] || "transparent"
        border.width: 1
        border.color: "#808080"
      }
      onClicked: {
        colorPicker.settingKey = colorRow.settingKey
        colorPicker.selectedColor = window.values[colorRow.settingKey]
        colorPicker.open()
      }
    }
    TextField {
      Layout.preferredWidth: 130
      Accessible.name: colorRow.label + " hex color"
      text: window.values[colorRow.settingKey] || ""
      selectByMouse: true
      maximumLength: 9
      onEditingFinished: if (text !== window.values[colorRow.settingKey]) window.save(colorRow.settingKey, text)
    }
  }

  ColumnLayout {
    anchors.fill: parent
    anchors.rightMargin: 24
    anchors.leftMargin: 248
    anchors.margins: 24
    spacing: 18

    RowLayout {
      Layout.fillWidth: true
      Item { Layout.fillWidth: true }
      Button { text: "Preview Spotlight"; onClicked: window.previewRequested() }
      Button { text: "Done"; onClicked: window.close() }
    }

    ScrollView {
      id: scroll
      Layout.fillWidth: true
      Layout.fillHeight: true
      clip: true
      contentWidth: availableWidth
      ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

      ColumnLayout {
        width: scroll.availableWidth
        spacing: 14

        ColumnLayout {
          visible: window.sectionIndex === 0
          Layout.fillWidth: true
          spacing: 10
          Label { text: "Size and spacing for the centered launcher."; color: "#a9abb3" }
          SliderRow { settingKey: "width"; label: "Panel width"; suffix: " px" }
          SliderRow { settingKey: "radius"; label: "Corner radius"; suffix: " px" }
          SliderRow { settingKey: "padding"; label: "Inner padding"; suffix: " px" }
          SliderRow { settingKey: "headerHeight"; label: "Search field height"; suffix: " px" }
          SliderRow { settingKey: "rowHeight"; label: "Result height"; suffix: " px" }
          SliderRow { settingKey: "detailRowHeight"; label: "Result height with description"; suffix: " px" }
          SliderRow { settingKey: "rowSpacing"; label: "Space between results"; suffix: " px" }
          SliderRow { settingKey: "maxResultsHeight"; label: "Maximum results height"; suffix: " px" }
          Label { text: "Result behavior"; font.weight: Font.Medium }
          ComboBox {
            Layout.fillWidth: true
            model: ["Expanded — show results", "Collapsed — search first"]
            currentIndex: (window.values.resultBehavior || "expanded") === "collapsed" ? 1 : 0
            onActivated: window.save("resultBehavior", currentIndex === 1 ? "collapsed" : "expanded")
          }
        }

        ColumnLayout {
          visible: window.sectionIndex === 1
          Layout.fillWidth: true
          spacing: 12
          Label { text: "Tune the search field and result rows."; color: "#a9abb3" }
          Label { text: "Font family"; font.weight: Font.Medium }
          ComboBox {
            id: fontFamilyBox
            Layout.fillWidth: true
            editable: true
            model: ["Adwaita Sans", "Iosevka Nerd Font", "sans-serif", "monospace"]
            currentIndex: model.indexOf(window.values.fontFamily || "Adwaita Sans")
            editText: window.values.fontFamily || "Adwaita Sans"
            onAccepted: window.save("fontFamily", editText)
          }
          TextRow { settingKey: "placeholder"; label: "Search placeholder" }
          SliderRow { settingKey: "searchFontSize"; label: "Search text size"; suffix: " px" }
          SliderRow { settingKey: "resultFontSize"; label: "Result text size"; suffix: " px" }
          SliderRow { settingKey: "detailFontSize"; label: "Description text size"; suffix: " px" }
          SliderRow { settingKey: "iconSize"; label: "Icon size"; suffix: " px" }
          SliderRow { settingKey: "searchIconSize"; label: "Search icon size"; suffix: " px" }
          SliderRow { settingKey: "resultInnerPadding"; label: "Result inner padding"; suffix: " px" }
          SliderRow { settingKey: "selectionRadius"; label: "Selected result radius"; suffix: " px" }
          CheckBox {
            text: "Show result icons"
            checked: window.values.showIcons === true
            onToggled: window.save("showIcons", checked)
          }
        }

        ColumnLayout {
          visible: window.sectionIndex === 2
          Layout.fillWidth: true
          spacing: 12
          Label { text: "Choose a surface mode and tune its colors."; color: "#a9abb3" }
          Label { text: "Panel style"; font.weight: Font.Medium }
          ComboBox {
            id: colorModeBox
            Layout.fillWidth: true
            model: ["Wallpaper", "Monochrome", "Grey"]
            currentIndex: ["wallpaper", "monochrome", "grey"].indexOf(window.values.colorMode || "monochrome")
            onActivated: window.save("colorMode", ["wallpaper", "monochrome", "grey"][currentIndex])
          }
          SliderRow { settingKey: "transparency"; label: "Transparency"; suffix: "%" }
          ColorRow { settingKey: "background"; label: "Panel background" }
          ColorRow { settingKey: "foreground"; label: "Text" }
          ColorRow { settingKey: "borderColor"; label: "Border" }
          ColorRow { settingKey: "selectionColor"; label: "Selected result" }
          ColorRow { settingKey: "selectionTextColor"; label: "Selected text" }
          ColorRow { settingKey: "selectionBorderColor"; label: "Selected border" }
          Label {
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: "Click a swatch to choose a color and transparency."
            color: "#a9abb3"
          }
        }

        ColumnLayout {
          visible: window.sectionIndex === 3
          Layout.fillWidth: true
          spacing: 16
          Label {
            Layout.fillWidth: true
            text: "A compact, keyboard-first launcher styled after macOS Spotlight for Omarchy."
            color: "#a9abb3"
            wrapMode: Text.WordWrap
          }
          Rectangle { Layout.fillWidth: true; height: 1; color: "#28ffffff" }
          Label { text: "Included"; color: "#d7dde8"; font.weight: Font.Medium }
          Label { text: "• Centered Spotlight overlay"; color: "#a9abb3" }
          Label { text: "• Native application icons"; color: "#a9abb3" }
          Label { text: "• Keyboard navigation and search"; color: "#a9abb3" }
          Label { text: "• Wallpaper, monochrome, and grey modes"; color: "#a9abb3"; wrapMode: Text.WordWrap }
          Rectangle { Layout.fillWidth: true; height: 1; color: "#28ffffff" }
          Label { text: "Shortcuts"; color: "#d7dde8"; font.weight: Font.Medium }
          Label { text: "Super + Space    Open Spotlight"; color: "#a9abb3" }
          Label { text: "Super + Alt + Space    Open Apps"; color: "#a9abb3" }
          Label { text: "Ctrl + ,    Open Settings"; color: "#a9abb3" }
          Label { text: "Esc    Clear or close"; color: "#a9abb3" }
          Rectangle { Layout.fillWidth: true; height: 1; color: "#28ffffff" }
          Label { text: "Plugin details"; color: "#d7dde8"; font.weight: Font.Medium }
          Label { text: "stash.menu  ·  v1.2.0"; color: "#a9abb3" }
          Label { text: "Settings.qml + Menu.qml"; color: "#8f98a8" }
        }
      }
    }

    RowLayout {
      Layout.fillWidth: true
      Button { text: "Reset to defaults"; onClicked: window.resetRequested() }
      Label {
        text: window.status
        color: window.failed ? "#ffaca6" : "#a9abb3"
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignRight
        wrapMode: Text.WordWrap
      }
    }
  }

  // Category navigation keeps each section focused and makes About part of
  // the same settings flow as the editable controls.
  Rectangle {
    id: categorySidebar
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.bottom: parent.bottom
    anchors.margins: 24
    width: 200
    radius: 14
    color: "#1821262c"
    border.color: "#2dffffff"
    border.width: 1

    ColumnLayout {
      anchors.fill: parent
      anchors.margins: 12
      spacing: 6
      Label { text: "SETTINGS"; color: "#858c9a"; font.pixelSize: 11; font.weight: Font.DemiBold; leftPadding: 10; bottomPadding: 8 }
      Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 42; radius: 9
        color: window.sectionIndex === 0 ? "#3f444d" : "transparent"
        RowLayout {
          anchors.fill: parent; anchors.leftMargin: 10; spacing: 10
          Label { text: "⌘"; color: "#dce2eb"; font.pixelSize: 17 }
          Label { text: "Layout"; color: "#f0f2f6"; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; onClicked: window.sectionIndex = 0 }
      }
      Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 42; radius: 9
        color: window.sectionIndex === 1 ? "#3f444d" : "transparent"
        RowLayout {
          anchors.fill: parent; anchors.leftMargin: 10; spacing: 10
          Label { text: "A"; color: "#dce2eb"; font.pixelSize: 16; font.weight: Font.DemiBold }
          Label { text: "Text & Icons"; color: "#f0f2f6"; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; onClicked: window.sectionIndex = 1 }
      }
      Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 42; radius: 9
        color: window.sectionIndex === 2 ? "#3f444d" : "transparent"
        RowLayout {
          anchors.fill: parent; anchors.leftMargin: 10; spacing: 10
          Label { text: "◐"; color: "#dce2eb"; font.pixelSize: 17 }
          Label { text: "Appearance"; color: "#f0f2f6"; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; onClicked: window.sectionIndex = 2 }
      }
      Item { Layout.preferredHeight: 12 }
      Label { text: "PROJECT"; color: "#858c9a"; font.pixelSize: 11; font.weight: Font.DemiBold; leftPadding: 10; bottomPadding: 8 }
      Rectangle {
        Layout.fillWidth: true; Layout.preferredHeight: 42; radius: 9
        color: window.sectionIndex === 3 ? "#3f444d" : "transparent"
        RowLayout {
          anchors.fill: parent; anchors.leftMargin: 10; spacing: 10
          Label { text: "ⓘ"; color: "#dce2eb"; font.pixelSize: 16 }
          Label { text: "About"; color: "#f0f2f6"; Layout.fillWidth: true }
        }
        MouseArea { anchors.fill: parent; onClicked: window.sectionIndex = 3 }
      }
      Item { Layout.fillHeight: true }
      Label { text: "stash.menu"; color: "#858c9a"; font.pixelSize: 11; leftPadding: 10 }
    }
  }
}
