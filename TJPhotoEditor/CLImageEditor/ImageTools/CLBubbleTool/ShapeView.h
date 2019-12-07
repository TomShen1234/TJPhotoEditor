//
//  ShapeView.h
//  ShapeTest
//
//  Created by yifeng shen on 2/17/15.
//  Copyright (c) 2015 Tom and Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeView : UIView <UITextViewDelegate>

@property (nonatomic, readwrite, assign) CGSize boxSize;

@property (nonatomic, strong) UITextView *textView;

@end
