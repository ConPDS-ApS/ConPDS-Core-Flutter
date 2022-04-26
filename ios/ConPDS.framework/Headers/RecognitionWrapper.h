//
//  RecognitionWrapper.h
//  ConPDS
//
//  Created by Igor Kostyk on 7/6/15.
//  Copyright (c) 2015 Codevog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIkit/UIkit.h>

@interface RecognitionWrapper : NSObject

- (NSArray*)recognizeCodes:(UIImage*)image
             engineVersion:(NSString*)version
                     error:(NSError * __autoreleasing *)error;

- (NSString *)recognizeToJSON:(UIImage *)image
                        error:(NSError * __autoreleasing *)error;

- (NSString *)recognizeToJSONFromPictureBuffer:(NSData *)pictureBuffer
                                         error:(NSError * __autoreleasing *)error;

@end
