#import <UIKit/UIKit.h>
extern void hs_init(int * argc, char ** argv[]);
extern void startSlave(bool, int, const char *);

int main(int argc, char * argv[]) {
    const char * documents_path = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject].path.UTF8String;
    
    hs_init(&argc, &argv);
    
    startSlave(true, 5000, documents_path);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, nil);
    }
}
