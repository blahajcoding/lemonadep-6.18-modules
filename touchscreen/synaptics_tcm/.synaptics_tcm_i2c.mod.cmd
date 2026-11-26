savedcmd_synaptics_tcm_i2c.mod := printf '%s\n'   synaptics_tcm_i2c.o | awk '!x[$$0]++ { print("./"$$0) }' > synaptics_tcm_i2c.mod
