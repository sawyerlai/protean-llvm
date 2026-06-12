PIN_ROOT ?= $(error Set PIN_ROOT to your PIN installation directory)

CXX    := g++
OBJDIR := obj-intel64

CXXFLAGS := -std=c++17 -fPIC -O3 \
            -Wall -Wno-unknown-pragmas \
            -fno-stack-protector \
            -DBIGARRAY_MULTIPLIER=1 \
            -DUSING_XED \
            -DTARGET_IA32E -DHOST_IA32E -DTARGET_LINUX \
            -I$(PIN_ROOT)/source/include/pin \
            -I$(PIN_ROOT)/source/include/pin/gen \
            -I$(PIN_ROOT)/extras/components/include \
            -I$(PIN_ROOT)/extras/xed-intel64/include/xed \
            -I$(PIN_ROOT)/source/tools/InstLib

PINCRT := $(PIN_ROOT)/intel64/runtime/pincrt

LDFLAGS := -shared \
           -Wl,--hash-style=sysv \
           -Wl,-Bsymbolic \
           $(PINCRT)/crtbeginS.o \
           -L$(PIN_ROOT)/intel64/lib \
           -L$(PIN_ROOT)/intel64/lib-ext \
           -L$(PINCRT) \
           -lpin -lxed -lpindwarf -ldl -lpincrt -lstlport-dynamic -lm-dynamic \
           $(PINCRT)/crtendS.o

.PHONY: all clean

all: $(OBJDIR)/prot_count.so

$(OBJDIR):
	mkdir -p $@

$(OBJDIR)/prot_count.so: prot_count.cpp | $(OBJDIR)
	$(CXX) $(CXXFLAGS) -o $@ $< $(LDFLAGS)

clean:
	rm -rf $(OBJDIR)
