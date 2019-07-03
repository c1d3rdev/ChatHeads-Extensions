
#import <Contacts/Contacts.h>

#import "MHRequired.h"
#import "MobileSMS.h"

static float keyboardHeight = 80;
static CPDistributedMessagingCenter *center = nil;


%hook SMSApplication

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler{
  NSLog(@"[MH] userInfo: %@!", userInfo);
  %orig;
}

%new
-(void)setupChatHeadsWithCompletion:(void (^)(BOOL finished))completion{

  //For debug purposes, send a message saying we succesfully hooked the app
  [center sendMessageName:@"debug" userInfo:@{@"message":[NSString stringWithFormat:@"%@ launched and hooked!", [UIApplication displayIdentifier]]}];

  //Register the extension
  [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.c1d3r.messagehub.%@.didRegister", [UIApplication displayIdentifier]] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      completion(true);
  }];

  //Inbound messages from ChatHeads / MessageHub
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.c1d3r.messagehub.%@.openConversation", [UIApplication displayIdentifier]] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        //Find the conversation to open
        CKConversation *conversation;
        NSArray *conversations = [[NSClassFromString(@"CKConversationList") sharedConversationList] conversations];
        for (CKConversation *c in conversations){
            if ([c.chat.chatIdentifier isEqualToString:[notification.userInfo objectForKey:@"conversationId"]]){
                conversation = c;
                break;
            }
        }

        //Open the conversation. We all this twice, the first time right away,
        //the second, after a slight delay, just to ensure it responds.
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.messagesController showConversation:conversation animate:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self.messagesController showConversation:conversation animate:NO];
            });
        });
  }];

  // This could be in an init method.
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
}

%new
- (void)keyboardWillAppear:(NSNotification *)notification {
  keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
}


//Message received hook
- (void)_messageReceived:(NSConcreteNotification *)arg1{

    //Register the extension
    [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];

    // Do the original implementation
    %orig;

    [(SMSApplication *)[[UIApplication sharedApplication] delegate] setupChatHeadsWithCompletion:^(BOOL finished){
      NSLog(@"[MH] got callback!");
        __block IMChat *m = arg1.object;

        // Find the corresponding conversationId
        CKConversation *conversation;
        NSArray *conversations = [[%c(CKConversationList) sharedConversationList] conversations];
        for (CKConversation *c in conversations){
            if ([c.chat.chatIdentifier isEqualToString:m.chatIdentifier]){
                conversation = c;
                break;
            }
        }

        // Find the contacts
        NSMutableArray *recipients = [[NSMutableArray alloc] init];
        if (conversation.recipients.count > 0){
            for (int i=0; i<conversation.recipients.count; i++){
                NSMutableDictionary *recipient = [[NSMutableDictionary alloc] init];
                CKEntity *e = (CKEntity *)conversation.recipients[i];
                CNContact *contact = e.cnContact;

                NSString *name;
                if (contact.nickname.length > 0) {
                  name = contact.nickname;
                }else{
                  //Some protection against null values
                  NSString *first = contact.givenName ? contact.givenName : @"";
                  NSString *last = contact.familyName ? contact.familyName : @"";

                  name = [NSString stringWithFormat:@"%@ %@", first, last];
                }

                recipient[@"name"] = name;
                recipient[@"id"] = contact.identifier;
                recipient[@"imageData"] = contact.thumbnailImageData;

                [recipients addObject:recipient];
            }
        }

        // Send it to MessageHub
        [center sendMessageName:@"messageReceived" userInfo:@{
          @"conversationId" : m.chatIdentifier,
          @"recipients" : recipients,
          @"message" : m.lastMessage.plainBody ? m.lastMessage.plainBody : @"",
          @"bundleId" : [UIApplication displayIdentifier]
        }];
    }];
}

%end


//Fix content inset bug
%hook CKTranscriptCollectionView
-(void)setContentInset:(UIEdgeInsets)arg1 {
  %orig(UIEdgeInsetsMake(arg1.top, arg1.left, keyboardHeight, arg1.right));
}
%end

%ctor {
  //Setup IPC
  center = [CPDistributedMessagingCenter centerNamed:@"com.c1d3r.messagehub"];
  rocketbootstrap_distributedmessagingcenter_apply(center);
}
