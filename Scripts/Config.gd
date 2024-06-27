extends Node

var conf = ConfigFile.new()
var installDir: Variant = null
var HATVers: Variant = null

func _ready() -> void:
	loadConfig()

func loadConfig() -> void: # Load a config file; create a new one if not found.
	var err = conf.load("user://hexahedron.cfg")
	
	if err != OK: # Must be a new file. Make a new one
		saveConfig("InstallInfo", "InstallDir", null)
	else: # Get config info.
		installDir = conf.get_value("InstallInfo", "InstallDir")

func saveConfig(section: String, key: String, val: Variant) -> void: # Save information to the config file.
	conf.set_value(section, key, val)
	conf.save("user://hexahedron.cfg")
