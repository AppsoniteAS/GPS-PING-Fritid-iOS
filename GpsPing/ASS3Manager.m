//
//  ASS3Manager.m
//  GpsPing
//
//  Created by Юджин Топсекретович on 10/15/17.
//  Copyright © 2017 Robin Grønvold. All rights reserved.
//

#import "ASS3Manager.h"

static const DDLogLevel ddLogLevel = DDLogLevelVerbose;

#define S3AccessKey @"AKIAJIH5WTKMPAXM27EA"
#define S3SecretKey @"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"
#define S3Region @"GlobalS3TransferManager"
#define S3BucketName @"fritidbucket"


@interface ASS3Manager()


@end

@implementation ASS3Manager


#pragma mark - Init

IMPLEMENT_SINGLETON(ASS3Manager)

- (RACSignal*) handleS3: (NSString*) imageName image: (UIImage*) image{
    DDLogInfo(@"%@", imageName);
    
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        AWSStaticCredentialsProvider *credentialsProvider =
        [[AWSStaticCredentialsProvider alloc]
         initWithAccessKey:S3AccessKey
         secretKey:S3SecretKey];
        
        NSFileManager*  fileManager = [NSFileManager defaultManager];
        NSString* path =  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: [NSString stringWithFormat: @"%@.jpg", imageName]];
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        
        [fileManager createFileAtPath:path contents:imageData attributes:nil];// .createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        //let fileUrl = NSURL(fileURLWithPath: path)
        
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc]initWithRegion:AWSRegionEUWest1 credentialsProvider:credentialsProvider];
        // S3 has only a Global Region -- establish our creds configuration
        [AWSS3TransferManager registerS3TransferManagerWithConfiguration:configuration forKey:S3Region];
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
        
        AWSS3TransferManager * transferManager = [AWSS3TransferManager S3TransferManagerForKey:S3Region];
        
        uploadRequest.bucket = S3BucketName;
        uploadRequest.key = [NSString stringWithFormat: @"%@.jpg", imageName];
        uploadRequest.contentType = @"image/jpeg";
        uploadRequest.body = [NSURL fileURLWithPath: path];
        
        [[transferManager upload:uploadRequest] continueWithBlock:^id _Nullable(AWSTask * _Nonnull t) {
            if (t.error){
                [subscriber sendError:t.error];

                DDLogError(@"Error: %@", t.error);
                return nil;
            }
            [subscriber sendNext:t.result];
            [subscriber sendCompleted];
            DDLogInfo(@"Result: %@", t.result);
            return nil;
        }];
        return nil;
    }];
    
    
   
    
    
    
    

    
    
    //    [[transferManager download:downloadRequest] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
    //
    //        if (task.error){
    //            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
    //                switch (task.error.code) {
    //                    case AWSS3TransferManagerErrorCancelled:
    //                    case AWSS3TransferManagerErrorPaused:
    //                        break;
    //
    //                    default:
    //                        NSLog(@"Error: %@", task.error);
    //                        break;
    //                }
    //            } else {
    //                NSLog(@"Error: %@", task.error);
    //            }
    //        }
    //
    //        if (task.result) {
    //            // ...this runs on main thread already
    //            NSLog(@"Result: %@", task.result);
    //
    //           // cell.imageView.image = [UIImage imageWithContentsOfFile:downloadingFilePath];
    //        }
    //        return nil;
    //    }];
    
}

@end
