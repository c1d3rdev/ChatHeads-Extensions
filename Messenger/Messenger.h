#import <UIKit/UIKit.h>

//Messenger
@interface MNAppDelegate
- (_Bool)application:(id)arg1 openURL:(id)arg2 sourceApplication:(id)arg3 annotation:(id)arg4;
@property(retain, nonatomic) UIWindow *window; // @synthesize window=_window;
-(void)setupChatHeadsIfNeeded;
@end

@interface MNInAppNotificationManager
- (void)navigateToThreadWithThreadKey:(id)arg1;
@end

@interface FBStringWithRedactedDescription
@property(readonly, copy, nonatomic) NSString *rawContentValueOnlyToBeVisibleToUser; // @synthesize rawContentValueOnlyToBeVisibleToUser=_rawContentValueOnlyToBeVisibleToUser;
@end

@interface FBMGroupThreadKey
@property(readonly, copy, nonatomic) NSString *threadFbId; // @synthesize threadFbId=_threadFbId;
@end
@interface FBMCanonicalThreadKey
@property(readonly, copy, nonatomic) NSString *userId; // @synthesize userId=_userId;
@end



@interface FBMSyncedThreadKey{
    unsigned long long _subtype;
    FBMGroupThreadKey *_groupThreadKey_groupThreadKey;
    FBMCanonicalThreadKey *_canonicalThreadKey_canonicalThreadKey;
}
+ (id)groupThreadKeyWithGroupThreadKey:(id)arg1;
+ (id)canonicalThreadKeyWithCanonicalThreadKey:(id)arg1;
@end

@interface FBMThreadKey
+ (id)syncedThreadKey:(id)arg1;
@end

@interface MNPushMessageNavigationHandler
- (void)_navigateToThread:(id)arg1 withInitialComposerExtensionIdentifier:(id)arg2;
@end


@interface FBMMessageAttachment
@property(readonly, copy, nonatomic) NSArray *jsonAttachments; // @synthesize jsonAttachments=_jsonAttachments;
@end


@interface FBMMontageMessageTypeInfo
@property(readonly, nonatomic) long long montageType; // @synthesize montageType=_montageType;
@end

@interface FBMIndexedThreadParticipationInfoSet : NSObject
- (id)participationInfoForUserWithId:(id)arg1;
@end

@interface FBMUserName
@property(readonly, copy, nonatomic) NSString *displayName; // @synthesize displayName=_displayName;
@property(readonly, copy, nonatomic) NSString *lastName; // @synthesize lastName=_lastName;
@property(readonly, copy, nonatomic) NSString *firstName; // @synthesize firstName=_firstName;
@end

@interface FBMUser
@property(readonly, copy, nonatomic) FBMUserName *name; // @synthesize name=_name;
@end


@interface MNAPNSMessage
@property(readonly, copy, nonatomic) NSString *senderId; // @synthesize senderId=_senderId;
@property(readonly, copy, nonatomic) FBMSyncedThreadKey *threadKey; // @synthesize threadKey=_threadKey;
@property(readonly, copy, nonatomic) FBStringWithRedactedDescription *text; // @synthesize text=_text;
@end

@interface FBMMessage
@property(readonly, copy, nonatomic) NSString *offlineThreadingId; // @synthesize offlineThreadingId=_offlineThreadingId;
@property(readonly, nonatomic) _Bool landToInbox; // @synthesize landToInbox=_landToInbox;
@property(readonly, copy, nonatomic) NSString *senderId; // @synthesize senderId=_senderId;
@property(readonly, copy, nonatomic) FBStringWithRedactedDescription *text; // @synthesize text=_text;
@property(readonly, copy, nonatomic) FBMSyncedThreadKey *threadKey; // @synthesize threadKey=_threadKey;
@property(readonly, copy, nonatomic) FBMMessageAttachment *attachment; // @synthesize attachment=_attachment;
@property(readonly, copy, nonatomic) NSArray *tags; // @synthesize tags=_tags;
@property(readonly, nonatomic) long long type; // @synthesize type=_type;
@property(readonly, copy, nonatomic) FBMMontageMessageTypeInfo *montageTypeInfo; // @synthesize montageTypeInfo=_montageTypeInfo;
@end


@interface MNProfileImageInfo
+ (id)profileImageWithIdentifiers:(id)arg1 profileImageSize:(unsigned long long)arg2;
@end

@interface MNThreadStore

@end

@interface FBContactStore
- (void)fetchContactWithId:(id)arg1 andCompletion:(id)arg2;
- (void)fetchContactsWithIds:(id)arg1 andCompletion:(id)arg2;
@end

@interface MNUserStore
- (id)handleMultipleUserRequest:(id)arg1;
- (id)handleSingleUserRequest:(id)arg1;
@end


@interface MNMultipleUserResponse
@property(readonly, copy, nonatomic) NSDictionary *usersByUserId; // @synthesize usersByUserId=_usersByUserId;
@end

@interface MNSingleUserResponse
@property(readonly, copy, nonatomic) FBMUser *user; // @synthesize user=_user;
@end



@protocol MNUserRequestListener <NSObject>
- (void)multipleUserRequest:(unsigned long long)arg1 didUpdatePreliminaryResult:(MNMultipleUserResponse *)arg2 longOperationDidBegin:(_Bool)arg3;
- (void)multipleUserRequest:(unsigned long long)arg1 didFailWithError:(NSError *)arg2;
- (void)multipleUserRequest:(unsigned long long)arg1 didSucceedWithResult:(MNMultipleUserResponse *)arg2;
- (void)singleUserRequest:(unsigned long long)arg1 didUpdatePreliminaryResult:(MNSingleUserResponse *)arg2 longOperationDidBegin:(_Bool)arg3;
- (void)singleUserRequest:(unsigned long long)arg1 didFailWithError:(NSError *)arg2;
- (void)singleUserRequest:(unsigned long long)arg1 didSucceedWithResult:(MNSingleUserResponse *)arg2;
@end

@interface FBMThreadSummary : NSObject
@end

@interface MNThreadSummaryCache
- (id)threadSummaryForThreadKey:(id)arg1;
- (id)allThreadSummaries;
@end

@interface MNProfileImageIdentifier
+ (id)userIdentifier:(id)arg1;
@end

@interface MNProfileImageUserIdentifier
- (id)initWithUserId:(id)arg1 profilePicHash:(id)arg2;
@end

@interface MNCDNProfileImageRequestFbId
+ (id)profileImageWithUserId:(id)arg1;
@end

@interface MNThreadImageManager
- (id)profileImageInfoForUser:(id)arg1 useLargeImage:(_Bool)arg2;
@end
