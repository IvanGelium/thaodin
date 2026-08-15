package main

input_init :: proc(ctx: ^Game_Context, bindings: []Key_Binding) {
	for binding in bindings {
		input_map_action(ctx, binding.action, binding.key, binding.value)
	}
}
