extends HBoxContainer

@onready var _ch: OptionButton = $"Chooser"
@onready var _log: RichTextLabel = $"../Log"

signal installed(code: int)

func _ready() -> void:
	if FileAccess.file_exists("user://releases.atom") != false:
		_add_versions()
	else:
		_refresh_versions()

func _on_refresh_pressed() -> void:
	_refresh_versions()

func _refresh_versions() -> void: # Refresh available HAT versions.
	var req = HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(self._on_req_completed)
	
	var err = req.request("https://github.com/FEZModding/HAT/releases.atom")
	if err != OK:
		_log.append_text("\nError in HAT version list HTTP Request!")

func _on_req_completed(result, _response, _headers, body): # Save HAT versions to file, read from file.
	if result != HTTPRequest.RESULT_SUCCESS:
		_log.append_text("\nCould not download HAT version list!")
	_add_versions(body)
	
func _add_versions(body: Variant = null) -> void: # List version in Chooser.
	if body != null:
		var savefile = FileAccess.open("user://releases.atom", FileAccess.WRITE)
		savefile.store_buffer(body)
		savefile.close()
	
	var tags = FileAccess.get_file_as_bytes("user://releases.atom")
	
	var xml := XMLParser.new()
	var _err = xml.open_buffer(tags)
	
	while xml.read() != ERR_FILE_EOF:
		if xml.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = xml.get_node_name()
			
			if node_name == "title":
				xml.read() # Get version data (could potentially display changelog too)
				var ver = xml.get_node_data()
				
				if ver != "Release notes from HAT":
					_ch.add_item("v" + ver)
					pass

func _download_version(version: String) -> void:
	var req = HTTPRequest.new()
	add_child(req)
	req.request_completed.connect(self._install_version)
	
	var err = req.request("https://github.com/FEZModding/HAT/releases/download/" + version + "/HAT.zip")
	if err != OK:
		_log.append_text("\nError in HAT installer HTTP Request!")

func _install_version(result, _response, _headers, body) -> void: # Install a version of HAT.
	# Check if HTTP request worked
	if result != HTTPRequest.RESULT_SUCCESS:
		_log.append_text("\nCould not download HAT version!")
	
	# Save specified HAT version into install dir
	var hatzip = FileAccess.open(Config.installDir + "/HAT.zip", FileAccess.WRITE)
	hatzip.store_buffer(body)
	hatzip.close()
	_log.append_text("Downloaded selected version...")
	
	# Unpack HAT into dir
	var zip = ZIPReader.new()
	var err = zip.open(Config.installDir + "/HAT.zip")
	if err != OK:
		_log.append_text("\nError reading HAT.zip!")
	var files = zip.get_files()
	
	for i in files:
		if i.ends_with("/") != true: # Files only
			var savefile = FileAccess.open(Config.installDir + "/" + i, FileAccess.WRITE)
			var file = zip.read_file(i)
			savefile.store_buffer(file)
			savefile.close()
		else: # Dirs only
			var dir = DirAccess.open(Config.installDir)
			dir.make_dir(i)
	_log.append_text("\nFiles unpacked...")
	
	# Remove "pause" line from .bat file to bypass user input
	var newbat = FileAccess.get_file_as_string(Config.installDir + "/hat_install.bat").replace("pause", "")
	var savebat = FileAccess.open(Config.installDir + "/hat_install2.bat", FileAccess.WRITE)
	savebat.store_string(newbat)
	savebat.close()
	
	# Run .bat file
	## Take into account external drives (like mine)
	var commands = ["-Command",
					"cd \"\""
					+ Config.installDir.replace("/", "\\") + "\"\"\"; "
					+ ".\\hat_install2.bat"
					]
	var out := ["a"]
	OS.execute("powershell.exe", commands, out)
	emit_signal("installed", 0)
	
	pass

func _on_hexahedron_start_install() -> void:
	_download_version(_ch.text)
