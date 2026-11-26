savedcmd_synaptics_tcm_touch.mod := printf '%s\n'   synaptics_tcm_touch.o | awk '!x[$$0]++ { print("./"$$0) }' > synaptics_tcm_touch.mod
