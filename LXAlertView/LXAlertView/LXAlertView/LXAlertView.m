//
//  LXAlertView.m
//  MyTestProject
//
//  Created by liuxu on 2017/1/10.
//  Copyright © 2017年 Hunter. All rights reserved.
//

#import "LXAlertView.h"

@interface LXAlertView ()

@property (nonatomic, weak) UIView *targetView;
@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) NSMutableArray *buttonTitlesArray;
@property (nonatomic, copy) void(^dismissBlock)(LXAlertViewStruct result);
@property (nonatomic, copy) void(^completeBlock)();
@property (nonatomic, strong) UIView *overlay;
@property (nonatomic, assign) LXAlertViewStruct result;
@property (nonatomic, assign) CGFloat leftRightMargin;
@property (nonatomic, assign) UIEdgeInsets contentInsets;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;

@end

@implementation LXAlertView

+ (UIWindow *)shareAlertWindow {
    static UIWindow *_sharedAlertWindow = NULL;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedAlertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _sharedAlertWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UIViewController *rootViewController = [[UIViewController alloc] init];
        rootViewController.view.backgroundColor = [UIColor clearColor];
        _sharedAlertWindow.rootViewController = rootViewController;
        _sharedAlertWindow.backgroundColor = [UIColor clearColor];
        _sharedAlertWindow.userInteractionEnabled = YES;
    });
    
    return _sharedAlertWindow;
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
            otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION {
    
    va_list args, args_copy;
    va_start(args, otherButtonTitles);
    va_copy(args_copy, args);
    va_end(args);
    return [self initWithTitle:title
                       message:message
                      delegate:delegate
             cancelButtonTitle:cancelButtonTitle
              otherButtonTitle:otherButtonTitles
                        valist:args_copy];
}

- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                     delegate:(id)delegate
            cancelButtonTitle:(NSString *)cancelButtonTitle
             otherButtonTitle:(NSString *)otherButtonTitle
                       valist:(va_list)valist {
    
    if (self = [super initWithFrame:CGRectZero]) {
        
        _delegate = delegate;
        _leftRightMargin = LXAlertViewLeftRightMargin;
        _contentInsets = LXAlertViewContentInsets;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0f;
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        // 标题
        if (title.length) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setTextAlignment:NSTextAlignmentCenter];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont boldSystemFontOfSize:17.0f]];
            [label setTextColor:[UIColor blackColor]];
            [label setNumberOfLines:1];
            [label setText:title];
            [self addSubview:label];
            _titleLabel = label;
        }
        
        // 副标题
        if (message.length) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:12.0f]];
            [label setTextColor:[UIColor blackColor]];
            [label setNumberOfLines:0];
            
            // 多行文本，需要行间距
            NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:message];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 2.5;
            style.lineBreakMode = NSLineBreakByWordWrapping;
            style.alignment = NSTextAlignmentCenter;
            [messageAttrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, messageAttrString.length)];
            label.attributedText = messageAttrString;
            
            [self addSubview:label];
            _messageLabel = label;
        }
        
        // 处理取消按钮和其他按钮（取消按钮等同其他按钮，位于第一个按钮）
        NSMutableArray *titlesArray = [NSMutableArray arrayWithCapacity:1];
        if (cancelButtonTitle && cancelButtonTitle.length) {
            [titlesArray addObject:cancelButtonTitle];
        }
        if (otherButtonTitle && otherButtonTitle.length) {
            [titlesArray addObject:otherButtonTitle];
            if (valist) {
                NSString *eachObject;
                while ((eachObject = va_arg(valist, NSString *))) {
                    [titlesArray addObject:eachObject];
                }
            }
        }
        _buttonsArray = [NSMutableArray arrayWithCapacity:1];
        _buttonTitlesArray = titlesArray;
        for (NSString *item in _buttonTitlesArray) {
            [self addButtonWithTitle:item];
        }
        
        // 子类定制 UI
        [self initUI];
    }
    
    return self;
}

- (void)initUI {
    // TO BE OVERRIDE
}

- (void)setContentView:(UIView *)contentView {
    if ([_contentView isEqual:contentView]) {
        return;
    }
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = contentView;
    [self addSubview:_contentView];
    [self layoutIfNeeded];
}

- (NSInteger)addButtonWithTitle:(NSString *)title {
    NSInteger index = [self indexOfObjectInButtonsArrayByTitle:title];
    if (index == -1) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        button.tag = self.buttonsArray.count;
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
        [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3.0f;
        button.layer.borderWidth = 0.5f;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        if (self.buttonTitlesArray.count > 1 && !self.buttonsArray.count) {
            // 取消按钮样式
            button.tag = LXAlertViewCancelButtonTag;
        }
        [self addSubview:button];
        [self.buttonsArray addObject:button];
        return self.buttonsArray.count - 1;
    }
    else {
        return index;
    }
}

- (NSInteger)indexOfObjectInButtonsArrayByTitle:(NSString *)title {
    if (!title) {
        return -1;
    }
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        UIButton *button = [self.buttonsArray objectAtIndex:i];
        if ([button.titleLabel.text isEqualToString:title]) {
            return i;
        }
    }
    return -1;
}


- (void)show {
    UIWindow *window = [LXAlertView shareAlertWindow];
    for (UIView *subview in window.subviews) {
        [subview removeFromSuperview];
    }
    window.hidden = NO;
    [self showInView:window];
}

- (void)showInView:(UIView *)aToView {
    if (!aToView) {
        return;
    }
    self.targetView = aToView;
    [self showOverlay:YES];
    self.layer.zPosition = 1000;
    CATransform3D rotate = CATransform3DMakeRotation(90.0 * M_PI / 180.0, 0.0, 1.0, 0.0);
    CATransform3D translate = CATransform3DMakeTranslation(-self.frame.size.width/2, 40.0, 0.0);
    translate.m34 = 1.0 / -500;
    self.layer.transform = CATransform3DConcat(rotate, translate);
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CATransform3D translate = CATransform3DIdentity;
        self.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(0.0 * M_PI / 180.0, 0.0, 1.0, 0.0), translate);
    } completion:^(BOOL finished) {
        if (self.completeBlock) {
            self.completeBlock();
        }
    }];
}

- (void)showOverlay:(BOOL)show {
    if (show) {
        // 刷新布局
        [self layoutIfNeeded];
        
        if (![self.targetView isKindOfClass:[UIWindow class]]) {
            [self.overlay removeFromSuperview];
            self.overlay = nil;
            [self removeFromSuperview];
            UIView *bgView = [[UIView alloc] initWithFrame:[LXAlertView shareAlertWindow].bounds];
            bgView.backgroundColor = [UIColor blackColor];
            bgView.alpha = 0.0f;
            self.overlay = bgView;
            [self.targetView addSubview:self.overlay];
            [self.targetView addSubview:self];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.overlay.alpha = 0.40f;
                } completion:^(BOOL finished) {
                    
                }];
            });
            return;
        }
        UIWindow *window = [LXAlertView shareAlertWindow];
        [self.overlay removeFromSuperview];
        self.overlay = nil;
        [self removeFromSuperview];
        window.windowLevel = UIWindowLevelStatusBar + 1;
        window.opaque = NO;
        window.hidden = NO;
        
        UIView *bgView = [[UIView alloc] initWithFrame:[LXAlertView shareAlertWindow].bounds];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.0f;
        self.overlay = bgView;
        
        [window addSubview:self.overlay];
        [window addSubview:self];
        dispatch_async(dispatch_get_main_queue(), ^{
            [window makeKeyAndVisible];
            [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.overlay.alpha = 0.40f;
            } completion:^(BOOL finished) {
                
            }];
        });
    }
    else {
        [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.overlay.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.overlay removeFromSuperview];
            self.overlay = nil;
        }];
    }
}

- (void)showWithCompletionBlock:(void(^)())completion dismissBlock:(void(^)(LXAlertViewStruct result))dimissBlock {
    if (completion) {
        self.completeBlock = completion;
    }
    if (dimissBlock) {
        self.dismissBlock = dimissBlock;
    }
    [self show];
}

- (void)showInView:(UIView *)aToView completionBlock:(void(^)())completion dismissBlock:(void(^)(LXAlertViewStruct result))dimissBlock {
    if (!aToView) {
        [self showWithCompletionBlock:completion dismissBlock:dimissBlock];
        return;
    }
    if (dimissBlock) {
        self.dismissBlock = dimissBlock;
    }
    if (completion) {
        self.completeBlock = completion;
    }
    [self showInView:aToView];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void(^)())completionBlock {
    [self showOverlay:NO];
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CATransform3D translate = CATransform3DMakeTranslation(self.frame.size.width+50, 50.0, 0.0);
        translate.m34 = 1.0 / -500;
        CATransform3D rotate = CATransform3DMakeRotation(10 * M_PI / 180.0, 0.0, -1.0, 0.0);
        self.layer.transform = CATransform3DConcat(rotate, translate);
    } completion:^(BOOL finished) {
        [self cleanup];
        if (completionBlock) {
            completionBlock();
        }
    }];
}


- (void)cleanup {
    self.layer.transform = CATransform3DIdentity;
    self.transform = CGAffineTransformIdentity;
    self.alpha = 1.0f;
    [LXAlertView shareAlertWindow].hidden = YES;
    if (!self.targetView) {
        [[[[UIApplication sharedApplication] delegate] window] makeKeyWindow];
    }
    [self.overlay removeFromSuperview];
    self.overlay = nil;
    [self removeFromSuperview];
}

- (void)buttonDidClicked:(id)sender {
    UIButton *button = nil;
    if ([sender isKindOfClass:[UIButton class]]) {
        button = (UIButton *)sender;
    }
    self.result = (LXAlertViewStruct){self.tag, button.tag};

    [self dismissWithCompletion:^{
        if (self.dismissBlock) {
            self.dismissBlock(self.result);
        }
        else {
            if (self.delegate && [self.delegate respondsToSelector:@selector(LXAlertView:clickedButtonAtIndex:)]) {
                [self.delegate LXAlertView:self clickedButtonAtIndex:self.result.buttonIndex];
            }
            else if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
                [self.delegate alertView:(UIAlertView *)self clickedButtonAtIndex:self.result.buttonIndex];
            }
        }
    }];
}


- (CGFloat)contentViewWidth {
    return CGRectGetWidth([UIScreen mainScreen].bounds) - (self.leftRightMargin * 2) - (self.contentInsets.left + self.contentInsets.right);
}


- (void)layoutSubviews {
    CGRect alertViewRect = [[UIScreen mainScreen] bounds];
    CGRect contentViewRect = CGRectZero;
    CGRect topRect = CGRectZero;
    CGRect bottomRect = CGRectZero;
    CGFloat alertViewHeight = self.contentInsets.top + self.contentInsets.bottom;
    CGFloat contentViewWidth = [self contentViewWidth];
    
    CGSize titleSize = CGSizeZero;
    if (self.titleLabel) {
        titleSize = [self.titleLabel.text boundingRectWithSize:CGSizeMake(contentViewWidth, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName: self.titleLabel.font}
                                                       context:nil].size;
        alertViewHeight += LXAlertViewTitleHeight;
    }
    
    CGSize messageSize = CGSizeZero;
    if (self.messageLabel) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2.5;
        style.lineBreakMode = NSLineBreakByWordWrapping;
        style.alignment = NSTextAlignmentCenter;
        messageSize = [self.messageLabel.text boundingRectWithSize:CGSizeMake(contentViewWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:@{NSFontAttributeName: self.messageLabel.font,
                                                                     NSParagraphStyleAttributeName: style}
                                                           context:nil].size;
        alertViewHeight += messageSize.height;
        alertViewHeight += LXAlertViewMessageBottomMargin;
    }
    
    if (self.contentView) {
        alertViewHeight += CGRectGetHeight(self.contentView.frame);
        alertViewHeight += LXAlertViewContentBottomMargin;
    }
    
    if (self.buttonsArray.count > 0) {
        if (self.buttonLayout == LXAlertViewButtonLayoutHorizontal) {
            alertViewHeight += LXAlertViewButtonHeight;
        }
        else if (self.buttonLayout == LXAlertViewButtonLayoutVertical) {
            alertViewHeight += self.buttonsArray.count * LXAlertViewButtonHeight + (self.buttonsArray.count - 1) * LXAlertViewButtonsMargin;
        }
    }
    
    CGFloat dy = (alertViewRect.size.height - alertViewHeight) / 2;
    alertViewRect.origin.x = self.leftRightMargin;
    alertViewRect.origin.y = dy > 0 ? dy : 0;
    alertViewRect.size.width -= self.leftRightMargin * 2;
    alertViewRect.size.height = alertViewHeight;
    self.frame = alertViewRect;
    
    contentViewRect = self.bounds;
    contentViewRect.origin.x = self.contentInsets.left;
    contentViewRect.size.width -= (self.contentInsets.left + self.contentInsets.right);

    CGRectDivide(contentViewRect, &topRect, &bottomRect, self.contentInsets.top, CGRectMinYEdge);
    if (self.titleLabel) {
        CGRectDivide(bottomRect, &topRect, &bottomRect, LXAlertViewTitleHeight, CGRectMinYEdge);
        CGFloat minX = 0;

        minX = (contentViewWidth - titleSize.width) / 2.0 + CGRectGetMinX(topRect);

        self.titleLabel.frame = CGRectMake(minX, CGRectGetMinY(topRect), titleSize.width, titleSize.height);
        CGRectDivide(bottomRect, &topRect, &bottomRect, LXAlertViewTitleBottomMargin, CGRectMinYEdge);
    }
    
    if (self.messageLabel) {
        CGRectDivide(bottomRect, &topRect, &bottomRect, messageSize.height, CGRectMinYEdge);
        NSMutableAttributedString *messageAttrString = [[NSMutableAttributedString alloc] initWithString:self.messageLabel.text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 2.5;
        style.lineBreakMode = NSLineBreakByCharWrapping;
        [messageAttrString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, messageAttrString.length)];
        [messageAttrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0f] range:NSMakeRange(0, messageAttrString.length)];
        if (messageSize.height > 20) { // 系统字体12，2.5行间距，如果高度大于20，则表示多行
            style.alignment = NSTextAlignmentLeft;
        }
        else {
            style.alignment = NSTextAlignmentCenter;
        }
        self.messageLabel.attributedText = messageAttrString;
        self.messageLabel.numberOfLines = 0;
        self.messageLabel.frame = topRect;
        CGRectDivide(bottomRect, &topRect, &bottomRect, LXAlertViewMessageBottomMargin, CGRectMinYEdge);
    }
    
    if (self.contentView) {
        CGRectDivide(bottomRect, &topRect, &bottomRect, CGRectGetHeight(self.contentView.frame), CGRectMinYEdge);
        self.contentView.frame = topRect;
        CGRectDivide(bottomRect, &topRect, &bottomRect, LXAlertViewContentBottomMargin, CGRectMinYEdge);
    }
    
    if (self.buttonsArray.count > 0) {
        if (self.buttonLayout == LXAlertViewButtonLayoutHorizontal) {
            CGRectDivide(bottomRect, &topRect, &bottomRect, LXAlertViewButtonHeight, CGRectMinYEdge);
            CGFloat buttonWidth = (topRect.size.width - (self.buttonsArray.count - 1) * LXAlertViewButtonsMargin) / self.buttonsArray.count;
            buttonWidth = buttonWidth > 0 ? buttonWidth : 0;
            CGRect buttonRect = CGRectMake(topRect.origin.x, topRect.origin.y, buttonWidth, topRect.size.height);
            for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
                UIButton *button = [self.buttonsArray objectAtIndex:i];
                buttonRect.origin.x = topRect.origin.x + i * buttonWidth + i * LXAlertViewButtonsMargin;
                button.frame = buttonRect;
                [self configureButton:button];
            }
        }
        else if (self.buttonLayout == LXAlertViewButtonLayoutVertical) {
            CGRect buttonRect = CGRectMake(topRect.origin.x, bottomRect.origin.y, topRect.size.width, LXAlertViewButtonHeight);
            for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
                UIButton *button = [self.buttonsArray objectAtIndex:i];
                buttonRect.origin.y = bottomRect.origin.y + i * LXAlertViewButtonHeight + i * LXAlertViewButtonsMargin;
                button.frame = buttonRect;
                [self configureButton:button];
            }
        }
    }
}

- (void)configureButton:(UIButton *)button {
    if (button.tag == LXAlertViewCancelButtonTag) {
        [button setBackgroundColor:self.cancelButtonColor?self.cancelButtonBorderColor:[UIColor grayColor]];
        if (self.cancelButtonBorderColor) {
            button.layer.borderColor = self.cancelButtonBorderColor.CGColor;
        }
        [button setTitleColor:self.cancelButtonTitleColor?self.cancelButtonTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } else {
        // 其他按钮样式
        if (self.otherButtonBorderColor) {
            button.layer.borderColor = self.otherButtonBorderColor.CGColor;
        }
        [button setBackgroundColor:self.otherButtonColor?self.otherButtonColor:[UIColor whiteColor]];
        [button setTitleColor:self.otherButtonTitleColor?self.otherButtonTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
}

@end
