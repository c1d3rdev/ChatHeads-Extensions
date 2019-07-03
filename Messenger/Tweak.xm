
#import "MHRequired.h"
#import "Messenger.h"

// Required variables
static CPDistributedMessagingCenter *center;

// Shared instances from the app
static NSString *currentUserId;
static MNThreadSummaryCache *threadCache;
static FBContactStore *contactStore;

%hook UIApplicationDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
    bool o =  %orig;
    NSLog(@"[MH] FBM launched!");
    [(MNAppDelegate *)[[UIApplication sharedApplication] delegate] setupChatHeadsIfNeeded];
    return o;
}
%end

%hook MNPushNotificationEventTracker

- (void)didReceiveAPNSPayloadOverPushKitWithType:(int)arg1 messageId:(id)arg2 threadId:(id)arg3{
  [(MNAppDelegate *)[[UIApplication sharedApplication] delegate] setupChatHeadsIfNeeded];

  NSMutableString *string = [[NSMutableString alloc] init];
  if (center) {
    NSLog(@"[MH] ✅ IPC");
    [string appendString:@"✅ IPC\n"];
  }else{
    NSLog(@"[MH] ❌ IPC");
    [string appendString:@"❌ IPC\n"];
  }

  if (contactStore) {
    NSLog(@"[MH] ✅ contactStore");
    [string appendString:@"✅ ContactStore\n"];
  }else{
    [string appendString:@"❌ ContactStore\n"];
    NSLog(@"[MH] ❌ contactStore");
  }

  if (currentUserId) {
    [string appendString:@"✅ currentUserId\n"];
    NSLog(@"[MH] ✅ currentUserId");
  }else{
    [string appendString:@"❌ currentUserId\n"];
    NSLog(@"[MH] ❌ currentUserId");
  }

  [center sendMessageName:@"debug" userInfo:@{@"message":string}];

  %orig;
}

%end









// Hook the AppDelegate to setup our global configs for ChatHeads
%hook MNAppDelegate
%new
-(void)setupChatHeadsIfNeeded{
  NSLog(@"[MH] setupChatHeadsIfNeeded");
  center = [CPDistributedMessagingCenter centerNamed:@"com.c1d3r.messagehub"];
  rocketbootstrap_distributedmessagingcenter_apply(center);
  
  //Register the extension
  [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];
  
  //Inbound messages from ChatHeads / ChatHeads to open the conversation for the correct ChatHead
  [[NSDistributedNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.c1d3r.messagehub.%@.openConversation", [UIApplication displayIdentifier]] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      dispatch_async(dispatch_get_main_queue(), ^{
          [self application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@",  [notification.userInfo objectForKey:@"conversationId"]]] sourceApplication:nil annotation:nil];
          dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
              [self application:[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb-messenger://user-thread/%@",  [notification.userInfo objectForKey:@"conversationId"]]] sourceApplication:nil annotation:nil];
          });
      });
  }];
  [center sendMessageName:@"debug" userInfo:@{@"message":@"Messenger did finish setup!"}];
}
%end


//Hook the message received method
%hook MNPushMessageHandler
- (void)handleSyncMessage:(id)arg1{
  //Setup chatheads if needed
  [(MNAppDelegate *)[[UIApplication sharedApplication] delegate] setupChatHeadsIfNeeded];

  //Incase the app goes has shutdown, re-register
  [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];
  [center sendMessageName:@"debug" userInfo:@{@"message":@"Messenger received!"}];


  %orig;


  //Cast arg1 to FBMessage
  FBMMessage *m = (FBMMessage *)arg1;

  NSLog(@"[MH Got here!]");

  //If it's a story, ignore it
  if ([m.tags containsObject:@"montage"])
    return;

  //if the user sent the message, ignore it
  if ([currentUserId isEqualToString:m.senderId]){
    return;
  }

  //Start processing the message
  NSString *text = m.text.rawContentValueOnlyToBeVisibleToUser;
  NSString *key;

  //Get the thread ID
  FBMGroupThreadKey *groupKey = MSHookIvar<id>(m.threadKey, "_groupThreadKey_groupThreadKey");
  FBMCanonicalThreadKey *singleKey = MSHookIvar<id>(m.threadKey, "_canonicalThreadKey_canonicalThreadKey");
  if (groupKey){
      key = groupKey.threadFbId;
  }else{
      key = singleKey.userId;
  }

  //Get the thread info, to figure out who is in it
  FBMThreadSummary *thread = [threadCache threadSummaryForThreadKey:m.threadKey];
  FBMIndexedThreadParticipationInfoSet *info = [thread valueForKey:@"_participationInfoCollection"];
  NSArray *users = [info valueForKey:@"_participants"];

  //Now to parse each user in the chat and get their info
  NSMutableArray *recipients = [[NSMutableArray alloc] init];
  NSMutableArray *imagesArray = [[NSMutableArray alloc] init];

  for (int i=0; i<users.count; i++){
    NSString *userId = [users[i] valueForKey:@"_userId"];

    //Get the user's info
    [contactStore fetchContactWithId:userId andCompletion:^(/*FBContactSyncUser*/ id user){

      //Get the profile picture
      NSString *imageString = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];

      //Download the photo async
      dispatch_async(dispatch_get_global_queue(0,0), ^{
          NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:imageString]];

          dispatch_async(dispatch_get_main_queue(), ^{
            //Got the profile picture, now to convert it to data
            [imagesArray addObject:imageData];

            //Create a recipient with the required info, Name, Id, and imageData
            NSMutableDictionary *recipient = [[NSMutableDictionary alloc] init];
            recipient[@"name"] = [[user valueForKey:@"_name"] valueForKey:@"_displayName"];
            recipient[@"id"] = [user valueForKey:@"_userId"];
            recipient[@"imageData"] = imageData;
            [recipients addObject:recipient];

            //If we've downloaded and added all of the users in the convo, send it to ChatHeads
            if (imagesArray.count == users.count) {
              [center sendMessageName:@"messageReceived" userInfo:@{
                @"conversationId" : key,
                @"recipients" : recipients,
                @"message" : text ? text : @"",
                @"bundleId" : [UIApplication displayIdentifier]
              }];
            }
          });
      });
    }];
  }
}
%end


//Create a shared instances
%hook FBContactStore
- (id)initWithOmnistore:(id)arg1 userSession:(id)arg2 analytics:(id)arg3 lruUserCache:(id)arg4 profileImageCachingRunner:(id)arg5 userStoreInvalidatingRunner:(id)arg6 fastProfilePicHashEnabled:(_Bool)arg7 configManager:(id)arg8{
  id o = %orig;
  NSLog(@"[MH] FBContactStore");
  contactStore = o;
  return o;
}
%end

//Create a shared instances
%hook MNThreadSummaryCache
- (id)initWithListener:(id)arg1 singleUpdateListener:(id)arg2 annotatedUpdateListener:(id)arg3 queue:(id)arg4{
  id o = %orig;
  NSLog(@"[MH] MNThreadSummaryCache");
  threadCache = o;
  return o;
}
%end

//Get current user ID
%hook FBUserSession
- (id)initWithApiSessionStore:(id)arg1{
  id o = %orig;
  NSLog(@"[MH] initWithApiSessionStore");
  currentUserId = [o valueForKey:@"loggedInAccountID"];
  return o;
}
%end
