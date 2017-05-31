#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>

#include <jni.h>
#include <android/log.h>
#include <sys/socket.h>
#include <sys/un.h>

#define  LOG_TAG    "GHCSlave"
#define  LOGI(...)  __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define  LOGE(...)  __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)
#define  UNUSED     __attribute__((unused))

// from the rts.
extern void hs_init(int * argc, char ** argv[]);
// from LineBuff
extern void setLineBuffering(void);
// from iserv Remote.Slave
extern void startSlave(bool verbose, int port, const char * docroot);

JNIEXPORT
void
JNICALL
Java_com_zw3rk_GHCSlave_startSlave(JNIEnv *env,
                                   jclass class UNUSED,
                                   jboolean  jVerbose,
                                   jint jPort,
                                   jstring jDocRoot )
{
//  int argc = 4;
//
//  char ** argv = malloc(sizeof(char*)*4);
//  argv[0] = "GHCSlave";
//  argv[1] = "+RTS";
//  argv[2] = "-Di";
//  argv[3] = "-RTS";
//  hs_init(&argc, &argv);

  hs_init(NULL,NULL);
  setLineBuffering();
  const char *docroot = (*env)->GetStringUTFChars(env, jDocRoot, JNI_FALSE);
  startSlave(jVerbose, jPort, docroot);
  (*env)->ReleaseStringUTFChars(env, jDocRoot, docroot);
}

JNIEXPORT
jint
JNICALL
Java_com_zw3rk_GHCSlave_pipeStdOutToSocket(JNIEnv * env,
                                           jclass class UNUSED,
                                           jstring jSocketName)
{

  const char *name = (*env)->GetStringUTFChars(env, jSocketName, JNI_FALSE);

  LOGI("socket name: %s", name);

  int localsocket, len;
  if((localsocket = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
    LOGE("failed to create socket!");
    return 1;
  }

  struct sockaddr_un remote;
  remote.sun_path[0] = '\0'; /* abstract namespace */
	strcpy(remote.sun_path + 1, name);
	remote.sun_family = AF_UNIX;
	size_t nameLen = strlen(name);
	len = 1 + nameLen + offsetof(struct sockaddr_un, sun_path);

  if (connect(localsocket, (struct sockaddr *) &remote, len) == -1) {
		LOGE("connect error");
		return 1;
	}

  dup2( localsocket, STDOUT_FILENO );
  dup2( localsocket, STDERR_FILENO );

  (*env)->ReleaseStringUTFChars(env, jSocketName, name);

  return 0;
}
