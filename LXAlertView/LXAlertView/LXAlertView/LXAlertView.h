//
//  LXAlertView.h
//  MyTestProject
//
//  Created by liuxu on 2017/1/10.
//  Copyright © 2017年 Hunter. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LXAlertViewLeftRightMargin              (10.0f)
#define LXAlertViewContentInsets                UIEdgeInsetsMake(31.0f, 20.0f, 33.0f, 20.0f)
#define LXAlertViewTitleHeight                  (21.0f)
#define LXAlertViewMessageBottomMargin          (18.0f)
#define LXAlertViewContentBottomMargin          (5.0f)
#define LXAlertViewButtonHeight                 (41.0f)
#define LXAlertViewButtonsMargin                (9.0f)
#define LXAlertViewTitleBottomMargin            (11.0f)
#define LXAlertViewCancelButtonTag              (-99)

typedef struct {
    NSInteger alertTag;
    NSUInteger buttonIndex;
} LXAlertViewStruct;

typedef enum {
    LXAlertViewButtonLayoutHorizontal,
    LXAlertViewButtonLayoutVertical
} LXAlertViewButtonLayout;

@interface LXAlertView : UIView

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) UIColor *borderColor;
@property (nonatomic, assign) LXAlertViewButtonLayout buttonLayout;
@property (nonatomic, strong) UIColor *cancelButtonColor;
@property (nonatomic, strong) UIColor *cancelButtonBorderColor;
@property (nonatomic, strong) UIColor *cancelButtonTitleColor;
@property (nonatomic, strong) UIColor *otherButtonColor;
@property (nonatomic, strong) UIColor *otherButtonBorderColor;
@property (nonatomic, strong) UIColor *otherButtonTitleColor;
@property (nonatomic, assign, readonly) CGFloat contentViewWidth;

@property (nonatomic, strong) UIView *contentView;

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;


- (void)show;
- (void)showInView:(UIView *)aToView;
- (void)showWithCompletionBlock:(void(^)())completion dismissBlock:(void(^)(LXAlertViewStruct result))dimissBlock;
- (void)showInView:(UIView *)aToView completionBlock:(void(^)())completion dismissBlock:(void(^)(LXAlertViewStruct result))dimissBlock;
- (void)dismiss;
- (void)dismissWithCompletion:(void(^)())completionBlock;

@end


@protocol LXAlertViewDelegate <NSObject>

@optional

- (void)alertView:(LXAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
