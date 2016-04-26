CXXFLAGS += -I.
CXXFLAGS += -std=c++11 -g -c -o
CXX=g++

CFLAGS += -I.
CFLAGS += -g -c -o
CC=gcc

LIB_FILES := -lboost_system -lkrb5 -lssl -lcrypto -lpthread -lz

COMMON_SOURCES := ./common/time.cc \
	./common/kfserrno.cc \
	./common/MemLock.cc \
	./common/kfsatomic.cc \
	./common/nofilelimit.cc \
	./common/KfsTraceNew.cc \
	./common/RequestParser.cc \
	./common/kfsdecls.cc \
	./common/Version.cc \
	./common/MsgLogger.cc \
	./common/BufferedLogWriter.cc \
	./common/rusage.cc \
	./common/Properties.cc \
	./common/hsieh_hash.cc 
COMMON_OBJECTS := $(COMMON_SOURCES:.cc=.o)

QCDIO_SOURCES := ./qcdio/QCThread.cc \
	./qcdio/QCUtils.cc \
	./qcdio/QCMutex.cc \
	./qcdio/QCIoBufferPool.cc \
	./qcdio/QCFdPoll.cc \
	./qcdio/QCDiskQueue.cc 
QCDIO_OBJECTS := $(QCDIO_SOURCES:.cc=.o)

KFSIO_SOURCES := ./kfsio/CryptoKeys.cc \
	./kfsio/ZlibInflate.cc \
	./kfsio/ClientAuthContext.cc \
	./kfsio/PrngIsaac64.cc \
	./kfsio/KfsCallbackObj.cc \
	./kfsio/Globals.cc \
	./kfsio/ChunkAccessToken.cc \
	./kfsio/NetErrorSimulator.cc \
	./kfsio/HttpResponseHeaders.cc \
	./kfsio/NetConnection.cc \
	./kfsio/TransactionalClient.cc \
	./kfsio/SslFilter.cc \
	./kfsio/HttpChunkedDecoder.cc \
	./kfsio/Acceptor.cc \
	./kfsio/NetManager.cc \
	./kfsio/checksum.cc \
	./kfsio/DelegationToken.cc \
	./kfsio/TcpSocket.cc \
	./kfsio/IOBuffer.cc \
	./kfsio/Base64.cc
KFSIO_OBJECTS := $(KFSIO_SOURCES:.cc=.o)

EMULATOR_SOURCES:= ./emulator/LayoutEmulator.cc \
	./emulator/ChunkServerEmulator.cc \
	./emulator/emulator_setup.cc 
EMULATOR_OBJECTS:=$(EMULATOR_SOURCES:.cc=.o)

META_SOURCES:= ./meta/MetaRequestHandler.cc \
	./meta/layoutmanager_instance.cc \
	./meta/DiskEntry.cc \
	./meta/MetaRequest.cc \
	./meta/UserAndGroup.cc \
	./meta/ChunkServer.cc \
	./meta/NetDispatch.cc \
	./meta/ClientSM.cc \
	./meta/kfstree.cc \
	./meta/kfsops.cc \
	./meta/util.cc \
	./meta/AuditLog.cc \
	./meta/AuthContext.cc \
	./meta/ChildProcessTracker.cc \
	./meta/Restorer.cc \
	./meta/meta.cc \
	./meta/Replay.cc \
	./meta/Logger.cc \
	./meta/Checkpoint.cc \
	./meta/LayoutManager.cc 
META_OBJECTS := $(META_SOURCES:.cc=.o)

CHUNK_SOURCES := ./chunk/Replicator.cc \
	./chunk/utils.cc \
	./chunk/ClientThread.cc \
	./chunk/RemoteSyncSM.cc \
	./chunk/KfsOps.cc \
	./chunk/ChunkServer.cc \
	./chunk/ClientSM.cc \
	./chunk/ChunkManager.cc \
	./chunk/AtomicRecordAppender.cc \
	./chunk/DirChecker.cc \
	./chunk/DiskIo.cc \
	./chunk/LeaseClerk.cc \
	./chunk/Chunk.cc \
	./chunk/MetaServerSM.cc \
	./chunk/Logger.cc \
	./chunk/ClientManager.cc \
	./chunk/IOMethod.cc \
	./chunk/BufferManager.cc 
CHUNK_OBJECTS:=$(CHUNK_SOURCES:.cc=.o)

KRB_SOURCES := ./krb/KrbClient.cc \
	./krb/KrbService.cc 
KRB_OBJECTS := $(KRB_SOURCES:.cc=.o)

CLIENT_SOURCES := ./libclient/utils.cc \
	./libclient/Path.cc \
	./libclient/Writer.cc \
	./libclient/KfsOps.cc \
	./libclient/KfsNetClient.cc \
	./libclient/KfsAttr.cc \
	./libclient/KfsProtocolWorker.cc \
	./libclient/KfsWrite.cc \
	./libclient/ECMethod.cc \
	./libclient/QCECMethod.cc \
	./libclient/KfsClient.cc \
	./libclient/WriteAppender.cc \
	./libclient/RSStriper.cc \
	./libclient/kfsglob.cc \
	./libclient/Reader.cc \
	./libclient/KfsRead.cc \
	./libclient/FileOpener.cc \
	./libclient/ECMethodJerasure.cc
CLIENT_OBJECTS := $(CLIENT_SOURCES:.cc=.o)

QCRS_SOURCES := ./qcrs/decode.c \
./qcrs/rs_table.c \
./qcrs/encode.c
QCRS_OBJECTS := $(QCRS_SOURCES:.c=.o)

STATIC_LIBS := libmeta.a libchunk.a libkfsio.a libcommon.a libqcdio.a libemulator.a \
	\
	libqfs_krb.a libqcrs.a #libclient.a

all: $(STATIC_LIBS) metaserver chunkserver

metaserver: ./meta/metaserver_main.o $(STATIC_LIBS)
	$(CXX) -o $@ ./meta/metaserver_main.o $(STATIC_LIBS) $(LIB_FILES)

./meta/metaserver_main.o: ./meta/metaserver_main.cc
	$(CXX) $(CXXFLAGS) $@ $<

chunkserver: ./chunk/chunkserver_main.o $(STATIC_LIBS)
	$(CXX) -o $@ ./chunk/chunkserver_main.o $(STATIC_LIBS) $(LIB_FILES)
./chunk/chunkserver_main.o: ./chunk/chunktrimmer_main.cc
	$(CXX) $(CXXFLAGS) $@ $<

libcommon.a: $(COMMON_OBJECTS)
	@ar crf $@ $(COMMON_OBJECTS)
	@echo "[AR]    $@"

libqcdio.a: $(QCDIO_OBJECTS)
	@ar crf $@ $(QCDIO_OBJECTS)
	@echo "[AR]    $@"

libkfsio.a: $(KFSIO_OBJECTS)
	@ar crf $@ $(KFSIO_OBJECTS)
	@echo "[AR]    $@"

libemulator.a: $(EMULATOR_OBJECTS)
	@ar crf $@ $(EMULATOR_OBJECTS)
	@echo "[AR]    $@"

libmeta.a: $(META_OBJECTS)
	@ar crf $@ $(META_OBJECTS)
	@echo "[AR]    $@"

libchunk.a: $(CHUNK_OBJECTS)
	@ar crf $@ $(CHUNK_OBJECTS)
	@echo "[AR]    $@"

libqfs_krb.a: $(KRB_OBJECTS)
	@ar crf $@ $(KRB_OBJECTS)
	@echo "[AR]    $@"

libclient.a: $(CLIENT_OBJECTS)
	@ar crf $@ $(CLIENT_OBJECTS)
	@echo "[AR]    $@"

libqcrs.a: $(QCRS_OBJECTS)
	@ar crf $@ $(QCRS_OBJECTS)
	@echo "[AR]    $@"

.cc.o:
	@$(CXX) $(CXXFLAGS) $@ $<
	@echo "[CXX]   $@"

.c.o:
	@$(CC) $(CFLAGS) $@ $<
	@echo "[CXX]   $@"


clean:
	@rm -fr $(COMMON_OBJECTS) $(QCDIO_OBJECTS) $(KFSIO_OBJECTS)
