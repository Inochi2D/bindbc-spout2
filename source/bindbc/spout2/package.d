module bindbc.spout2;
import bindbc.loader;
import bindbc.spout2.types;
import core.sys.windows.windef;

private extern(C) @nogc nothrow {
    alias _spGetSpout = SPOUTHANDLE function();
    alias _spSetSenderName = void function(SPOUTHANDLE self, const(char)* senderName);
    alias _spSetSenderFormat = void function(SPOUTHANDLE self, DWORD dwFormat);
    alias _spReleaseSender = void function(SPOUTHANDLE self, DWORD dwMsec);
    alias _spSendFbo = bool function(SPOUTHANDLE self, uint fboId, uint width, uint height, bool invert);
    alias _spSendTexture = bool function(SPOUTHANDLE self, uint textureId, uint textureTarget, uint width, uint height, bool invert, uint hostFBO);
    alias _spSendImage = bool function(SPOUTHANDLE self, const(ubyte)* pixels, uint width, uint height, uint glFormat, bool invert);
    alias _spGetName = const(char)* function(SPOUTHANDLE self);
    alias _spGetWidth = uint function(SPOUTHANDLE self);
    alias _spGetHeight = uint function(SPOUTHANDLE self);
    alias _spGetFps = double function(SPOUTHANDLE self);
    alias _spGetFrame = long function(SPOUTHANDLE self);
    alias _spGetHandle = HANDLE function(SPOUTHANDLE self);
    alias _spGetCPU = bool function(SPOUTHANDLE self);
    alias _spGetGLDX = bool function(SPOUTHANDLE self);
}

__gshared {
    _spGetSpout spGetSpout;
    _spSetSenderName spSetSenderName;
    _spSetSenderFormat spSetSenderFormat;
    _spReleaseSender spReleaseSender;
    _spSendFbo spSendFbo;
    _spSendTexture spSendTexture;
    _spSendImage spSendImage;
    _spGetName spGetName;
    _spGetWidth spGetWidth;
    _spGetHeight spGetHeight;
    _spGetFps spGetFps;
    _spGetFrame spGetFrame;
    _spGetHandle spGetHandle;
    _spGetCPU spGetCPU;
    _spGetGLDX spGetGLDX;
}

enum Spout2Support {
    noLibrary,
    badLibrary,
    spout2
}

private {
    SharedLib lib;
    Spout2Support loadedVersion;
}

@nogc nothrow:

void unloadSpout2() {
    if (lib != invalidHandle) {
        lib.unload;
    }
}

Spout2Support loadedSpout2Version() @safe { return loadedVersion; }
bool isSpout2Loaded() @safe { return lib != invalidHandle; }

Spout2Support loadSpout2() {
    
    version(Windows) {
        const(char)[][1] libNames = ["SpoutLibrary.dll"];
    }
    else static assert(0, "bindbc-spout2 only supports Windows.");

    Spout2Support ret;
    foreach(name; libNames) {
        ret = loadSpout2(name.ptr);
        if (ret != Spout2Support.noLibrary) break;
    }
    return ret;
}

Spout2Support loadSpout2(const(char)* libName) {
    lib = load(libName);
    if(lib == invalidHandle) {
        return Spout2Support.noLibrary;
    }

    auto errCount = errorCount();
    loadedVersion = Spout2Support.badLibrary;

    lib.bindSymbol(cast(void**)&spGetSpout, "GetSpout");
    lib.bindSymbol(cast(void**)&spSetSenderName, "spSetSenderName");
    lib.bindSymbol(cast(void**)&spSetSenderFormat, "spSetSenderFormat");
    lib.bindSymbol(cast(void**)&spReleaseSender, "spReleaseSender");
    lib.bindSymbol(cast(void**)&spSendFbo, "spSendFbo");
    lib.bindSymbol(cast(void**)&spSendTexture, "spSendTexture");
    lib.bindSymbol(cast(void**)&spSendImage, "spSendImage");
    lib.bindSymbol(cast(void**)&spGetName, "spGetName");
    lib.bindSymbol(cast(void**)&spGetWidth, "spGetWidth");
    lib.bindSymbol(cast(void**)&spGetHeight, "spGetHeight");
    lib.bindSymbol(cast(void**)&spGetFps, "spGetFps");
    lib.bindSymbol(cast(void**)&spGetFrame, "spGetFrame");
    lib.bindSymbol(cast(void**)&spGetHandle, "spGetHandle");
    lib.bindSymbol(cast(void**)&spGetCPU, "spGetCPU");
    lib.bindSymbol(cast(void**)&spGetGLDX, "spGetGLDX");

    return Spout2Support.spout2;
}