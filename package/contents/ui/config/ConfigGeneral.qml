import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.ksvg as KSvg
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.iconthemes as KIconThemes

KCM.SimpleKCM {
	id: root
	property string cfg_icon: Plasmoid.configuration.icon
	property alias cfg_hidden: hidden.checked
	property alias cfg_showBackground: showBackground.checked
	property alias cfg_deleteOnComplete: deleteOnComplete.checked
	property alias cfg_listTitleBold: listTitleBold.checked
	property alias cfg_useGlobalNote: useGlobalNote.checked
	property alias cfg_fadeCompleted: fadeCompleted.checked
	property alias cfg_strikeoutCompleted: strikeoutCompleted.checked
	property alias cfg_showCounter: showCounter.currentIndex
	property alias cfg_bigCounter: bigCounter.checked
	property alias cfg_roundCounter: roundCounter.checked

	property string defaultValue: "view-list-symbolic"

	Kirigami.FormLayout {
		QQC2.Button {
			id: iconButton
			Kirigami.FormData.label: i18n("Icon:")
			hoverEnabled: true
			Accessible.name: i18nc("@action:button", "Change Application Launcher's icon")
			Accessible.description: i18nc("@info:whatsthis", "Current icon is %1. Click to open menu to change the current icon or reset to the default icon.", cfg_icon)
			Accessible.role: Accessible.ButtonMenu

			QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
			QQC2.ToolTip.text: i18nc("@info:tooltip", "Icon name is \"%1\"", cfg_icon)
			QQC2.ToolTip.visible: iconButton.hovered && cfg_icon.length > 0

			onPressed: iconMenu.opened ? iconMenu.close() : iconMenu.open()

			KIconThemes.IconDialog {
				id: iconDialog
				onIconNameChanged: cfg_icon = iconName || defaultValue
			}

			KSvg.FrameSvgItem {
				id: previewFrame
				anchors.centerIn: parent
				imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
						? "widgets/panel-background" : "widgets/background"
				width: Kirigami.Units.iconSizes.medium + fixedMargins.left + fixedMargins.right
				height: Kirigami.Units.iconSizes.medium + fixedMargins.top + fixedMargins.bottom

				Kirigami.Icon {
					anchors.centerIn: parent
					width: Kirigami.Units.iconSizes.medium
					height: Kirigami.Units.iconSizes.medium
					source: cfg_icon || defaultValue
				}
			}

			QQC2.Menu {
				id: iconMenu
				// Appear below the button
				y: +parent.height

				QQC2.MenuItem {
					text: i18nc("@item:inmenu Open icon chooser dialog", "Choose…")
					icon.name: "document-open-folder"
					onClicked: iconDialog.open()
				}
				QQC2.MenuItem {
					text: i18nc("@item:inmenu Reset icon to default", "Reset to default icon")
					icon.name: "edit-clear"
					enabled: cfg_icon !== ""
					onClicked: cfg_icon = defaultValue
				}
			}
		}

		Item {
            Kirigami.FormData.isSection: true
		}
		QQC2.Label {
			text: i18n("Widget settings")
			font.weight: Font.Bold
		}

		QQC2.CheckBox {
			id: 'hidden'
			text: i18n("Desktop Widget: Hide")
		}

		QQC2.CheckBox {
			id: "showBackground"
			text: i18n("Desktop Widget: Show background")
		}

		Item {
            Kirigami.FormData.isSection: true
		}
		QQC2.Label {
			text: i18n("Widget Title Style")
			font.weight: Font.Bold
		}

		QQC2.CheckBox {
			id: "listTitleBold"
			text: i18n("Bold")
		}

		Item {
				Kirigami.FormData.isSection: true
		}

		QQC2.Label {
			text: i18n("Note Filename")
			font.weight: Font.Bold
		}

	 	QQC2.CheckBox {
	 		id: 'useGlobalNote'
	 		text: i18n("Use Global Note")
	 	}

	 	RowLayout {
	 		QQC2.Label {
	 			text: i18n("Filename:")
	 		}
	 		QQC2.TextField {
	 			id: 'noteFilename'
	 			enabled: !useGlobalNote.checked

	 			// Keep in sync with NoteItem.qml
	 			placeholderText: {
	 				if (plasmoid.configuration.useGlobalNote) {
	 				return 'todolist'
	 				} else { // instanceNoteId
	 					return 'todolist_' + plasmoid.id
	 				}
	 			}
	 		}
	 	}

		Item {
            Kirigami.FormData.isSection: true
		}
		QQC2.Label {
			text: i18n("Completed Items")
			font.weight: Font.Bold
		}

		QQC2.CheckBox {
			id: 'deleteOnComplete'
			text: i18n("Delete On Complete")
		}

		QQC2.CheckBox {
			id: 'strikeoutCompleted'
			text: i18n("Strikeout")
		}

		QQC2.CheckBox {
			id: 'fadeCompleted'
			text: i18n("Faded")
		}

		Item {
            Kirigami.FormData.isSection: true
		}
		QQC2.Label {
			text: i18n("Counter style")
			font.weight: Font.Bold
		}

		 QQC2.ComboBox {
		 	id: 'showCounter'
		 	Kirigami.FormData.label: i18n("Show counter:")
		 	model: [i18n("Never"), i18n("Incomplete"), i18n("Always")]
		}

		QQC2.CheckBox {
			id: 'bigCounter'
			text: i18n("Use big counter")
		}

		QQC2.CheckBox {
			id: 'roundCounter'
			text: i18n("Use round counter")
		}
	}
}
