savedcmd_synaptics_tcm_core.mod := printf '%s\n'   synaptics_tcm_core.o | awk '!x[$$0]++ { print("./"$$0) }' > synaptics_tcm_core.mod
