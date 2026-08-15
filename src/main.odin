package main

import rl "vendor:raylib"
import "vendor:raylib/rlgl"

t_cfg :: struct {
	text:  cstring,
	x:     i32,
	y:     i32,
	size:  i32,
	color: rl.Color,
}

shutdown :: proc(ctx: ^Game_Context) {
	audio_shutdown(ctx)
	rl.CloseWindow()
}

main :: proc() {
	rl.InitWindow(800, 600, "Engine: Input Init Success")


	texts := make([dynamic]t_cfg)
	nt := t_cfg {
		text  = "Init project A.P.P.L.E.P.I.C.K.E.R",
		x     = 20,
		y     = 20,
		size  = 30,
		color = rl.GREEN,
	}
	append(&texts, nt)
	ctx := Game_Context{}
	defer shutdown(&ctx)

	rl.SetTargetFPS(60)

	init_game(&ctx)
	offset := cast(i32).0
	append(&texts, get_test(offset))
	offset += 30
	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.Q) {
			play_piano(&ctx, Tone{.C, 5})
		}
		if rl.IsKeyPressed(.W) {
			play_piano(&ctx, Tone{.D, 5})
		}
		if rl.IsKeyPressed(.E) {
			play_piano(&ctx, Tone{.E, 5})
		}
		if rl.IsKeyPressed(.R) {
			play_piano(&ctx, Tone{.F, 5})
		}
		if rl.IsKeyPressed(.T) {
			play_piano(&ctx, Tone{.G, 5})
		}
		if rl.IsKeyPressed(.Y) {
			play_piano(&ctx, Tone{.A, 5})
		}
		if rl.IsKeyPressed(.U) {
			play_piano(&ctx, Tone{.B, 5})
		}
		if rl.IsKeyPressed(.ONE) {
			play_piano(&ctx, Tone{.C, 6})
		}
		if rl.IsKeyPressed(.TWO) {
			play_piano(&ctx, Tone{.D, 6})
		}
		if rl.IsKeyPressed(.THREE) {
			play_piano(&ctx, Tone{.E, 6})
		}
		if rl.IsKeyPressed(.FOUR) {
			play_piano(&ctx, Tone{.F, 6})
		}
		if rl.IsKeyPressed(.FIVE) {
			play_piano(&ctx, Tone{.G, 6})
		}
		if rl.IsKeyPressed(.SIX) {
			play_piano(&ctx, Tone{.A, 6})
		}
		if rl.IsKeyPressed(.SEVEN) {
			play_piano(&ctx, Tone{.B, 6})
		}
		if rl.IsKeyPressed(.Z) {
			play_piano(&ctx, Tone{.C, 2})
		}
		if rl.IsKeyPressed(.X) {
			play_piano(&ctx, Tone{.D, 2})
		}
		if rl.IsKeyPressed(.C) {
			play_piano(&ctx, Tone{.E, 2})
		}
		if rl.IsKeyPressed(.V) {
			play_piano(&ctx, Tone{.F, 2})
		}
		if rl.IsKeyPressed(.B) {
			play_piano(&ctx, Tone{.G, 2})
		}
		if rl.IsKeyPressed(.N) {
			play_piano(&ctx, Tone{.A, 2})
		}
		if rl.IsKeyPressed(.M) {
			play_piano(&ctx, Tone{.B, 2})
		}

		audio_update(&ctx)
		rl.BeginDrawing()
		for t in texts {
			rl.DrawText(t.text, t.x, t.y, t.size, t.color)
		}
		rl.ClearBackground(rl.BLACK)
		rl.EndDrawing()
	}
}

get_test :: proc(offset: i32) -> t_cfg {
	nt := t_cfg {
		text  = "TEST",
		x     = 100,
		y     = offset + 100,
		size  = 20,
		color = rl.RED,
	}
	return nt
}
