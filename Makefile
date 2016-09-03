TARGET_LIB = libvitashaders.a
SOURCES = src
INCLUDES = include
SHDIR		 = shaders
SHADERS   := $(foreach dir,$(SHDIR), $(wildcard $(dir)/*.cg))


GXPS       = $(SHADERS:.cg=.gxp)
OBJS       = $(SHADERS:.cg=.o)

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
AR      = $(PREFIX)-ar
CFLAGS  = -Wall -I$(INCLUDES) -O3 -ftree-vectorize -mfloat-abi=hard -ffast-math -fsingle-precision-constant -ftree-vectorizer-verbose=2 -fopt-info-vec-optimized -funroll-loops
ASFLAGS = $(CFLAGS)

all: $(TARGET_LIB)


$(TARGET_LIB): $(OBJS)
	$(AR) -rc $@ $^

tools/raw2c: tools/raw2c.c
	cc $< -o $@


%_v.gxp: %_v.cg
	qemu-arm-static -L ./gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf/libc/ ./vita-shaders/shacc --vertex $^ $@


%_f.gxp: %_f.cg
	qemu-arm-static -L ./gcc-linaro-4.9-2015.02-3-x86_64_arm-linux-gnueabihf/arm-linux-gnueabihf/libc/ ./vita-shaders/shacc --fragment $^ $@


%_v.o: tools/raw2c %_v.gxp
	@mkdir -p $(INCLUDES)
	@mkdir -p $(SOURCES)
	$< $(word 2,$^)
	mv $(word 2,$^:.gxp=.h) $(INCLUDES)
	mv $(word 2,$^:.gxp=.c) $(SOURCES)
	$(CC) $(CFLAGS) -c $(SOURCES)/$(word 2,$^:.gxp=.c) -o $@
	
%_f.o: tools/raw2c %_f.gxp
	@mkdir -p $(INCLUDES)
	@mkdir -p $(SOURCES)
	$< $(word 2,$^)
	mv $(word 2,$^:.gxp=.h) $(INCLUDES)
	mv $(word 2,$^:.gxp=.c) $(SOURCES)
	$(CC) $(CFLAGS) -c $(SOURCES)/$(word 2,$^:.gxp=.c) -o $@

clean:
	@rm -rf $(TARGET_LIB) $(OBJS) $(GXPS) $(INCLUDES) $(SOURCES)
