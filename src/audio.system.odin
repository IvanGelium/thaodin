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
}


audio_update :: proc(ctx: ^Game_Context) {
	audio := &ctx.audio
	SAMPLE_RATE_F := ctx.audio.sample_rate
	for rl.IsAudioStreamProcessed(audio.stream) {
		for i in 0 ..< len(audio.samples) do audio.samples[i] = 0.0
		for i := len(audio.active_voices) - 1; i >= 0; i -= 1 {
			v := &audio.active_voices[i]
			voice_time := v.time_alive
			for j := 0; j < len(audio.samples); j += 2 {
				if voice_time >= v.duration {
					v.is_active = false
					break
				}
				progress := voice_time / v.duration
				amplitude := 0.2 * math.exp(-3.0 * progress)
				vibrato := math.sin(voice_time * 10.0) * 0.5
				step := (v.current_freq + vibrato) * 2.0 * math.PI / SAMPLE_RATE_F
				attack_time: f32 = 0.01
				release_time: f32 = 0.02
				remaining_time := v.duration - voice_time
				current_vol := amplitude
				if voice_time < attack_time {
					current_vol = amplitude * (voice_time / attack_time)
				} else if remaining_time < release_time {
					current_vol = amplitude * (remaining_time / release_time)
				}
				sample_val := v.wave_func(v.phase) * current_vol
				audio.samples[j] += sample_val
				audio.samples[j + 1] += sample_val
				v.phase += step
				if v.phase >= 2.0 * math.PI {
					v.phase -= 2.0 * math.PI
				}
				voice_time += 1.0 / SAMPLE_RATE_F
			}
			v.time_alive = voice_time
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

set_attack :: proc(v: ^Voice, amp: f32, progress: f32) -> f32 {
	attack_time: f32 = 0.01
	vol: f32 = 0.0
	if progress < attack_time {
		vol = amp * (v.time_alive / attack_time)
	}
	return vol
}

play_piano :: proc(ctx: ^Game_Context, tone: Tone) {
	base_freq := ctx.audio.note_frequencies[{tone.note, tone.octave}]
	random_drift := (rand.float32() - 0.5) * 1.0
	new_voice := Voice {
		note_freq    = base_freq,
		current_freq = base_freq + random_drift,
		duration     = 3.0 + rand.float32() * 0.2,
		time_alive   = 0.0,
		phase        = 0.0,
		wave_func    = wave_sine,
		is_active    = true,
	}
	append(&ctx.audio.active_voices, new_voice)
}
