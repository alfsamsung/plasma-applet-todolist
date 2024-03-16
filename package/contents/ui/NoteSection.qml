import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs // MessageDialog
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.draganddrop as DragAndDrop
import org.kde.ksvg as KSvg

ColumnLayout {
	id: container
	Layout.fillWidth: true
	Layout.fillHeight: true
	spacing: 0

	property int contentHeight: textField.height + container.spacing + noteListView.contentHeight
	
	property var noteSection: noteItem.sectionList[index]

	MouseArea {
		id: labelMouseArea
		Layout.fillWidth: true
		Layout.preferredHeight: labelRow.height
		hoverEnabled: true
		cursorShape: Qt.WhatsThisCursor  //OpenHandCursor

		DropArea {
			id: noteSectionDropArea
			anchors.fill: parent
			z: -1
			// anchors.margins: 10

			onDropped: {
				// console.log('noteSectionDropArea.onDropped', drag.source.dragSectionIndex, index)
				if (typeof drag.source.dragSectionIndex === "number") {
					// swap drag.source.dragNoteIndex and labelRow.dragNoteIndex
					noteItem.moveSection(drag.source.dragSectionIndex, labelRow.dragSectionIndex)
				}
			}

			Rectangle {
				anchors.fill: parent
				color: parent.containsDrag ? "#88336699" : "transparent"
			}
		}

		RowLayout {
			id: labelRow
			anchors.left: parent.left
			anchors.right: parent.right
			spacing: 0
			
			property int dragSectionIndex: index

			DragAndDrop.DragArea {
				id: dragArea
				Layout.fillHeight: true
				Layout.preferredWidth: 30 * Kirigami.Units.devicePixelRatio // Same width as drag area in todoItem

				delegate: labelRow

				KSvg.FrameSvgItem {
					visible: labelMouseArea.containsMouse && !noteSectionDropArea.containsDrag
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.top: parent.top
					anchors.bottom: parent.bottom
					width: parent.width / 2
					imagePath: Qt.resolvedUrl("../images/dragarea.svg")
				}
			}

			PlasmaComponents3.TextField {
				id: textField
				Layout.leftMargin:  Kirigami.Units.iconSizes.smallMedium * 2
				text: noteSection.label
				background: null
				font.pointSize: -1
				font.pixelSize: pinButton.height - 4
				font.weight: plasmoid.configuration.listTitleBold ? Font.Bold : Font.Normal
				implicitHeight: contentHeight
				leftPadding: - 3
				topPadding: 0
				bottomPadding: 0
				topInset: 0


				onEditingFinished: {
					noteSection.label = text
					text = Qt.binding(function() { return noteSection.label })
				}

				// PlasmaComponents3.Label {
				// 	id: textOutline
				// 	anchors.fill: parent
				// 	visible: false
				// 	visible: !textField.usingPlasmaStyle && plasmoid.configuration.listTitleOutline
				// 	text: parent.text
				// 	font.pointSize: -1
				// 	font.pixelSize: pinButton.height
				// 	font.weight: plasmoid.configuration.listTitleBold ? Font.Bold : Font.Normal
				// 	color: "transparent"
				// 	style: Text.Outline
				// 	styleColor: Kirigami.Theme.backgroundColor
				// 	verticalAlignment: Text.AlignVCenter
				// }

			}
		}

		PlasmaComponents3.ToolButton {
			anchors.right: labelRow.right
			readonly property bool isRightMostSection: index == notesRepeater.count-1
			anchors.rightMargin: isRightMostSection && pinButton.visible ? pinButton.width : 0
			anchors.verticalCenter: labelRow.verticalCenter
			visible: notesRepeater.count > 1 && labelMouseArea.containsMouse && !noteSectionDropArea.containsDrag
			icon.name: "delete"
			text: i18n("Delete")
			onClicked: promptDeleteLoader.show()

			Loader {
				id: promptDeleteLoader
				active: false

				function show() {
					if (item) {
						item.visible = true
					} else {
						active = true
					}
				}

				sourceComponent: Component {
					MessageDialog {
						// visible: true
						title: i18n("Delete List")
						text: i18n("Are you sure you want to delete the list \"%1\" with %2 items?", noteSection.label || ' ', Math.max(0, noteSection.model.count - 1))
						buttons: MessageDialog.Ok | MessageDialog.Cancel
						onButtonClicked: function (button, role) {
							switch (button) {
							case MessageDialog.Ok:
								noteItem.removeSection(index)
								break;
							}
						}
						Component.onCompleted: visible = true
					}
				}
			}
		}
	}

	ScrollView {
		Layout.fillWidth: true
		Layout.fillHeight: true

		NoteListView {
			id: noteListView
			model: noteSection.model
		}
	}
}
