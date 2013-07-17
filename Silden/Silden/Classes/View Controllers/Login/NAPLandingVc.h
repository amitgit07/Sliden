//
//  NAPLandingVc.h
//  Silden
//
//  Created by Amit Priyadarshi on 28/04/13.
//  Copyright (c) 2013 Amit Priyadarshi. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface NAPLandingVc : UIViewController {
    
}
- (IBAction)testBtnTap:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *testButtonTap;
- (IBAction)fbConnectButtonTap:(UIButton *)sender;
- (IBAction)loginButtonTap:(UIButton *)sender;
- (IBAction)registerButtonTap:(UIButton *)sender;
@end
