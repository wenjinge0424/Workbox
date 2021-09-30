//
//  Config.h
//
//  Created by IOS7 on 12/16/14.
//  Copyright (c) 2014 iOS. All rights reserved.
//

#import "AppStateManager.h"

#define UI_TEST                     NO

/* ***************************************************************************/
/* ***************************** Paypal config ********************************/
/* ***************************************************************************/
#define PAYPAL_APP_ID_SANDBOX       @"APP-"
#define PAYPAL_APP_ID_LIVE          @"APP-"
#define PAYPAL_IS_PRODUCT_MODE      YES
#define PAYPAL_APP_ID               (PAYPAL_IS_PRODUCT_MODE ? PAYPAL_APP_ID_LIVE : PAYPAL_APP_ID_SANDBOX)
#define PAYPAL_ENV                  (PAYPAL_IS_PRODUCT_MODE ? ENV_LIVE : ENV_SANDBOX)


/* ***************************************************************************/
/* ***************************** Stripe config ********************************/
/* ***************************************************************************/

#define STRIPE_KEY                              @""
//#define STRIPE_KEY                              @""
#define STRIPE_URL                              @"https://api.stripe.com/v1"
#define STRIPE_CHARGES                          @"charges"
#define STRIPE_CUSTOMERS                        @"customers"
#define STRIPE_TOKENS                           @"tokens"
#define STRIPE_ACCOUNTS                         @"accounts"
#define STRIPE_CONNECT_URL                      @"https://stripe.workbox.brainyapps.com"
#define STRIPE_CREATE_ACCOUNT_URL               @"https://dashboard.stripe.com/register"


#define APP_NAME                                                @"BmBrella"
#define APP_ID                                                  @"1316881441"
#define PARSE_FETCH_MAX_COUNT                                   10000
#define APP_THEME                                               [AppStateManager sharedInstance].app_theme
//#define APP_THEME                                                @"business"
#define APP_TEHME_CUSTOMER                                      @"customer"
#define APP_THEME_BUSINESS                                      @"business"

#define WEB_END_POINT_ITEM_SEARCH_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemSearch"
#define WEB_END_POINT_ITEM_LOOKUP_URL                           @"http://data.enzounified.com:19551/bsc/AmazonPA/ItemLookup/%@"

#define AUTH_TOKEN_KEY                                          @"98c9c3d6-6c1e-4b8a-acd3-9177a1176d90"

/* Friend / SO status values */
#define FRIEND_INVITE_SEND                                      @"Invite"
#define FRIEND_INVITE_ACCEPT                                    @"Accept"
#define FRIEND_INVITE_REJECT                                    @"Reject"

#define SO_INVITE_SEND                                          @"SOInviteSend"
#define SO_INVITE_ACCEPT                                        @"SOInviteAccept"
#define SO_INVITE_REJECT                                        @"SOInviteReject"

/* Pending Type values */
#define PENDING_TYPE_FRIEND_INVITE                              @"Pending_Friend_Invite"
#define PENDING_TYPE_SO_SEND                                    @"Pending_SO_Send"
#define PENDING_TYPE_INTANGIBLE_SEND                            @"Pending_Intangible_Send"

// Push Notification
#define PARSE_CLASS_NOTIFICATION_FIELD_TYPE                     @"type"
#define PARSE_CLASS_NOTIFICATION_FIELD_DATAINFO                 @"dataInfo"
#define PARSE_NOTIFICATION_APP_ACTIVE                           @"app_active"

/* Pagination values  */
#define PAGINATION_DEFAULT_COUNT                                10000
#define PAGINATION_START_INDEX                                  1

/* IWant Type values */
#define IWANT_INTANGIBLE_CATEGORY                                @"Intangible"

/* Notification values */
#define NOTIFICATION_SHOW_PENDING_PAGE                          @"ShowPending"
#define NOTIFICATION_HIDE_PENDING_PAGE                          @"HidePending"

#define NOTIFICATION_SHOW_INPUTSO_PAGE                          @"ShowInputSO"
#define NOTIFICATION_HIDE_INPUTSO_PAGE                          @"HideInputSO"

#define NOTIFICATION_SHOW_INTANGIBLE_PAGE                       @"ShowIntangible"
#define NOTIFICATION_HIDE_INTANGIBLE_PAGE                       @"HideIntangible"

#define NOTIFICATION_SHOW_SOPREVIEW_PAGE                        @"ShowSOPreview"
#define NOTIFICATION_HIDE_SOPREVIEW_PAGE                        @"HideSOPreview"

#define MAIN_COLOR          [UIColor colorWithRed:82/255.f green:123/255.f blue:255/255.f alpha:1.f]
#define MAIN_BORDER_COLOR   [UIColor colorWithRed:186/255.f green:186/255.f blue:186/255.f alpha:1.f]
#define MAIN_BORDER1_COLOR  [UIColor colorWithRed:209/255.f green:209/255.f blue:209/255.f alpha:1.f]
#define MAIN_BORDER2_COLOR  [UIColor colorWithRed:95/255.f green:95/255.f blue:95/255.f alpha:1.f]
#define MAIN_HEADER_COLOR   [UIColor colorWithRed:103/255.f green:103/255.f blue:103/255.f alpha:1.f]
#define MAIN_SWDEL_COLOR    [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
#define MAIN_DESEL_COLOR    [UIColor colorWithRed:206/255.f green:89/255.f blue:37/255.f alpha:1.f]
#define MAIN_HOLDER_COLOR   [UIColor colorWithRed:170/255.f green:170/255.f blue:170/255.f alpha:1.f]
#define MAIN_TRANS_COLOR    [UIColor colorWithRed:204/255.f green:227/255.f blue:244/255.f alpha:1.f]
#define MAIN_TEXT_COLOR     [UIColor grayColor]
#define MAIN_TEXT_PLACEHOLDER_COLOR [UIColor redColor]
/* Page Notifcation */
#define NOTIFICATION_START_PAGE                                 @"StartMainPage"
#define NOTIFICATION_SIGNIN_PAGE                                @"SignInPage"
#define NOTIFICATION_PASSWDRESET_PAGE                           @"PasswdResetPage"
#define NOTIFICATION_WANTLIST_PAGE                              @"WantListPage"
#define NOTIFICATION_PROFILE_PAGE                               @"ProfilePage"
#define NOTIFICATION_FRIENDS_PAGE                               @"FriendsPage"
#define NOTIFICATION_INVITE_PAGE                                @"InvitePage"
#define NOTIFICATION_INSTRUCTIONS_PAGE                          @"InstructionsPage"
#define NOTIFICATION_NEWITEM_PAGE                               @"NewItemPage"
#define NOTIFICATION_NEWCATEGORY_PAGE                           @"NewCategoryPage"
#define NOTIFICATION_HIDENEW_PAGE                               @"HideNewPage"

#define STRING_SUCCESS              @"Success"
#define STRING_ERROR                @"Error"


/*Error Message Config*/
#define USERNAME_IS_IN_USE      @"This email is already in use. Please use another."
#define     MESSAGE_ERROR_EMAIL_EMPTY               @"Please insert email."
#define     MESSAGE_ERROR_EMAIL_INCORRECT           @"Input email correctly."
#define     MESSAGE_ERROR_EMAIL_REGISTERED          @"Your email has already been registered."

#define     MESSAGE_ERROR_PASSWORD_EMPTY            @"Please insert password."
#define     MESSAGE_ERROR_PASSWORD_SHORT            @"Password must be at least 6 characters long."
#define     MESSAGE_ERROR_PASSWORD_LONG             @"Password must be at most 20 characters long."
#define     MESSAGE_ERROR_PASSWORD_UPPER            @"Password must contain uppercase letter."
#define     MESSAGE_ERROR_PASSWORD_LOWER            @"Password must contain lowercase letter."
#define     MESSAGE_ERROR_PASSWORD_NUMBER           @"Password must contain a number."

#define     MESSAGE_ERROR_NAME_FIRST_EMPTY          @"Please insert your first name."
#define     MESSAGE_ERROR_NAME_LAST_EMPTY           @"Please insert your last name."
#define     MESSAGE_ERROR_NAME_FIRST_SHORT          @"First name must be at least 6 characters long."
#define     MESSAGE_ERROR_NAME_FIRST_LONG           @"First name must be at most 20 characters long."
#define     MESSAGE_ERROR_NAME_LAST_SHORT           @"Last name must be at least 6 characters long."
#define     MESSAGE_ERROR_NAME_LAST_LONG            @"Last name must be at most 20 characters long."

#define     MESSAGE_ERROR_NO_AGREE                  @"We detected an error. Please agree to the Terms of Service and Privacy Policy to continue."

#define     MESSAGE_ERROR_INTERNET_NO_CONNECT       @"There is NO internet connection."
#define     MESSAGE_ERROR_UNKNOWN_OCCURED           @"Unknown error occurred."

#define     MESSAGE_ERROR_TOURNAMENT_NO_DATE        @"Please insert the date of new tournament."
#define     MESSAGE_ERROR_TOURNAMENT_WRONG_DATE     @"Please insert date correctly."

#define     MESSAGE_ERROR_PROFILE_NO_IMAGE          @"Please select your profile image."

#define     MESSAGE_ERROR_BUDGET_NOT_ENOUGH         @"You have not enough budget."
#define     MESSAGE_ERROR_MAX_USE_NO                @"You cannot join in this tournament. The number of users are at the maximum now."

#define     MESSAGE_ERROR_NO_USER                   @"You must add at least one participant."
#define     MESSAGE_ERROR_MAX_USER                  @"You can add up to 20 participants."

#define     MESSAGE_INFO_SKIP_AVATAR                @"Are you sure you want to proceed without a profile photo or video?"
#define     MESSAGE_INFO_HAVE_WILDCARD              @"You have a wildcard in your profile."

#define     MESSAGE_WATCH_CANNOT_PAIR               @"Please turn off and on your Smartwatch and try again."
#define     MESSAGE_WATCH_DEVICE_NO_SUPPORT         @"This accessory may not be supported."

#define     MESSAGE_JOIN_ERROR                      @"You are not allowed to join %@ until you are done with your existing %@."
#define     MESSAGE_CREATE_ERROR                    @"You are not allowed to create a tournament anymore."

#define     MESSAGE_PASSCODE_ERROR                  @"You must enter four-digit number to set as a passcode."
#define     MESSAGE_PASSCODE_EMPTY_ERROR            @"You must enter passcode."
#define     MESSAGE_PASSCODE_MISMATCH               @"You entered the wrong passcode, please try again."

#define     MESSAGE_VIDEO_EMPTY_ERROR               @"Please select a video to proceed."
#define     MESSAGE_TITLE_EMPTY_ERROR               @"Please input title."
#define     MESSAGE_CATEGORY_EMPTY_ERROR            @"Please choose a category."
#define     MESSAGE_PRIVACY_EMPTY_ERROR             @"Please choose a privacy setting."
#define     MESSAGE_PHOTO_EMPTY_ERROR               @"Please select a photo to proceed."

#define     MESSAGE_SUCCESS_PASSCODE_CHANGED        @"You have successfully set a new passcode!"
#define     MESSAGE_REPORT_EMPTY_ERROR              @"Please input report text."
#define     MESSAGE_REPORT_INPUT_ERROR              @"Minimum of 3 characters and maximum of 500."

#define     MESSAGE_SUCCESS_IAP_DONE                @"Purchase Successful!"
#define     MESSAGE_INFO_IAP_NEEDED                 @"To upload more private videos, please proceed to the In-App Purchase Screen."

#define     MESSAGE_PLAN_EMPTY_ERROR                @"Please input plan."

/* Refresh Notifcation */
#define NOTIFICATION_CHANGED_PAGE                               @"ChangedPage"
#define NOTIFICATION_START_CHAT                                 @"StartNewChat"

/* Remote Notification Type values */
#define REMOTE_NF_TYPE_NEW_ITEM                                 @"New_Iwant_Item"
#define REMOTE_NF_TYPE_NEW_CATEGORY                             @"New_Category"
#define REMOTE_NF_TYPE_FRIEND_INVITE                            @"Friend_Invite"
#define REMOTE_NF_TYPE_INVITE_ACCEPT                            @"Invite_Result_Accept"
#define REMOTE_NF_TYPE_INVITE_REJECT                            @"Invite_Result_Reject"
#define REMOTE_NF_TYPE_CLICK_EMPTY_CATEGORY                     @"Click_Empty_Category"
#define kChatReceiveNotification                                @"ChatReceiveNotification"
#define kChatReceiveNotificationUsers                           @"ChatReceiveNotificationUsers"
#define kNewAdPosted                                            @"kNewAdPosted"
#define kJobApproved                                @"kJobApproved"
#define kPlacebid                                @"kPlacebid"

#define PUSH_NOTIFICATION_TYPE                                  @"type"

/* JCWheelView Notification */
#define NOTIFICATION_SPIN_STOP                                  @"spin_stopped"

/* Spin Notification Data */
#define SPIN_POINT_X                                             @"point_x"
#define SPIN_POINT_Y                                             @"point_y"

//enum {
//    USER_TYPE_CUSTOMER = 100,
//    USER_TYPE_BUSINESS = 200,
//    USER_TYPE_ADMIN = 300
//};

enum {
    CHAT_TYPE_MESSAGE = 100,
    CHAT_TYPE_IMAGE = 200,
    CHAT_TYPE_VIDEO = 300
};

enum {
    PUSH_TYPE_CHAT = 1,
    PUSH_TYPE_BAN,
    PUSH_TYPE_NEW_POST,
    PUSH_TYPE_DEL_POST
};

enum {
    FLAG_TERMS_OF_SERVERICE,
    FLAG_PRIVACY_POLICY,
    FLAG_ABOUT_THE_APP
};

enum {
    REPORT_TYPE_POST = 100,
    REPORT_TYPE_USER = 200
};

/* Multi Languages */
#define KEY_LANGUAGE                                            @"KEY_LANGUAGE"
#define KEY_LANGUAGE_EN                                         @"English_en"
#define KEY_LANGUAGE_FR                                         @"French_fr"
#define KEY_LANGUAGE_AR                                         @"Arabic_ar"

/* Parse Table */
#define PARSE_FIELD_OBJECT_ID                                   @"objectId"
#define PARSE_FIELD_USER                                        @"user"
#define PARSE_FIELD_CHANNELS                                    @"channels"
#define PARSE_FIELD_CREATED_AT                                  @"createdAt"
#define PARSE_FIELD_UPDATED_AT                                  @"updatedAt"


// login type
enum {
    ACCOUNT_TYPE_WORKER,
    ACCOUNT_TYPE_EMPLOYER,
    ACCOUNT_TYPE_ADMIN
};


/* User Table */
#define PARSE_TABLE_USER                                        @"User"
#define FIELD_USER_TYPE                                   @"userType"
#define FIELD_FIRST_NAME                                   @"firstName"
#define FIELD_LAST_NAME                                    @"lastName"
#define PARSE_USER_FULL_NAME                                    @"fullName"
#define FIELD_EMAIL                                        @"email"
#define FIELD_PASSWORD                                    @"password"
#define FIELD_PREVIEW_PASSWORD                                    @"previewPassword"
#define FIELD_FACEBOOKID                                    @"facebookid"
#define FIELD_GOOOGLEID                                    @"googleid"
#define FIELD_AVATAR                                    @"avatar"
#define FIELD_IS_PAID                                    @"isPaid"
#define FIELD_IS_BANNED                                    @"isBanned"
#define FIELD_EXPERIENCE                                    @"experience"
#define FIELD_TOTAL_MONEY                                    @"totalMoney"
#define FIELD_LOCATION                                    @"location"
#define FIELD_GEOPOINT                                    @"geoPoint"
#define FIELD_NEAR_DISTANCE                                    @"nearDistance"
#define FIELD_SUBSCRIPTION                                    @"subscription"
#define FIELD_PAYMENTINFO                                    @"paymentInfo"
#define FIELD_CUR_BID_COUNT                                    @"currentBidCount"
#define FIELD_BID_COUNT_PERMONTH                                    @"bidCountPerMonth"
#define FIELD_PAID_AT                                    @"paidAt"
#define FIELD_INVITED_FACEBOOK_FRIENDS_ID                                    @"invitedId"
#define FIELD_COUNTED_INVITE_ID                                    @"countedInviteId"


#define TYPE_USER_HAVE                                    100
#define TYPE_USER_LOOKING                                    200
#define TYPE_ADMIN                                    300
#define TYPE_SUB_FREE                                    0
#define TYPE_SUB_10                                    10
#define TYPE_SUB_20                                    20
#define TYPE_SUB_25                                    250
#define AVATAR_SIZE                                    128
#define THUMBNAIL_SIZE                                    256


#define CURRENT_CATEGORY                                    @"current_category"

// notification type
#define  TYPE_NORMAL  1
#define  TYPE_CHAT  2
#define  TYPE_GROUP  3
#define  TYPE_JOB_POST  4
#define  TYPE_REVIEW_POST  5
#define  TYPE_PLACE_BID  6
#define  TYPE_JOB_APPROVED  7
#define  TYPE_PREFER_JOB_POST  8


// notification list on userdefault
#define UD_NOTIFICATIONS                                    @"UD_NOTIFICATIONS"
#define UD_LOOKING_JOBS @"UD_LOOKING_JOBS"

/* job */
#define  STATE_READY  0
#define  STATE_WAITING  1
#define  STATE_STARTED  2
#define  STATE_COMPLETED  3
#define  STATE_EXPIRED  4
#define  STATE_DECLINE  5

#define  FIELD_DATE  @"date"
#define  FIELD_CREATED_AT  @"createdAt"
#define  FIELD_LOCATION  @"location"
#define  FIELD_GEOPOINT  @"geoPoint"
#define  FIELD_OWNER  @"Owner"
#define  FIELD_TITLE  @"title"
#define  FIELD_CATEGORY  @"category"
#define  FIELD_DESCRIPTION  @"description"
#define  FIELD_BIDDERS  @"bidders"
#define  FIELD_PRICE_LIST @"priceList"
#define  FIELD_BIDTIME_LIST @"bidTimeList"
#define  FIELD_PAYMENTMETHOD  @"paymentMethod"
#define  FIELD_WORKER  @"worker"
#define  FIELD_STATE  @"state"
#define  FIELD_THUMBNAIL  @"thumbnail"
#define FIELD_THUMBNAIL_IS_VIDEO @"isVideo"
#define FIELD_VIDEO @"video"
#define  FIELD_POSITION  @"position"
#define  FIELD_START_BID_AMOUNT  @"startBidAmount"
#define FIELD_PARTICIPANTS @"participants"
#define FIELD_CHAT_ROOM_ID @"chat_room_id"
#define FIELD_REMOVELIST @"removeList"
#define FIELD_LAST_MESSAGE @"lastMessage"
#define FIELD_JOB_MODEL @"jobModel"

#define FIELD_CONTENT @"content"
#define FIELD_HEAD_LINE @"headLine"

#define FIELD_TO_USER @"toUser"
#define FIELD_MARK @"mark"
#define FIELD_CREATED_AT @"createdAt"
#define  FIELD_OWNER_1  @"owner"


#define FIELD_CARD_NUMBER @"cardNumber"
#define FIELD_EXP_DATE @"expDate"
#define FIELD_CVV @"CVV"
#define FIELD_COUNTRY @"country"
#define FIELD_STATE @"state"




/* Post Table */
#define PARSE_TABLE_POST                                        @"Posts"
#define PARSE_POST_OWNER                                        @"owner"
#define PARSE_POST_IMAGE                                        @"image"
#define PARSE_POST_CATEGORY                                     @"category"
#define PARSE_POST_TITLE                                        @"title"
#define PARSE_POST_TITLE_COLOR                                  @"titleColor"
#define PARSE_POST_LIKES                                        @"liked"
#define PARSE_POST_COMMENT_COUNT                                @"commentCount"

/* Chat Room */
#define PARSE_TABLE_CHAT_ROOM                                   @"ChatRoom"
#define PARSE_ROOM_SENDER                                       @"sender"
#define PARSE_ROOM_RECEIVER                                     @"receiver"
#define PARSE_ROOM_LAST_MESSAGE                                 @"lastMessage"
#define PARSE_ROOM_ENABLED                                      @"isAvailable"
#define PARSE_ROOM_IS_READ                                      @"isRead"
#define PARSE_ROOM_LAST_SENDER                                  @"message_sender"

/* Chat History */
#define PARSE_TABLE_CHAT_HISTORY                                @"Messages"
#define PARSE_HISTORY_ROOM                                      @"group"
#define PARSE_HISTORY_SENDER                                    @"sender"
#define PARSE_HISTORY_RECEIVER                                  @"receiver"
#define PARSE_HISTORY_TYPE                                      @"type"
#define PARSE_HISTORY_MESSAGE                                   @"text"
#define PARSE_HISTORY_IMAGE                                     @"picture"
#define PARSE_HISTORY_VIDEO                                     @"video"

/* Report Table */
#define PARSE_TABLE_REPORT                                      @"Report"
#define PARSE_REPORT_POST                                       @"post"
#define PARSE_REPORT_OWNER                                      @"owner"
#define PARSE_REPORT_REPORTER                                   @"reporter"
#define PARSE_REPORT_TYPE                                       @"type"
#define PARSE_REPORT_DESCRIPTION                                @"description"

/* Comment Table */
#define PARSE_TABLE_COMMENT                                     @"Comment"
#define PARSE_COMMENT_USER                                      @"user"
#define PARSE_COMMENT_POST                                      @"post"
#define PARSE_COMMENT_TEXT                                      @"comment"


#define AppStoreUrl                                      @"https://itunes.apple.com/us/app/work-box/id1359901850?ls=1&mt=8"
//https://itunes.apple.com/us/app/work-box/id1359901850?ls=1&mt=8
#define EDUCATION_ATTAINMENT               [[NSArray alloc] initWithObjects:@"High School", @"College", @"Diploma", @"Bachelor's", @"Post-Graduate", nil]
#define CATEGORY_ARRAY                     [[NSArray alloc] initWithObjects:@"Beauty & Salons", @"Brands", @"Cars", @"Daycare & Babysitting", @"Education & Tutorial", @"Elderly Care", @"Events", @"Homemade Food", @"Home Services", @"Hotels", @"Pet Care", @"Private Accommodation", @"Restaurants", @"Sports", @"Travel and Airlines", @"Volunteer", @"Other", nil]

#define COLOR_ARRAY                        [[NSArray alloc] initWithObjects:@"#333333", @"#cf2a28", @"#ff9900", @"#ffff00", @"#069e10", @"#0cffff", @"#2978e4",@"#9804ff",@"#fe03ff",nil]

#define CATEGORY_BAR_ARRAY                 [[NSArray alloc] initWithObjects:@"View All Ads", @"View all Categories", @"Daycare & Babysitting", @"Elderly Care", @"Restaurants", @"Homemade Food", @"Hotels", @"Private Accommodation", @"Events", @"Cars", @"Pet Care", @"Education & Tutorial", @"Sports", @"Volunteer", @"Home Services", @"Travel and Airlines", @"Beauty & Salons", @"Brands", nil]
#define CATEGORY_IC_ARRAY                 [[NSArray alloc] initWithObjects:@"ic_cat_all_ads", @"ic_cat_view_all", @"ic_cat_daycard", @"ic_cat_eld", @"ic_cat_rest", @"ic_cat_home", @"ic_cat_hotel", @"ic_cat_private", @"ic_cat_event", @"ic_cat_car", @"ic_cat_pet", @"ic_cat_educ", @"ic_cat_sport", @"ic_cat_vol", @"ic_cat_service", @"ic_cat_travel", @"ic_cat_beauty", @"ic_cat_brand", nil]




