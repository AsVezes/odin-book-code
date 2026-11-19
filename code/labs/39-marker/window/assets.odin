package main

import rl "vendor:raylib"

Marker :: struct {
    texture: rl.Texture2D,
    attached: bool,
}

load_marker :: proc() -> Marker {
    if !rl.FileExists("marker.png") {
        return {}
    }
    image := rl.LoadImage("marker.png")
    if !rl.IsImageValid(image) {
        return {}
    }
    defer rl.UnloadImage(image)
    texture := rl.LoadTextureFromImage(image)
    return Marker{texture = texture, attached = rl.IsTextureValid(texture)}
}

release_marker :: proc(marker: Marker) {
    if marker.attached {
        rl.UnloadTexture(marker.texture)
    }
}
