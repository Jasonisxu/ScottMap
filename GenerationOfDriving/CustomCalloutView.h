//
//  CustomCalloutView.h
//  GenerationOfDriving
//
//  Created by ZKR on 16/1/7.
//  Copyright © 2016年 ZKR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCalloutView : UIView
@property (nonatomic,strong) UIImage *image; //商户圈
@property (nonatomic,copy) NSString *title;  //商户名
@property (nonatomic,copy) NSString *subtitle; //地址

@property (nonatomic, strong) UIImageView *portraitView;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@end
