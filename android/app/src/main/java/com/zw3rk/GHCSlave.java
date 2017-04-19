package com.zw3rk;

public class GHCSlave {
    static {
        System.loadLibrary("native-lib");
    }
    public static native void startSlave(boolean verbose, int port, String docroot);
    public static native int pipeStdOutToSocket(String socketName);
}
