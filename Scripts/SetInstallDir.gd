extends HBoxContainer

@onready var _fd = $"Browse/FileDialog"
@onready var _dir = $"LineEdit"

func _ready() -> void:
	if Config.installDir != null:
		_dir.text = Config.installDir

func _on_browse_pressed() -> void:
	_fd.visible = true

func _on_file_dialog_dir_selected(dir: String) -> void:
	_dir.text = dir
	Config.saveConfig("InstallInfo", "InstallDir", dir)
