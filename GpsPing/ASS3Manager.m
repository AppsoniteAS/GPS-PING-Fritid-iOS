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


- (void) prepareCognito{
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:AWSRegionEUWest1
                                                                                                    identityPoolId:@"eu-west-1:1d49973f-8111-48d4-9c26-dcdf6c50ee8d"];
    
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionEUWest1
                                                                         credentialsProvider:credentialsProvider];
    
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
}

// access via Cognito
- (RACSignal*) handleCognitoS3: (NSString*) imageName image: (UIImage*) image{
    DDLogInfo(@"%@", imageName);
    
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSFileManager*  fileManager = [NSFileManager defaultManager];
        NSString* path =  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:  imageName];
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        
        [fileManager createFileAtPath:path contents:imageData attributes:nil];// .createFile(atPath: path as String, contents: imageData, attributes: nil)
        
        AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
        uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
        
        AWSS3TransferManager * transferManager = [AWSS3TransferManager defaultS3TransferManager];
        
        uploadRequest.bucket = S3BucketName;
        uploadRequest.key =  imageName;
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
}


// access via 2 keys
- (RACSignal*) handleS3: (NSString*) imageName image: (UIImage*) image{
    DDLogInfo(@"%@", imageName);
    
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        AWSStaticCredentialsProvider *credentialsProvider =
        [[AWSStaticCredentialsProvider alloc]
         initWithAccessKey:S3AccessKey
         secretKey:S3SecretKey];
        
        NSFileManager*  fileManager = [NSFileManager defaultManager];
        NSString* path =  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: imageName];
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
        uploadRequest.key = imageName;// [NSString stringWithFormat: @"%@.jpg", imageName];
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
}



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


- (NSURL*) getURLByImageIdentifier: (NSString*) imageId{
    //https://s3-eu-west-1.amazonaws.com/fritidbucket/
    
    return [NSURL URLWithString: [NSString stringWithFormat:@"https://s3-eu-west-1.amazonaws.com/%@/%@", S3BucketName, imageId]];
}

@end
