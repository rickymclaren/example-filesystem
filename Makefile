# Make 'all' first so that it is THE default target.
#
# The :: means that if there is more than one of the same target name 
# then process all the occurrences one after the other.

all:: disk.img

# assume that there will be one .com file that is built for each .asm file
SRC=$(wildcard progs/*/*.asm)
PROGS=$(SRC:%.asm=%.com)
PROG_DIRS=$(sort $(dir $(SRC)))

TOP=.

# include things that might be of interest to more than just this Makefile
include $(TOP)/Make.default
-include $(TOP)/Make.local		# The - on this means ignore it if the file does not exist

burn: disk.img
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=$(DISK_SLOT)x16384 conv=fsync

ls:: disk.img
	cpmls -f $(DISKDEF) disk.img


disk.img: $(PROGS)
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:


# files to overwrite onto CP/M drive D 
burn_d: disk_d.img
	@ if [ -z "$(PROGS_D)" ]; then\
		echo "PROGS_D is empty, nothing to do!"; \
		false; \
	fi
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=3x16384 conv=fsync
disk_d.img: $(PROGS_D)
	@ if [ -z "$(PROGS_D)" ]; then\
		echo "PROGS_D is empty, nothing to do!"; \
		false; \
	fi
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:
ls:: disk_d.img
	cpmls -f $(DISKDEF) disk_d.img


# files to overwrite onto CP/M drive B
burn_b: disk_b.img
	@ if [ -z "$(PROGS_B)" ]; then\
		echo "PROGS_B is empty, nothing to do!"; \
		false; \
	fi
	@ if [ `hostname` != "$(SD_HOSTNAME)" -o ! -b "$(SD_DEV)" ]; then\
		echo "\nWARNING: You are either NOT logged into $(SD_HOSTNAME) or there is no $(SD_DEV) mounted!\n"; \
		false; \
	fi
	sudo dd if=$< of=$(SD_DEV) bs=512 seek=1x16384 conv=fsync
disk_b.img: $(PROGS_B)
	@ if [ -z "$(PROGS_B)" ]; then\
		echo "PROGS_B is empty, nothing to do!"; \
		false; \
	fi
	rm -f $@
	mkfs.cpm -f $(DISKDEF) $@
	cpmcp -f $(DISKDEF) $@ $^ 0:
ls:: disk_b.img
	cpmls -f $(DISKDEF) disk_b.img


%.com: %.asm
	make -C $(dir $@) $(notdir $@)

clean:
	rm -f disk.img disk_d.img disk_b.img
	for i in $(PROG_DIRS); do make -C $$i clean; done


world: clean all
