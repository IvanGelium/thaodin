package main
import "core:math"
import rl "vendor:raylib"

test :: proc() {
	sine_idx: f32 = 0.0
	stream := rl.LoadAudioStream(44100, 32, 1)
	defer rl.UnloadAudioStream(stream)
	rl.PlayAudioStream(stream)
	samples := make([]f32, 4096)
	defer delete(samples)
	rl.SetTargetFPS(60)
}


// package main

// import "core:math"
// import rl "vendor:raylib"

// // Глобальная переменная для фазы волны
// sine_idx: f32 = 0.0

// main :: proc() {
//     rl.InitWindow(800, 450, "Процедурный синтез")
//     defer rl.CloseWindow()

//     rl.InitAudioDevice()
//     defer rl.CloseAudioDevice()

//     // Создаем аудиопоток: 44100 Гц, 32-бит float, 1 канал (Моно)
//     stream := rl.LoadAudioStream(44100, 32, 1)
//     defer rl.UnloadAudioStream(stream)

//     rl.PlayAudioStream(stream)

//     // Буфер, который мы будем наполнять на лету (максимум 4096 сэмплов за раз)
//     samples := make([]f32, 4096)
//     defer delete(samples)

//     rl.SetTargetFPS(60)

//     for !rl.WindowShouldClose() {
//         // Меняем частоту звука от положения мышки по горизонтали
//         frequency := f32(rl.GetMouseX()) + 100.0

//         // Проверяем, готова ли аудиокарта принять порцию новых данных
//         if rl.IsAudioStreamProcessed(stream) {

//             // Наполняем буфер математической синусоидой
//             for i := 0; i < len(samples); i += 1 {
//                 samples[i] = math.sin(sine_idx) * 0.2 // 0.2 — это громкость

//                 // Шаг фазы зависит от желаемой частоты
//                 sine_idx += (frequency * 2.0 * math.PI) / 44100.0
//                 if sine_idx > math.PI * 2.0 do sine_idx -= math.PI * 2.0
//             }

//             // Отправляем массив сэмплов в аудиокарту
//             rl.UpdateAudioStream(stream, raw_data(samples), i32(len(samples)))
//         }

//         rl.BeginDrawing()
//         rl.ClearBackground(rl.BLACK)
//         rl.DrawText("Двигай мышь для изменения частоты синуса!", 10, 10, 20, rl.WHITE)
//         rl.EndDrawing()
//     }
// }
