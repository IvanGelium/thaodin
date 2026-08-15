package main

import rl "vendor:raylib"


Audio_Component :: struct {
	stream:           rl.AudioStream,
	samples:          []f32,
	active_voices:    [dynamic]Voice,
	note_frequencies: map[Tone]f32,
	master_volume:    f32,
	sample_rate:      f32,
}
MAX_MODS :: 16
Wave_Type :: enum {
	Sine,
	Triangle,
	Sawtooth,
	Square,
	Noise,
}

Wave_Proc :: #type proc(phase: f32) -> f32
Pitch_Mod_Proc :: #type proc(v: ^Voice, progress: f32)
Amp_Mod_Proc :: #type proc(v: ^Voice, current_amp, progress: f32)
Effect_Proc :: #type proc(v: ^Voice, sample: f32) -> f32

Voice :: struct {
	id:           int,
	is_active:    bool,
	time_alive:   f32,
	duration:     f32,
	note_freq:    f32,
	phase:        f32,
	wave_func:    Wave_Proc,
	current_freq: f32,
	current_amp:  f32,
	freq_drift:   f32,
	amp_drift:    f32,
	pitch_mods:   [MAX_MODS]Pitch_Mod_Proc,
	amp_mods:     [MAX_MODS]Amp_Mod_Proc,
	effects:      [MAX_MODS]Effect_Proc,
}


NOTE_KEY :: enum {
	C,
	C_SH,
	D_FL,
	D,
	D_SH,
	E_FL,
	E,
	F,
	F_SH,
	G_FL,
	G,
	G_SH,
	A_FL,
	A,
	A_SH,
	B,
	B_FL,
}

Tone :: struct {
	note:   NOTE_KEY,
	octave: int,
}

Bit_Depth :: enum i32 {
	B32 = 32,
	B64 = 64,
}

Audio_Config :: struct {
	sampling_rate: u32,
	buffer_size:   i32,
	bit_depth:     Bit_Depth,
	channels:      u32,
	master_volume: f32,
}
