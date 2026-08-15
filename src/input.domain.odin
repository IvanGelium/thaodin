
package main

import "vendor:raylib"

Input_Component :: struct {
	bindings:  [Actions][dynamic]Key_Binding,
	callbacks: [Actions]Input_Callback,
}

Key_Binding :: struct {
	action: Actions,
	key:    raylib.KeyboardKey,
	value:  f32,
}

Actions :: enum {
	Move_Horizontal,
	Move_Vertical,
	Jump,
	Run,
	Pause,
}

Input_Callback :: proc(ctx: ^Game_Context, value: f32)

input_map_action :: proc(
	ctx: ^Game_Context,
	action: Actions,
	key: raylib.KeyboardKey,
	value: f32,
) {
	binding := Key_Binding {
		key   = key,
		value = value,
	}
	append(&ctx.input.bindings[action], binding)
}

input_register_callback :: proc(ctx: ^Game_Context, action: Actions, callback: Input_Callback) {
	ctx.input.callbacks[action] = callback
}
