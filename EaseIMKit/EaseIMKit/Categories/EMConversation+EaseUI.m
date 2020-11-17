//
//  EMConversation+EaseUI.m
//  EaseIMKit
//
//  Created by 杜洁鹏 on 2020/11/14.
//

#import "EMConversation+EaseUI.h"

#define EMConversationTop @"EMConversation_Top"
#define EMConversationShowName @"EMConversation_ShowName"
#define EMConversationRemindMe @"EMConversation_RemindMe"
#define EMConversationDraft @"EMConversation_Draft"

@implementation EMConversation (EaseUI)

- (void)setTop:(BOOL)isTop {
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:@(isTop) forKey:EMConversationTop];
    [self setExt:dictionary];
}

- (BOOL)isTop {
    return [self.ext[EMConversationTop] boolValue];
}

- (void)setShowName:(NSString *)aShowName {
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:aShowName forKey:EMConversationShowName];
    [self setExt:dictionary];
}

- (NSString *)showName {
    return self.ext[EMConversationShowName] ? self.ext[EMConversationShowName] : self.conversationId;
}

- (void)setDraft:(NSString *)aDraft {
    NSMutableDictionary *dictionary = [self mutableExt];
    [dictionary setObject:aDraft forKey:EMConversationDraft];
    [self setExt:dictionary];
}

- (NSString *)draft {
    return self.ext[EMConversationDraft] ? self.ext[EMConversationDraft] : @"";
}

- (BOOL)remindMe {
    //判断会话类型和消息是否包含@我
    if (self.type != EMConversationTypeGroupChat) {
        return NO;
    }
    BOOL ret = NO;
    NSArray *msgIds = [self remindMeDic].allKeys;
    for (NSString *msgId in msgIds) {
        EMMessage *msg = [self loadMessageWithId:msgId error:nil];
        if (!msg.isRead && msg.body.type == EMMessageBodyTypeText) {
            EMTextMessageBody *textBody = (EMTextMessageBody*)msg.body;
            if ([textBody.text containsString:[NSString stringWithFormat:@"@%@",EMClient.sharedClient.currentUsername]]) {
                ret = YES;
                break;
            }
        }
    }
    
    return ret;
}

- (NSMutableDictionary *)remindMeDic {
    NSMutableDictionary *dict = [(NSMutableDictionary *)self.ext[EMConversationRemindMe] mutableCopy];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    
    return dict;
}

- (NSMutableDictionary *)mutableExt {
    NSMutableDictionary *mutableExt = [self.ext mutableCopy];
    if (!mutableExt) {
        mutableExt = [NSMutableDictionary dictionary];
    }
    
    return mutableExt;
}


@end