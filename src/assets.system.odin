package main

import "core:strings"
import "vendor:raylib"

asset_load_texture :: proc(
	ctx: ^Game_Context,
	path: string,
	modifier: Asset_Modifier = nil,
) -> raylib.Texture2D {

	if path in ctx.assets.textures {
		return ctx.assets.textures[path]
	}

	c_path := strings.clone_to_cstring(path, context.temp_allocator)
	raw_image := raylib.LoadImage(c_path)

	defer raylib.UnloadImage(raw_image)

	if modifier != nil {
		modifier(&raw_image)
	}

	ready_texture := raylib.LoadTextureFromImage(raw_image)

	ctx.assets.textures[path] = ready_texture

	return ready_texture
}
