###########################################################################
#
# SAP xmms plug-in. 
# Copyright 2002/2003 by Michal 'Mikey' Szwaczko <mikey@scene.pl>
# 
# SAP Library ver. 1.56 by Adam Bienias
# 
# This is free software. You can modify it and distribute it under the terms
# of the GNU General Public License. The verbatim text of the license can 
# be found in file named COPYING in the source directory.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR 
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
# 
##########################################################################

CC     = gcc 

#CFLAGS = -O2  -fPIC -fpic
#	-finline-functions -ffast-math
#	-funroll-all-loops -fomit-frame-pointer -fno-strength-reduce
CFLAGS= $CFLAGS $(shell xmms-config --cflags) 

LINKER_FLAGS = -shared -Wl,-soname -Wl,$(TARGET) \
	-Wl,-retain-symbols-file -Wl,syms

TARGET = libsap.so

SAPLIB = saplib/pokey0.o saplib/pokey1.o saplib/sapCpu.o saplib/sapEngine.o saplib/sapPokey.o

SRCS   = sap_plug.c sapfile.c fileinfo.c
OBJS   = sap_plug.o sapfile.o fileinfo.o

#----------- NO SERVICABLE PARTS BELOW THIS LINE --------------------#

all: library plugin

plugin: $(OBJS)
	@./scripts/gen_symbols sap_plug.o 
	@echo 
	$(CC) $(LINKER_FLAGS) $(OBJS) $(SAPLIB) -o $(TARGET)
	@echo 
library: 
	@echo 
	cd saplib && make 
	@echo 
install:
	cp $(TARGET) $(HOME)/.xmms/Plugins/Input
clean:
	rm -f *.o *.so *.a .syms syms
realclean: clean
	cd saplib && make clean
