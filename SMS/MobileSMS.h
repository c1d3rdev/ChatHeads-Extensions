
//SMS

@interface CKMessagesController
- (void)_popToConversationListAndPerformBlockAnimated:(_Bool)arg1 block:(id)arg2;
- (void)showConversation:(id)arg1 animate:(_Bool)arg2;
@end

@interface SMSApplication
-(void)handleMessageNamed:(NSString *)name withUserInfo:(id)userInfo;
@property(retain, nonatomic) CKMessagesController *messagesController; // @synthesize messagesController=_messagesController;
-(void)setupChatHeadsWithCompletion:(void (^)(BOOL finished))completion;
@end

@class CNContact;
@interface CKEntity
@property (nonatomic,readonly) UIImage * transcriptContactImage;                        //@synthesize transcriptContactImage=_transcriptContactImage - In the implementation block
@property (nonatomic,retain) CNContact * cnContact;                                     //@synthesize cnContact=_cnContact - In the implementation block
-(UIImage *)transcriptContactImage;
@end

@interface IMMessage
@property (nonatomic,readonly) NSString * plainBody;
@end

@interface IMChat
@property (nonatomic,readonly) NSString * identifier;
-(NSString *)chatIdentifier;
@property (nonatomic,readonly) IMMessage * firstMessage;
@property (nonatomic,readonly) IMMessage * lastMessage;
@end

@interface CKConversation
-(IMChat *)chat;
@property (nonatomic,retain) IMChat * chat;                                                          //@synthesize chat=_chat - In the implementation block
@property (nonatomic,retain) NSArray * recipients;                                                   //@synthesize recipients=_recipients - In the implementation block
@end

@interface CKConversationList
+(id)sharedConversationList;
-(id)activeConversations;
-(id)conversations;
-(id)_conversationForChat:(id)arg1 ;
@end
