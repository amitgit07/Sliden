//
//  Constants.h
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#ifndef Numerologist_Constants_h
#define Numerologist_Constants_h

#define PARSE_APP_ID        @"I1GYptTzgFU1Ku27JvgsdWCsXydQxZcAVWD55vNa"
#define PARSE_CLIENT_KEY    @"12OfRUePZugcRdNju9CFwvbkam35lJN6chSz4BbQ"

#define OVERLAY_VIEW_TAG        1111
#define OVERLAY_VIEW_TAG_SLIDE  1112
#define OVERLAY_VIEW_TAG_BOUNCE 1113

#define hDevice [[APP_DELEGATE window] frame].size.height
#define wDevice [[APP_DELEGATE window] frame].size.width

#define validObject(o) (o)?o:[NSNull null]

#define Image(o) [UIImage imageNamed:o]
#define StreachImage(o, l, t) [Image(@"blueBtn37.png") stretchableImageWithLeftCapWidth:l topCapHeight:t]
#define FractionIn255(o) (o/255.0f)

#endif




extern NSString* const kKeyUserId;
extern NSString* const kKeyUserInfo;
extern NSString* const kKeyFirstName;
extern NSString* const kKeyLastName;
extern NSString* const kKeyBirthName;
extern NSString* const kKeyEmailId;
extern NSString* const kKeyDateOfBirth;
extern NSString* const kKeyPassword;
extern NSString* const kKeyMiddleName;
extern NSString* const kKeyGender;
extern NSString* const kKeyLocation;
extern NSString* const kKeyRelationshipStatus;
extern NSString* const kKeyFollowing;
extern NSString* const kKeyFollowers;
extern NSString* const kKeyProfilePic;
extern NSString* const kKeyFollowingUsers;
