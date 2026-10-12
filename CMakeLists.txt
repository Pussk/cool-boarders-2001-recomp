cmake_minimum_required(VERSION 3.20)
project(CoolBoarders2001Recomp LANGUAGES C CXX)
set(PSXRECOMP_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/psxrecomp" CACHE PATH "PSXRecomp framework")
set(PSX_RECOMP_UI OFF CACHE BOOL "Launcher UI")
set(PSX_NETPLAY OFF CACHE BOOL "Netplay")
set(PSX_REWIND OFF CACHE BOOL "Rewind")
set(PSXRECOMP_BIOS_STEMS "OpenBIOS;SCPH1001;SCPH5500" CACHE STRING "Local BIOS backends")
set(PSX_SHELLWIN_INTERP ON CACHE BOOL "Interpret retail BIOS shell")
include("${PSXRECOMP_ROOT}/runtime/runtime.cmake")
psxrecomp_add_game_runtime(psx-runtime
    EXE_NAME "coolboard2001"
    APP_ICON "${CMAKE_CURRENT_SOURCE_DIR}/assets/ps1.ico"
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
set_property(SOURCE "${PSXRECOMP_ROOT}/runtime/src/main.cpp" APPEND PROPERTY COMPILE_DEFINITIONS COOLBOARDERS_EXPERIMENTAL_WIDESCREEN=1)
