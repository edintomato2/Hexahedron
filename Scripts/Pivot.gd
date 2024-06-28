extends Node3D

@onready var _anim = $"Pivot/Hexahedron1Ao_fezao/AnimationPlayer"
@onready var _pivanim = $"Pivot/PivotAnim"

signal start_install

func _on_install_pressed() -> void:
	_anim.play("install", 2, 1)
	await _anim.animation_finished
	
	_pivanim.play("spin_up")
	await _pivanim.animation_finished
	
	_pivanim.play("spin_loop", -1, 1)
	emit_signal("start_install")
	

func _on_hat_version_installed(code: int) -> void:
	if code == 0:
		_pivanim.play("spin_up", 1, -2, true)
		await _pivanim.animation_finished
		
		var timer = Timer.new()
		timer.one_shot = true
		add_child(timer)
		timer.start(2)
		await timer.timeout
		
		_anim.play("spin", 1, 0.5)
