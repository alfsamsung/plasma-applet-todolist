import QtQuick
import org.kde.plasma.plasma5support as P5Support

// Stand-in for the Note object from org.kde.plasma.private.notes, which
// Plasma 6 no longer installs as an importable QML module (the Notes widget
// now compiles it into its own applet plugin). Same file location and format
// as before: $XDG_DATA_HOME/plasma_notes/<noteId>, plain markdown, so a list
// can still be opened in a text editor.
Item {
	id: fileNote

	property string noteId: ''
	property string noteText: ''

	// Writes stay disabled until the first read succeeds, so a failed or
	// still-pending read can never overwrite the file with an empty list.
	property bool loaded: false

	readonly property string _dir: '"${XDG_DATA_HOME:-$HOME/.local/share}/plasma_notes"'

	function _quote(s) {
		return "'" + String(s).replace(/'/g, "'\\''") + "'"
	}

	property int _seq: 0
	property var _callbacks: ({})
	function _run(cmd, callback) {
		_seq += 1
		// The suffix keeps each source name unique, so two identical commands
		// in flight don't collapse into one DataSource source.
		var source = cmd + ' #todolist' + _seq
		_callbacks[source] = callback
		executable.connectSource(source)
	}

	P5Support.DataSource {
		id: executable
		engine: 'executable'
		connectedSources: []
		onNewData: function(sourceName, data) {
			disconnectSource(sourceName)
			var callback = fileNote._callbacks[sourceName]
			delete fileNote._callbacks[sourceName]
			if (callback) {
				callback(data['exit code'], data.stdout, data.stderr)
			}
		}
	}

	function reload() {
		var wanted = noteId
		if (!wanted) {
			return
		}
		var cmd = 'f=' + _dir + '/' + _quote(wanted) + '; if [ -e "$f" ]; then cat -- "$f"; fi'
		_run(cmd, function(exitCode, stdout, stderr) {
			if (wanted !== fileNote.noteId) {
				return // noteId changed while this read was in flight
			}
			if (exitCode != 0) {
				console.warn('[todolist] reading note', wanted, 'failed, exit', exitCode, '- saving disabled:', stderr)
				return
			}
			fileNote.loaded = true
			fileNote.noteText = stdout
		})
	}

	function save(text) {
		if (!loaded) {
			console.warn('[todolist] note', noteId, 'not loaded yet; refusing to save')
			return
		}
		noteText = text
		var cmd = 'd=' + _dir + '; f="$d/"' + _quote(noteId)
			+ '; mkdir -p "$d" && printf %s ' + _quote(text) + ' > "$f.tmp.$$" && mv -f -- "$f.tmp.$$" "$f"'
		_run(cmd, function(exitCode, stdout, stderr) {
			if (exitCode != 0) {
				console.warn('[todolist] saving note failed, exit', exitCode, ':', stderr)
			}
		})
	}

	onNoteIdChanged: {
		loaded = false
		reload()
	}
	Component.onCompleted: reload()
}
