//
//  EUExInputTextFieldView.m
//  EUExInputTextFieldView
//
//  Created by xurigan on 15/3/9.
//  Copyright (c) 2015年 com.zywx. All rights reserved.
//

#import "EUExInputTextFieldView.h"
#import "InputChatKeyboard.h"
#import "InputXMLReader.h"
#import "InputChatKeyboardData.h"

@interface EUExInputTextFieldView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) InputChatKeyboard * chatKeyboard;
@property (nonatomic, strong) NSString * delete;
@property (nonatomic, strong) NSString * pageNum;
@property (nonatomic, strong) UITapGestureRecognizer * tapGR;
@end

@implementation EUExInputTextFieldView

-(id)initWithBrwView:(EBrowserView *)eInBrwView {
    if (self = [super initWithBrwView:eInBrwView]) {
        //
    }
    return self;
}

-(void)clean {
    if (_tapGR) {
        
        _tapGR.delegate = nil;
        _tapGR = nil;
    }
    if (_chatKeyboard) {
        [_chatKeyboard close];
        _chatKeyboard = nil;
    }
}

-(void)open:(NSMutableArray *)array {
    
    NSDictionary * xmlDic = [[array objectAtIndex:0] JSONValue];
    NSString * xmlPath = [self absPath:[xmlDic objectForKey:@"emojicons"]];
    
    NSString * placeHold = @"";
    if ([xmlDic objectForKey:@"placeHold"]) {
        placeHold = [xmlDic objectForKey:@"placeHold"];
    }
    [InputChatKeyboardData sharedChatKeyboardData].placeHold = placeHold;
    [self getFaceDicByFaceXMLPath:xmlPath];
    
    NSArray * facePathArray = [xmlPath componentsSeparatedByString:@"/"];
    NSString * fileName = [facePathArray lastObject];
    NSRange range = [xmlPath rangeOfString:fileName];
    xmlPath = [xmlPath substringToIndex:range.location];
    [InputChatKeyboardData sharedChatKeyboardData].facePath = xmlPath;
    
    
    if (!_chatKeyboard) {
        _chatKeyboard = [[InputChatKeyboard alloc]initWithUexobj:self];
        if([xmlDic objectForKey:@"bottom"]){
            _chatKeyboard.bottomOffset=[[xmlDic objectForKey:@"bottom"] floatValue];
        }
        [_chatKeyboard open];
        _tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard:)];
        
        [self.meBrwView addGestureRecognizer:_tapGR];
        
        _tapGR.delegate = self;
    
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (void)hideKeyboard:(NSMutableArray*)inArguments {
    
    if (_chatKeyboard) {
        
        [_chatKeyboard hideKeyboard];
        
    }
    
}

- (void)changeWebViewFrame:(NSMutableArray *)array {
    NSLog(@"进入changeWebViewFrame");
    float h = [[array objectAtIndex:0] floatValue];
    NSLog(@"height=%lf",h);
    if (_chatKeyboard) {
        [_chatKeyboard changeWebView:h];
    }
}

-(void)getShareDicFromSharePath:(NSString *)sharePath
{
    NSData * xmlData = [NSData dataWithContentsOfFile:sharePath];
    NSError * error;
    NSDictionary * xmlDic = [InputXMLReader dictionaryForXMLData:xmlData error: &error];
    NSDictionary * tempDic = [xmlDic objectForKey:@"shares"];
    [InputChatKeyboardData sharedChatKeyboardData].shareArray = [tempDic objectForKey:@"key"];
    [InputChatKeyboardData sharedChatKeyboardData].shareImgArray = [tempDic objectForKey:@"string"];
    [InputChatKeyboardData sharedChatKeyboardData].pageNum = [tempDic objectForKey:@"prePageNum"];
    
}

-(NSMutableDictionary *)getDicByKeyArray:(NSArray *)keyArray andStringArray:(NSArray *)stringArray
{
    NSMutableDictionary * reDic = [NSMutableDictionary dictionary];
    for (int i = 0; i < [keyArray count]; i++)
    {
        NSString * key = [[keyArray objectAtIndex:i] objectForKey:@"text"];
        NSString * string = [[stringArray objectAtIndex:i] objectForKey:@"text"];
        [reDic setObject:string forKey:key];
    }
    return reDic;
}

-(void)getFaceDicByFaceXMLPath:(NSString *)xmlPath
{
    NSData * xmlData = [NSData dataWithContentsOfFile:xmlPath];
    NSError * error;
    NSDictionary * xmlDic = [InputXMLReader dictionaryForXMLData:xmlData error: &error];
    NSDictionary * emojiconsDic = [xmlDic objectForKey:@"emojicons"];
    [InputChatKeyboardData sharedChatKeyboardData].faceArray = [emojiconsDic objectForKey:@"key"];
    [InputChatKeyboardData sharedChatKeyboardData].faceImgArray = [emojiconsDic objectForKey:@"string"];
    [InputChatKeyboardData sharedChatKeyboardData].deleteImg = [emojiconsDic objectForKey:@"delete"];
}

-(void)close:(NSMutableArray *)array {
    if (_chatKeyboard) {
        [_chatKeyboard close];
        _chatKeyboard = nil;
    }
}

-(void)setInputFocused:(NSMutableArray *)array {
    
    [_chatKeyboard.messageToolView.messageInputTextView becomeFirstResponder];

}
@end
