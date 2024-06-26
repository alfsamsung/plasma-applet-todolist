import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

FocusScope {
	id: fullRepresentation
	Layout.minimumWidth: Kirigami.Units.gridUnit * 10 * noteItem.numSections
	Layout.minimumHeight: Kirigami.Units.gridUnit * 10
	Layout.preferredWidth: Kirigami.Units.gridUnit * 20 * noteItem.numSections
	Layout.preferredHeight: Math.min(Math.max(Kirigami.Units.gridUnit * 20, maxContentHeight), Screen.desktopAvailableHeight) // Binding loop warning (meh).
	property int maxContentHeight: 0
	function updateMaxContentHeight() {
		var maxHeight = 0
		for (var i = 0; i < notesRepeater.count; i++) {
			var item = notesRepeater.itemAt(i)
			if (item) {
				if (!item.ready) {
					return // Not ready yet
				}
				maxHeight = Math.max(maxHeight, item.contentHeight)
			}
		}
		// console.log('maxContentHeight', maxHeight)
		maxContentHeight = maxHeight
	}

	property bool isDesktopContainment: false

	RowLayout {
		id: notesRow
		anchors.fill: parent

		opacity: plasmoid.configuration.hidden ? 0 : 1
		visible: opacity > 0

		Behavior on opacity {
			NumberAnimation { duration: 400 }
		}

		Repeater {
			id: notesRepeater
			model: noteItem.numSections

			NoteSection {
				id: container

				onContentHeightChanged: {
					// console.log('onContentHeightChanged', index, contentHeight)
					fullRepresentation.updateMaxContentHeight()
				}
			}
		}

	}

	PlasmaComponents3.ToolButton {
		id: pinButton
		anchors.top: parent.top
		anchors.right: parent.right
		width: Math.round(Kirigami.Units.gridUnit * 1.25)
		height: width
		checkable: true
		icon.name: "window-pin"
		onCheckedChanged: Plasmoid.hideOnWindowDeactivate = !checked
		visible: !isDesktopContainment
	}
}
