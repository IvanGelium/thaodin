package main
import "core:fmt"
import "core:math"
import "core:math/rand"

import rl "vendor:raylib"


audio_init :: proc(ctx: ^Game_Context, cfg: Audio_Config) {
	rl.InitAudioDevice()
	bs := cfg.buffer_size / cast(i32)cfg.channels
	rl.SetAudioStreamBufferSizeDefault(bs)
	init_note_map(ctx)
	ctx.audio.stream = rl.LoadAudioStream(cfg.sampling_rate, cast(u32)cfg.bit_depth, cfg.channels)
	rl.PlayAudioStream(ctx.audio.stream)
	ctx.audio.samples = make([]f32, cfg.buffer_size)
	ctx.audio.active_voices = make([dynamic]Voice)
	ctx.audio.master_volume = cfg.master_volume
	ctx.audio.sample_rate = cast(f32)cfg.sampling_rate
	ctx.audio.instruments = make(map[string]Audio_Instrument)

	piano := get_piano()
	ctx.audio.instruments["piano"] = piano
}


get_piano :: proc() -> Audio_Instrument {
	return Audio_Instrument {
		name = "piano",
		attack = Attack_Params{attack_time = 0.1},
		release = Release_Params{release_time = 0.2},
		wave = wave_triangle,
	}
}

play_instrument :: proc(ctx: ^Game_Context, instrument: ^Audio_Instrument, tone: ^Tone) {
	base_freq := ctx.audio.note_frequencies[{tone.note, tone.octave}]

	new_voice := Voice {
		tone         = tone^,
		note_freq    = base_freq,
		current_freq = base_freq,
		duration     = 0.2,
		time_alive   = 0.0,
		phase        = 0.0,
		base_amp     = 0.5,
		wave_func    = wave_triangle,
		is_active    = true,
		amp_mods     = [16]Audio_Effect{},
	}

	if new_voice.amp_mods_count < 16 {
		new_voice.amp_mods[new_voice.amp_mods_count] = {
			data      = &instrument.attack,
			procedure = process_attack,
		}
		new_voice.amp_mods_count += 1
	}

	if new_voice.amp_mods_count < 16 {
		new_voice.amp_mods[new_voice.amp_mods_count] = {
			data      = &instrument.release,
			procedure = process_release,
		}
		new_voice.amp_mods_count += 1
	}

	append(&ctx.audio.active_voices, new_voice)
}


audio_update :: proc(ctx: ^Game_Context) {
	audio := &ctx.audio
	SAMPLE_RATE_F := ctx.audio.sample_rate
	for rl.IsAudioStreamProcessed(audio.stream) {
		for i in 0 ..< len(audio.samples) do audio.samples[i] = 0.0
		for i := len(audio.active_voices) - 1; i >= 0; i -= 1 {
			v := &audio.active_voices[i]
			for j := 0; j < len(audio.samples); j += 2 {
				if v.time_alive >= v.duration {
					v.is_active = false
					break
				}
				v.current_amp = v.base_amp
				// progress := v.time_alive / v.duration
				// amplitude := 0.2 * math.exp(-3.0 * progress)
				// vibrato := math.sin(v.time_alive * 10.0) * 0.5
				// attack_time: f32 = 0.01
				// release_time: f32 = 0.02
				// remaining_time := v.duration - v.time_alive
				// current_vol := amplitude
				// if v.time_alive < attack_time {
				// 	current_vol = amplitude * (v.time_alive / attack_time)
				// } else if remaining_time < release_time {
				// 	current_vol = amplitude * (remaining_time / release_time)
				// }
				for i in 0 ..< v.amp_mods_count {
					mod := v.amp_mods[i]
					v.current_amp *= mod.procedure(v, mod.data)
				}

				step := (v.current_freq) * 2.0 * math.PI / SAMPLE_RATE_F
				sample_val := v.wave_func(v.phase) * v.current_amp

				audio.samples[j] += sample_val
				audio.samples[j + 1] += sample_val

				v.phase += step
				if v.phase >= 2.0 * math.PI {
					v.phase -= 2.0 * math.PI
				}
				v.time_alive += 1.0 / SAMPLE_RATE_F
			}
			if !v.is_active {
				unordered_remove(&audio.active_voices, i)
			}
		}
		for i := 0; i < len(audio.samples); i += 1 {
			s := audio.samples[i] * audio.master_volume
			if s > 1.0 do s = 1.0
			if s < -1.0 do s = -1.0
			audio.samples[i] = s
		}
		num_frames := i32(len(audio.samples) / 2)
		rl.UpdateAudioStream(audio.stream, raw_data(audio.samples), num_frames)
	}
}

audio_shutdown :: proc(ctx: ^Game_Context) {
	rl.UnloadAudioStream(ctx.audio.stream)
	delete(ctx.audio.samples)
	delete(ctx.audio.active_voices)
	delete(ctx.audio.note_frequencies)
	rl.CloseAudioDevice()
}


init_note_map :: proc(ctx: ^Game_Context) {
	ctx.audio.note_frequencies = make(map[Tone]f32)
	for octave := 0; octave <= 8; octave += 1 {
		for note in NOTE_KEY {
			semitone := 0
			switch note {
			case .C:
				semitone = 0
			case .C_SH, .D_FL:
				semitone = 1
			case .D:
				semitone = 2
			case .D_SH, .E_FL:
				semitone = 3
			case .E:
				semitone = 4
			case .F:
				semitone = 5
			case .F_SH, .G_FL:
				semitone = 6
			case .G:
				semitone = 7
			case .G_SH, .A_FL:
				semitone = 8
			case .A:
				semitone = 9
			case .A_SH, .B_FL:
				semitone = 10
			case .B:
				semitone = 11
			}
			note_index := octave * 12 + semitone
			distance_from_a4 := note_index - 57
			freq := 440.0 * math.pow(2.0, f32(distance_from_a4) / 12.0)
			ctx.audio.note_frequencies[{note, octave}] = freq
		}
	}
}


wave_sine :: proc(phase: f32) -> f32 {
	return math.sin(phase)
}

wave_triangle :: proc(phase: f32) -> f32 {
	p := phase / (2 * math.PI)
	return 4.0 * math.abs(p - math.floor(p + 0.5)) - 1.0
}


process_attack :: proc(v: ^Voice, data: rawptr) -> f32 {
	params := (^Attack_Params)(data)
	if v.time_alive < params.attack_time {
		return v.time_alive / params.attack_time
	}
	return 1.0
}

process_release :: proc(v: ^Voice, effect_data: rawptr) -> f32 {
	params := (^Release_Params)(effect_data)
	remaining_time := v.duration - v.time_alive
	if remaining_time < params.release_time {
		return remaining_time / params.release_time
	}
	return 1.0
}
