import std/random
import futhark

importc:
  path "../example"
  forward "retro_set_video_refresh"
  forward "retro_set_audio_sample"
  forward "retro_set_audio_sample_batch"
  forward "retro_set_input_poll"
  forward "retro_set_environment"
  forward "retro_set_input_state"
  forward "retro_init"
  forward "retro_deinit"
  forward "retro_api_version"
  forward "retro_set_controller_port_device"
  forward "retro_get_system_info"
  forward "retro_get_system_av_info"
  forward "retro_reset"
  forward "retro_run"
  forward "retro_load_game"
  forward "retro_unload_game"
  forward "retro_get_region"
  forward "retro_load_game_special"
  forward "retro_serialize_size"
  forward "retro_serialize"
  forward "retro_unserialize"
  forward "retro_get_memory_data"
  forward "retro_get_memory_size"
  forward "retro_cheat_reset"
  forward "retro_cheat_set"
  "libretro.h"

proc NimMain() {.cdecl, importc.}

var video_cb: retro_video_refresh_t
var audio_cb: retro_audio_sample_t
var audio_batch_cb: retro_audio_sample_batch_t
var input_poll_cb: retro_input_poll_t
var environ_cb: retro_environment_t
var input_state_cb: retro_input_state_t

var buf:array[320*240*4, byte]

proc log_cb(level: enum_retro_log_level, message: string) =
  echo message

proc retro_set_video_refresh*(a0: retro_video_refresh_t) =
  video_cb = a0

proc retro_set_audio_sample*(a0: retro_audio_sample_t) =
  audio_cb = a0

proc retro_set_audio_sample_batch*(a0: retro_audio_sample_batch_t) =
  audio_batch_cb = a0

proc retro_set_input_poll*(a0: retro_input_poll_t) =
  input_poll_cb = a0

proc retro_set_environment*(a0: retro_environment_t) =
  environ_cb = a0
  var no_content:bool = true
  discard a0(RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME, addr no_content)

proc retro_set_input_state*(a0: retro_input_state_t) =
  input_state_cb = a0

proc retro_init*() =
  NimMain()
  randomize()
  echo "retro_init"

proc retro_deinit*() =
  echo "retro_deinit"

proc retro_api_version*(): cuint =
  return RETRO_API_VERSION

proc retro_set_controller_port_device*(port: cuint; device: cuint) =
  echo "retro_set_controller_port_device"
  echo port, device

proc retro_get_system_info*(info: ptr struct_retro_system_info) =
  info.library_name = "nim_example";
  info.library_version = "v1"
  info.need_fullpath = false
  info.valid_extensions = nil # we don't use any ROMs

proc retro_get_system_av_info*(info: ptr struct_retro_system_av_info) =
  echo "retro_get_system_av_info"
  info.timing.fps = 60
  info.timing.sample_rate = 48000
  info.geometry.base_width = 320
  info.geometry.base_height = 240
  info.geometry.max_width = 320
  info.geometry.max_height = 240
  info.geometry.aspect_ratio = 4 / 3

proc retro_reset*() =
  echo "retro_reset"

proc retro_run*() =
  for y in 0..239:
    for x in 0..319:
      var b = ((y * 320) + x) * 4
      buf[b  ] = 0x00 # B
      buf[b+1] = 0x00 # G
      buf[b+2] = 0x00 # R
      buf[b+3] = 0xFF # A
      if x mod 10 == 0:
        buf[b] = byte(y)
      if y mod 10 == 0:
        buf[b + 2] = byte(y)
      if y mod 5 == 0 and x mod 5 == 0:
        buf[b + 1] = byte(y)
  video_cb(buf.addr, 320, 240, (320 shl 2))

proc retro_load_game*(game: ptr struct_retro_game_info): bool =
  var fmt = RETRO_PIXEL_FORMAT_XRGB8888
  if not environ_cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, addr fmt):
    log_cb(RETRO_LOG_INFO, "XRGB8888 is not supported.\n")
    return false
  return true

proc retro_unload_game*() =
  echo "retro_unload_game"

proc retro_get_region*(): cuint =
  return 0 # NTSC

proc retro_load_game_special*(gametype: cuint; info: ptr struct_retro_game_info; numinfo: csize_t): bool =
  return true

proc retro_serialize_size*(): csize_t =
  return 0

proc retro_serialize*(data: pointer; size: csize_t): bool =
  return true

proc retro_unserialize*(data: pointer; size: csize_t): bool =
  return true

proc retro_get_memory_data*(id: cuint): pointer =
  discard

proc retro_get_memory_size*(id: cuint): csize_t =
  return 0

proc retro_cheat_reset*() =
  discard

proc retro_cheat_set*(index: cuint; enabled: bool; code: cstring) =
  discard
