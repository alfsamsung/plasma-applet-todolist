import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support 2.0 as P5Support
import org.kde.kirigami as Kirigami

PlasmoidItem {
	id: main

	NoteItem {
		id: noteItem
	}

	Plasmoid.icon: plasmoid.configuration.icon

	compactRepresentation: MouseArea {
		readonly property bool inPanel: [
			PlasmaCore.Types.TopEdge,
			PlasmaCore.Types.RightEdge,
			PlasmaCore.Types.BottomEdge,
			PlasmaCore.Types.LeftEdge,
		].includes(Plasmoid.location)

		acceptedButtons: Qt.LeftButton

		Layout.minimumWidth: {
			switch (Plasmoid.formFactor) {
			case PlasmaCore.Types.Vertical:
				return 0
			case PlasmaCore.Types.Horizontal:
				return height
			default:
				return Kirigami.Units.gridUnit * 3
			}
		}

		Layout.minimumHeight: {
			switch (Plasmoid.formFactor) {
			case PlasmaCore.Types.Vertical:
				return width
			case PlasmaCore.Types.Horizontal:
				return 0
			default:
				return Kirigami.Units.gridUnit * 3
			}
		}
		Layout.preferredWidth: Layout.minimumWidth
		Layout.preferredHeight: Layout.minimumHeight

		hoverEnabled: true

		Kirigami.Icon {
			id: icon
			anchors.fill: parent
			source: Plasmoid.icon
		}

		IconCounterOverlay {
			anchors.fill: parent
			text: noteItem.hasIncomplete ? noteItem.incompleteCount : "✓"
			visible: {
				if (plasmoid.configuration.showCounter == 0) {
					return false
				} else if (plasmoid.configuration.showCounter == 1) {
					return noteItem.hasIncomplete
				} else { // 'Always'
					return true
				}
			}
			heightRatio: plasmoid.configuration.bigCounter ? 1 : 0.5
		}

		onClicked: main.expanded = !main.expanded
	}

	fullRepresentation: FullRepresentation {
		isDesktopContainment: Plasmoid.location == PlasmaCore.Types.Floating
		Plasmoid.backgroundHints: {
			if (isDesktopContainment && !plasmoid.configuration.showBackground)
				return PlasmaCore.Types.NoBackground
			else if (isDesktopContainment && plasmoid.configuration.showBackground)
				return PlasmaCore.Types.DefaultBackground
			else if (!isDesktopContainment)  //on panel
				return PlasmaCore.Types.TranslucentBackground | PlasmaCore.Types.ConfigurableBackground
		}
        focus: true

	// 	 Connections {
	// 	 	target: plasmoid
	// 	 	onExpandedChanged: {
	// 	 		if (!expanded) {
	// 	 			updateVisibleItems()
	// 	 		}
	// 	 	}
	// 	 }
	}

	P5Support.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: disconnectSource(sourceName)
	}
	function exec(cmd) {
		executable.connectSource(cmd)
	}

	Plasmoid.contextualActions: [
		PlasmaCore.Action {
			text: i18n("Open in Text Editor")
			icon.name: "accessories-text-editor"
			onTriggered: exec("xdg-open ~/.local/share/plasma_notes/" + plasmoid.configuration.noteId)
		},
		PlasmaCore.Action {
			text: i18n("Add List")
			icon.name: "list-add"
			onTriggered: noteItem.addSection()
		},
		PlasmaCore.Action {
			text: i18n("Delete on Complete")
			icon.name: "checkmark"
			checkable: true
            checked: plasmoid.configuration.deleteOnComplete
			onTriggered: plasmoid.configuration.deleteOnComplete = !plasmoid.configuration.deleteOnComplete
		},
		PlasmaCore.Action {
			text: i18n("Hide")
			icon.name: "checkmark"
			checkable: true
            checked: plasmoid.configuration.hidden
			onTriggered: plasmoid.configuration.hidden = !plasmoid.configuration.hidden
		}
	]

//	Component.onCompleted: {
//		updateContextMenu()
//	}

}
