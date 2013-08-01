//
//  SDefaultSlidenCells.m
//  Sliden
//
//  Created by Amit Priyadarshi on 27/07/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import "SDefaultSlidenCells.h"

@implementation SDefaultSlidenCells
@synthesize showTitleLabel=_showTitleLabel;
@synthesize lastModifiedDateLabel=_lastModifiedDateLabel;
@synthesize lastModifiedTimeLabel=_lastModifiedTimeLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //
        _showTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 18, 165, 18)];
        [_showTitleLabel setTextAlignment:NSTextAlignmentLeft];
        [_showTitleLabel setTextColor:RGBA(36, 143, 183, 1.0)];
        [_showTitleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [_showTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_showTitleLabel];
        
        _lastModifiedDateLabel = [[UILabel alloc] initWithFrame:CGRectMake(185, 18, 165, 18)];
        [_lastModifiedDateLabel setTextAlignment:NSTextAlignmentLeft];
        [_lastModifiedDateLabel setTextColor:RGBA(93, 93, 93, 1.0)];
        [_lastModifiedDateLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [_lastModifiedDateLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lastModifiedDateLabel];
        
        _lastModifiedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 18, 165, 18)];
        [_lastModifiedTimeLabel setTextAlignment:NSTextAlignmentLeft];
        [_lastModifiedTimeLabel setTextColor:RGBA(93, 93, 93, 1.0)];
        [_lastModifiedTimeLabel setFont:[UIFont boldSystemFontOfSize:11]];
        [_lastModifiedTimeLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_lastModifiedTimeLabel];
        
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    return self;
}

@end
