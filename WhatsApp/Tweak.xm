#import "MHRequired.h"
#import "WhatsApp.h"

//Required variables
static BOOL enabled;
// static float keyboardHeight = 80;
static CPDistributedMessagingCenter *center;

//Shared instances from the app
static WAMessageNotificationCenter *muteChecker;

//Hook the AppDelegate to setup our global configs for ChatHeads
%hook WhatsAppAppDelegate
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2{
    bool o =  %orig;

    //Setup IPC
    center = [CPDistributedMessagingCenter centerNamed:@"com.c1d3r.messagehub"];
    rocketbootstrap_distributedmessagingcenter_apply(center);


    //For debug purposes
    [center sendMessageName:@"debug" userInfo:@{@"message":[NSString stringWithFormat:@"%@ launched and hooked!", [UIApplication displayIdentifier]]}];

    //Register the extension
    [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.c1d3r.messagehub.%@.didRegister", [UIApplication displayIdentifier]] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        enabled = [[notification.userInfo objectForKey:@"enabled"] boolValue];
    }];

    //Inbound messages from ChatHeads / ChatHeads to open the conversation for the correct ChatHead
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:[NSString stringWithFormat:@"com.c1d3r.messagehub.%@.openConversation", [UIApplication displayIdentifier]] object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
      if (enabled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reallyOpenChatWithPresenter:[%c(WAChatPresenter) forJIDString:[notification.userInfo objectForKey:@"conversationId"]] animated:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self reallyOpenChatWithPresenter:[%c(WAChatPresenter) forJIDString:[notification.userInfo objectForKey:@"conversationId"]] animated:NO];
            });
        });
      }
    }];

    return o;
}
%end


//Hook the message received method
%hook WAChatSessionTransaction
- (void)trackReceivedMessage:(id)arg1{

  //Register the extension in the event the app is dealloc'd
  [center sendMessageName:@"registerExtension" userInfo:@{@"bundleId" : [UIApplication displayIdentifier]}];

    %orig;

    //For debug purposes
    [center sendMessageName:@"debug" userInfo:@{@"message":@"WhatsApp message received..."}];

    if (enabled) {
      //Cast arg1 to WAMessage
      WAMessage *m = arg1;

      //Get the chatSession
      WAChatSession *session = m.chatSession;

      //If it's a story or the thread is muted, ignore it
      if ([muteChecker isChatWithJIDMuted:m.fromJID] | (session.sessionType == 3)){
          return;
      }

      //Setup the recipients array to return to ChatHeads
      NSMutableArray *recipients = [[NSMutableArray alloc] init];

      // Group chats are handled differently than normal conversations
      if (session.groupChat) {
        NSLog(@"[MH] groupChat!");

        //Get the user Ids in the group
        NSSet *groupMembers = [session valueForKey:@"groupMembers"];
        [groupMembers enumerateObjectsUsingBlock:^(id user, BOOL *stop){

          WAContact *contact = [[%c(WAContact) alloc] initWithGroupMember:user];
          NSString *name = [contact fullName] ? [contact fullName] : @"Unknown Sender";

          //Get the image for each user
          NSString *imagePath = [%c(WAProfilePictureManager) thumbnailFilePathForJID:[user valueForKey:@"userJID"] temporary:false];
          UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

          //Create a recipient
          NSMutableDictionary *recipient = [[NSMutableDictionary alloc] init];
          recipient[@"name"] = name;
          recipient[@"id"] = m.senderJID;
          recipient[@"imageData"] = image ? UIImagePNGRepresentation(image) : nil;
          [recipients addObject:recipient];
        }];
      }else{

        //Get the user
        id user = [[session valueForKey:@"chatJID"] valueForKey:@"userJIDIfUserOrIncomingStatusJID"];
        WAContact *contact = [[%c(WAContact) alloc] initWithUnknownJID:user];
        NSString *name = [contact fullName] ? [contact fullName] : @"Unknown Sender";

        //Get their profile picture
        NSString *imagePath = [%c(WAProfilePictureManager) thumbnailFilePathForJID:user temporary:false];
        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];

        //Create a recipient
        NSMutableDictionary *recipient = [[NSMutableDictionary alloc] init];
        recipient[@"name"] = name;
        recipient[@"id"] = m.senderJID;
        recipient[@"imageData"] = image ? UIImagePNGRepresentation(image) : nil;
        [recipients addObject:recipient];
      }

      //send the message and all of it's data to ChatHeads
      [center sendMessageName:@"messageReceived" userInfo:@{
        @"conversationId" : m.fromJID,
        @"recipients" : recipients,
        @"message" : m.text ? m.text : @"",
        @"bundleId" : [UIApplication displayIdentifier]
      }];
    }
}
%end

//Create a shared instances
%hook WAMessageNotificationCenter
- (id)initWithXMPPConnection:(id)arg1 chatStorage:(id)arg2{
    id o = %orig;
    muteChecker = o;
    return o;
}
%end

//Fix content inset bug
// %hook WAChatMessagesTableView
// -(void)setContentInset:(UIEdgeInsets)arg1 {
//   //For debug purposes
//   [center sendMessageName:@"debug" userInfo:@{@"message":[NSString stringWithFormat:@"%f contentInset!", keyboardHeight-40]}];
//
//   %orig(UIEdgeInsetsMake(arg1.top, arg1.left, keyboardHeight-40, arg1.right));
// }
// %end
