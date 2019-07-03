@interface WhatsAppAppDelegate
-(void)setupChatHeadsIfNeeded;
- (void)reallyOpenChatWithPresenter:(id)arg1 animated:(_Bool)arg2;
-(void)handleMessageNamed:(NSString *)name withUserInfo:(id)userInfo;
@end

@interface WAChatSession : NSObject
@property(nonatomic) short sessionType; // @dynamic sessionType;
+ (id)managedObjectContextForJID:(id)arg1;
@property(copy, nonatomic) NSString *contactJID; // @dynamic contactJID;
- (id)groupMemberWithJIDString:(id)arg1;
@property(copy, nonatomic) NSSet *groupMembers; // @dynamic groupMembers;
@property(readonly, nonatomic, getter=isGroupChat) _Bool groupChat;
@property(copy, nonatomic) NSString *partnerName; // @dynamic partnerName;
- (id)groupMemberWithJIDString:(id)arg1;
- (id)groupMemberWithJID:(id)arg1;
@end


@interface WAUserJID
- (id)initWithPrimaryIdentifier:(id)arg1;
@end
@interface WAProfilePictureManager
+ (id)thumbnailFilePathForJID:(id)arg1 temporary:(bool)arg2;
@end

@interface WAMessage
@property(readonly, nonatomic) WAChatSession *chatSession; // @dynamic chatSession;
@property(readonly, nonatomic) NSString *senderJID;
@property(copy, nonatomic) NSString *fromJID; // @dynamic fromJID;
@property(copy, nonatomic) NSString *text; // @dynamic text;
@property(readonly, nonatomic) NSString *contactNameMedium;
@property(readonly, nonatomic, getter=isGhost) _Bool ghost;
@property(nonatomic) int messageType;
@property(readonly, nonatomic) int messageStatus; // @dynamic messageStatus;
@end

@interface WAChatPresenter{
    WAChatSession *_chatSession;
}
+ (id)forJIDString:(id)arg1;
+ (id)forChatSession:(id)arg1;
@end

@interface WAMessageNotificationCenter
- (_Bool)isChatWithJIDMuted:(id)arg1;
@end

@interface WAContact : NSObject
@property(readonly, copy, nonatomic) NSString *fullName;
- (id)initWithGroupMember:(id)arg1;
- (id)initWithUnknownJID:(id)arg1;
- (id)initWithUnknownJIDString:(id)arg1;
- (id)initWithGroupMember:(id)arg1;
@end
