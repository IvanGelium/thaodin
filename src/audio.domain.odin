package main

import rl "vendor:raylib"


Audio_Component :: struct {
	stream:           rl.AudioStream,
	samples:          []f32,
	active_voices:    [dynamic]Voice,
	note_frequencies: map[Tone]f32,
	master_volume:    f32,
	sample_rate:      f32,
	instruments:      map[string]Audio_Instrument,
}
MAX_MODS :: 16
Wave_Type :: enum {
	Sine,
	Triangle,
	Sawtooth,
	Square,
	Noise,
}

Audio_Instrument :: struct {
	name:    string,
	attack:  Attack_Params,
	release: Release_Params,
	wave:    Wave_Proc,
}
Play_Proc :: #type proc(ctx: ^Game_Context, instrument: ^Audio_Instrument, tone: ^Tone)


Audio_Effect :: struct {
	data:      rawptr,
	procedure: Envelope_Proc,
}

Attack_Params :: struct {
	attack_time:  f32,
	attack_power: f32,
	max_vol:      f32,
}
Release_Params :: struct {
	release_time:  f32,
	release_power: f32,
	max_vol:       f32,
}

Wave_Proc :: #type proc(phase: f32) -> f32
Pitch_Mod_Proc :: #type proc(v: ^Voice, progress: f32)
Amp_Mod_Proc :: #type proc(v: ^Voice, current_amp, progress: f32)
Effect_Proc :: #type proc(v: ^Voice, sample: f32) -> f32
Envelope_Proc :: #type proc(v: ^Voice, effect_data: rawptr) -> f32


Voice :: struct {
	id:             int,
	is_active:      bool,
	is_down:        bool,
	time_alive:     f32,
	duration:       f32,
	tone:           Tone,
	note_freq:      f32,
	phase:          f32,
	wave_func:      Wave_Proc,
	current_freq:   f32,
	current_amp:    f32,
	base_amp:       f32,
	pitch_mods:     [MAX_MODS]Pitch_Mod_Proc,
	amp_mods:       [MAX_MODS]Audio_Effect,
	amp_mods_count: int,
	effects:        [MAX_MODS]Effect_Proc,
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
