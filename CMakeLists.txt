cmake_minimum_required(VERSION 3.20)
project(CoolBoarders2001Recomp LANGUAGES C CXX)
set(PSXRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/psxrecomp" CACHE PATH "PSXRecomp framework")
set(PSX_RECOMP_UI OFF CACHE BOOL "Launcher UI")
set(PSX_NETPLAY OFF CACHE BOOL "Netplay")
set(PSX_REWIND OFF CACHE BOOL "Rewind")
include("${PSXRECOMP_ROOT}/runtime/runtime.cmake")
psxrecomp_add_game_runtime(psx-runtime
    PRELOADED_MODS_DIR "NONE"
    WINDOW_TITLE "Cool Boarders 2001 Recompiled"
    DEFAULT_GAME_CONFIG_PATH "game.toml"
    MAX_PLAYERS 2
    GEN_MARKER "generated/SCUS_945.97_dispatch.c"
    GEN_FULL_GLOB "generated/SCUS_945.97_full_*.c"
)
add_custom_command(TARGET psx-runtime POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
    "${CMAKE_CURRENT_SOURCE_DIR}/game.toml" "$<TARGET_FILE_DIR:psx-runtime>/game.toml"
    VERBATIM)
