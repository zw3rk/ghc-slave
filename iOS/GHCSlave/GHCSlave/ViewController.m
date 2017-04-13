//
//  ViewController.m
//  GHCSlave
//
//  Created by Moritz Angermann on 4/11/17.
//  Copyright © 2017 Moritz Angermann. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *IPAddress;
@property (weak, nonatomic) IBOutlet UITextView *log;

@end

@implementation ViewController

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
- (void)setupStdoutToLog {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ssize_t rdsz_;
        char line[1024];
        memset(line, 0, sizeof line);
        unsigned left_over = 0;
        char buf[64];
        
        memset(buf, 0, sizeof buf);
        while ((rdsz_ = read(pfd[0], buf, sizeof buf - 1)) > 0) {
            unsigned rdsz = (unsigned)rdsz_; /* we checked in the cond. > 0 */
            unsigned offset = 0;
            for (unsigned i = 0; i < rdsz; i++) {
                if (buf[i] == '\n') {
                    memcpy(line + left_over, buf + offset, i - offset);
                    NSString *stdOutString = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSAttributedString* stdOutAttributedString = [[NSAttributedString alloc] initWithString:stdOutString];
                        [self.log.textStorage appendAttributedString:stdOutAttributedString];
                        [self.log scrollRangeToVisible:NSMakeRange(self.log.text.length-1, 0)];
                    });
                    memset(line, 0, sizeof line);
                    left_over = 0;
                    offset = i;
                }
            }
            if (offset < rdsz) {
                unsigned lo = rdsz - offset;
                memcpy(line + left_over, buf + offset, lo);
                if (left_over + lo < sizeof(line)) {
                    left_over += lo;
                } else {
                    NSString *stdOutString = [NSString stringWithCString:line encoding:NSUTF8StringEncoding];
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        NSAttributedString* stdOutAttributedString = [[NSAttributedString alloc] initWithString:stdOutString];
                        [self.log.textStorage appendAttributedString:stdOutAttributedString];
                        [self.log scrollRangeToVisible:NSMakeRange(self.log.text.length-1, 0)];
                    });
                    memset(line, 0, sizeof line);
                    left_over = 0;
                }
            }
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.IPAddress.text = [self getIPAddress];
    [self setupStdoutToLog];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
