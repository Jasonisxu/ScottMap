//
//  CustomAnnotationView.h
//  GenerationOfDriving
//
//  Created by ZKR on 16/1/7.
//  Copyright © 2016年 ZKR. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@class CustomCalloutView;
@interface CustomAnnotationView : MAAnnotationView
@property (nonatomic, readonly) CustomCalloutView *calloutView;
@end
