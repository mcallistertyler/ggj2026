extends Node

signal music_finished
signal music_fade_completed

@export var voices: int = 15
@export var sfx_bus: String = "SFX"
@export var music_bus: String = "Music"
@export var library: AudioLibrary

var _sfx_players: Array[AudioStreamPlayer] = []
var _next: int = 0

var _music_player: AudioStreamPlayer
var _fade_tween: Tween = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_buses()
	_create_sfx_players()
	_create_music_player()

func _setup_buses() -> void:
	if AudioServer.get_bus_index(sfx_bus) == -1:
		sfx_bus = "Master"
	if AudioServer.get_bus_index(music_bus) == -1:
		music_bus = "Master"

func _create_sfx_players() -> void:
	for i in range(voices):
		var player = AudioStreamPlayer.new()
		player.bus = sfx_bus
		add_child(player)
		_sfx_players.append(player)

func _create_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = music_bus
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)

# --- SFX ---

func play_sfx(sound_name: String, pitch_scale := 1.0, volume_db := 0.0) -> void:
	var stream = _get_sfx(sound_name)
	if stream == null:
		push_error("AudioManager: Sound effect not found: " + sound_name)
		return
	_play_sfx_stream(stream, pitch_scale, volume_db)

func play_sfx_stream(stream: AudioStream, pitch_scale := 1.0, volume_db := 0.0) -> void:
	_play_sfx_stream(stream, pitch_scale, volume_db)

func play_random_pitch(sound_name: String, spread := 0.04, volume_db := 0.0) -> void:
	var pitch = 1.0 + randf_range(-spread, spread)
	play_sfx(sound_name, pitch, volume_db)

func play_random_pitch_stream(stream: AudioStream, spread := 0.04, volume_db := 0.0) -> void:
	var pitch = 1.0 + randf_range(-spread, spread)
	_play_sfx_stream(stream, pitch, volume_db)

func stop_all_sfx() -> void:
	for player in _sfx_players:
		player.stop()

func _play_sfx_stream(stream: AudioStream, pitch_scale: float, volume_db: float) -> void:
	var player: AudioStreamPlayer = _sfx_players[_next]
	_next = (_next + 1) % _sfx_players.size()
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

func _get_sfx(sound_name: String) -> AudioStream:
	if library == null:
		return null
	return library.sound_effects.get(sound_name)

# --- Music ---

func play_music(track_name: String, volume_db := 0.0) -> void:
	var stream = _get_music(track_name)
	if stream == null:
		push_error("AudioManager: Music track not found: " + track_name)
		return
	play_music_stream(stream, volume_db)

func play_music_stream(stream: AudioStream, volume_db := 0.0) -> void:
	_kill_fade()
	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = volume_db
	_music_player.play()

func stop_music() -> void:
	_kill_fade()
	_music_player.stop()

func fade_out_music(duration := 1.0) -> void:
	if not _music_player or not _music_player.playing:
		return

	_kill_fade()
	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(_music_player, "volume_db", -80.0, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_fade_tween.finished.connect(_on_fade_done)

func fade_in_music(track_name: String, duration := 1.0, target_volume_db := 0.0) -> void:
	var stream = _get_music(track_name)
	if stream == null:
		push_error("AudioManager: Music track not found: " + track_name)
		return
	fade_in_music_stream(stream, duration, target_volume_db)

func fade_in_music_stream(stream: AudioStream, duration := 1.0, target_volume_db := 0.0) -> void:
	_kill_fade()
	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = -80.0
	_music_player.play()

	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(_music_player, "volume_db", target_volume_db, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func crossfade_music(track_name: String, duration := 1.0, target_volume_db := 0.0) -> void:
	var stream = _get_music(track_name)
	if stream == null:
		push_error("AudioManager: Music track not found: " + track_name)
		return
	crossfade_music_stream(stream, duration, target_volume_db)

func crossfade_music_stream(stream: AudioStream, duration := 1.0, target_volume_db := 0.0) -> void:
	if not _music_player.playing:
		fade_in_music_stream(stream, duration, target_volume_db)
		return

	_kill_fade()

	# Create a temporary player for the old track
	var old_player = AudioStreamPlayer.new()
	old_player.bus = music_bus
	old_player.stream = _music_player.stream
	old_player.volume_db = _music_player.volume_db
	add_child(old_player)
	old_player.play()
	old_player.seek(_music_player.get_playback_position())

	# Fade out old player and remove it
	var fade_out_tween = get_tree().create_tween()
	fade_out_tween.tween_property(old_player, "volume_db", -80.0, duration)
	fade_out_tween.finished.connect(old_player.queue_free)

	# Start new track with fade in
	_music_player.stop()
	_music_player.stream = stream
	_music_player.volume_db = -80.0
	_music_player.play()

	_fade_tween = get_tree().create_tween()
	_fade_tween.tween_property(_music_player, "volume_db", target_volume_db, duration) \
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func is_music_playing() -> bool:
	return _music_player.playing

func get_current_music_position() -> float:
	return _music_player.get_playback_position()

func seek_music(position: float) -> void:
	_music_player.seek(position)

func _get_music(track_name: String) -> AudioStream:
	if library == null:
		return null
	return library.music.get(track_name)

func _kill_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
		_fade_tween = null

func _on_fade_done() -> void:
	_kill_fade()
	music_fade_completed.emit()

func _on_music_finished() -> void:
	music_finished.emit()

# --- Backwards Compatibility Aliases ---

func playSFX(sound_effect: String, pitch_scale := 1.0, volume_db := 0.0) -> void:
	play_sfx(sound_effect, pitch_scale, volume_db)
