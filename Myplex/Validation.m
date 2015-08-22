//
//  Validation.m
//
//  Created by Chris Dritsas - ChrisDrit@gmail.com  
//  Copyright 2010. All rights reserved. 
//

#import "Validation.h"


@implementation Validation

- (BOOL)emailRegEx:(NSString *)string {
	
	// lowercase the email for proper validation
	string = [string lowercaseString];
	
	// regex for email validation
	NSString *emailRegEx =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
	
	NSPredicate *regExPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
	BOOL myStringMatchesRegEx = [regExPredicate evaluateWithObject:string];
	
	return myStringMatchesRegEx;
	
}

- (BOOL)passwordMinLength:(NSInteger)minLength password:(NSString *)password {
    // 1. Length.
    if ([password length] < minLength) {
        return NO;
    }
    
    //2. uppercase characters
    NSCharacterSet *charSet = [NSCharacterSet uppercaseLetterCharacterSet];
    NSRange range = [password rangeOfCharacterFromSet:charSet];
    if(range.location == NSNotFound)
        return NO;
    
    // 3. Special characters.
    charSet = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    range = [password rangeOfCharacterFromSet:charSet];
    if(range.location == NSNotFound)
        return NO;
    
    // 4. Numbers.
    if ([[password componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]] count] < 2)
        return NO;
    
    return YES;
}

- (BOOL)phoneNumber:(NSString *)phoneNumber {
    
    BOOL phoneNumberValid = NO;
    
    NSError *error = nil;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypePhoneNumber error:&error];
    
    NSUInteger numberOfMatches = [detector numberOfMatchesInString:phoneNumber
                                                           options:0
                                                             range:NSMakeRange(0, [phoneNumber length])];
    if (numberOfMatches > 0) {
        phoneNumberValid = YES;
    }
    
    return phoneNumberValid;
}

@end
