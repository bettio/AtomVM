project(avm_kernel_lib)

include(BuildErlang)

set(ERLANG_MODULES
    network_console
)

pack_archive(avm_kernel_lib ${ERLANG_MODULES})

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/avm_kernel_lib.avm DESTINATION lib/AtomVM/ebin)
