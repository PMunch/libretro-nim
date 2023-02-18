import example_libretro/libretro

var video_cb: retro_video_refresh_t
var audio_cb: retro_audio_sample_t
var audio_batch_cb: retro_audio_sample_batch_t
var input_poll_cb: retro_input_poll_t
var environ_cb: retro_environment_t
var input_state_cb: retro_input_state_t

var buf:array[1280, int32]

proc log_cb(level: retro_log_level, message: string) =
  echo message

proc retro_set_video_refresh*(cb: retro_video_refresh_t) {.cdecl,exportc,dynlib.} =
  video_cb = cb

proc retro_set_audio_sample*(cb: retro_audio_sample_t) {.cdecl,exportc,dynlib.} =
  audio_cb = cb

proc retro_set_audio_sample_batch*(cb: retro_audio_sample_batch_t) {.cdecl,exportc,dynlib.} =
  audio_batch_cb = cb

proc retro_set_input_poll*(cb: retro_input_poll_t) {.cdecl,exportc,dynlib.} =
  input_poll_cb = cb

proc retro_set_environment*(cb: retro_environment_t) {.cdecl,exportc,dynlib.} =
  environ_cb = cb
  var no_content:bool = true
  discard cb(RETRO_ENVIRONMENT_SET_SUPPORT_NO_GAME, addr no_content)

proc retro_set_input_state*(cb: retro_input_state_t) {.cdecl,exportc,dynlib.} =
  input_state_cb = cb

proc retro_init*() {.cdecl,exportc,dynlib.} =
  echo "retro_init"

proc retro_deinit*() {.cdecl,exportc,dynlib.} =
  echo "retro_deinit"

proc retro_api_version*(): cuint {.cdecl,exportc,dynlib.} =
  return RETRO_API_VERSION

proc retro_set_controller_port_device*(port: cuint; device: cuint) {.cdecl,exportc,dynlib.} =
  echo "retro_set_controller_port_device"
  echo port, device

proc retro_get_system_info*(info: ptr retro_system_info) {.cdecl,exportc,dynlib.} =
  info.library_name = "nim_example";
  info.library_version = "v1"
  info.need_fullpath = false
  info.valid_extensions = nil # we don't use any ROMs

proc retro_get_system_av_info*(info: ptr retro_system_av_info) {.cdecl,exportc,dynlib.} =
  echo "retro_get_system_av_info"
  info.timing.fps = 60
  info.timing.sample_rate = 48000
  info.geometry.base_width = 320
  info.geometry.base_height = 240
  info.geometry.max_width = 320
  info.geometry.max_height = 240
  info.geometry.aspect_ratio = 4 / 3

proc retro_reset*() {.cdecl,exportc,dynlib.} =
  echo "retro_reset"

proc retro_run*() {.cdecl,exportc,dynlib.} =
  for i in 0..1279:
     buf[i] = high(int32)
  video_cb(buf, 320, 240, 1280) # stride << 2

proc retro_load_game*(info: ptr retro_game_info): bool {.cdecl,exportc,dynlib.} =
  var fmt = RETRO_PIXEL_FORMAT_XRGB8888
  if not environ_cb(RETRO_ENVIRONMENT_SET_PIXEL_FORMAT, addr fmt):
    log_cb(RETRO_LOG_INFO, "XRGB8888 is not supported.\n")
    return false
  return true

proc retro_unload_game*() {.cdecl,exportc,dynlib.} =
  echo "retro_unload_game"

proc retro_get_region*(): cuint {.cdecl,exportc,dynlib.} =
  return 0 # NTSC

proc retro_load_game_special*(`type`: cuint; info: ptr retro_game_info; num: csize_t): bool {.cdecl,exportc,dynlib.} =
  return true

proc retro_serialize_size*(): csize_t {.cdecl,exportc,dynlib.} =
  return 0

proc retro_serialize*(data: pointer; size: csize_t): bool {.cdecl,exportc,dynlib.} =
  return true

proc retro_unserialize*(data: pointer; size: csize_t): bool {.cdecl,exportc,dynlib.} =
  return true

proc retro_get_memory_data*(id: cuint): pointer {.cdecl,exportc,dynlib.} =
  discard

proc retro_get_memory_size*(id: cuint): csize_t {.cdecl,exportc,dynlib.} =
  return 0

proc retro_cheat_reset*() {.cdecl,exportc,dynlib.} =
  discard

proc retro_cheat_set*(index: cuint; enabled: bool; code: cstring) {.cdecl,exportc,dynlib.} =
  discard
