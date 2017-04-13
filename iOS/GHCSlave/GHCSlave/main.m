#import <UIKit/UIKit.h>
#import "AppDelegate.h"

extern void hs_init(int * argc, char ** argv[]);
extern void startSlave(bool, int, const char *);
extern void setLineBuffering(void);

int main(int argc, char * argv[]) {
    NSFileManager * mngr = NSFileManager.defaultManager;
    const char * documents_path = [mngr URLsForDirectory:NSDocumentDirectory
                                               inDomains:NSUserDomainMask]
                            .firstObject.path.UTF8String;

    setupPipe();
    
    hs_init(&argc, &argv);
    setLineBuffering();
    
    startSlave(true, 5000, documents_path);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil,
                                 NSStringFromClass(AppDelegate.class));
    }
}
