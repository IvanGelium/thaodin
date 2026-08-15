package main

init_game :: proc(ctx: ^Game_Context) {
	//Управление
	input_init(ctx, DEFAULT_CONTROLS)


	//Аудио
	audio_cfg := Audio_Config {
		// sampling_rate = 44100,
		sampling_rate = 48000,
		buffer_size   = 2048,
		bit_depth     = .B32,
		channels      = 2,
		master_volume = 0.3,
	}
	audio_init(ctx, audio_cfg)
}
