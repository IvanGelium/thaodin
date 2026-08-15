package main

import "vendor:raylib"
Assets_Component :: struct {
	textures: map[string]raylib.Texture2D,
}

Asset_Modifier :: proc(img: ^raylib.Image)
