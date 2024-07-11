import Nat64 "mo:base/Nat64";

module {
    public type User = {
        id                : Principal;
        username          : Text;
        displayName       : Text;
        email             : Text;
        password          : Text;
        profileImg        : Text;
        bio               : Text;
        website           : Text;
        socialMedia       : [(SocialNetwork, Text)];
        walletAddr        : Text;
        location          : Text;
        portfolioUrl      : Text;
        notificationPrefs : [(NotificationType, Bool)];
        languagePref      : Text;
        termsAccepted     : Bool;
    };

    public type SocialNetwork = {#Twitter; #Facebook; #Instagram; #Linkedin; #Github; };
    public type NotificationType = {#Email; #SMS; #InApp; };

    public type Asset = {
        id                  : Nat;
        name                : Text;
        description         : Text;
        file                : Blob;
        fileFree            : ?Blob;
        preview             : [Blob];
        tags                : [Tag];
        licenseType         : LicenseType;
        price               : Nat64;
        currencyType        : CurrencyType;
        royaltyPercentage   : Float;
        communityPercentage : Float;
        creatorAddress      : Principal;
        cocreators          : Text;
        category            : Category;
        fontVersion         : Text;
        fontLicenceFile     : ?Blob;
        fontMetadata        : Text;
        fontOfTheDay        : Bool;
        termsAndConditions  : Bool;
        created             : Nat64;
        updated             : Nat64;
        status              : Status;
    };
    public type AssetList = {
        id             : Nat;
        name           : Text;
        description    : Text;
        preview        : [Blob];
        tags           : [Tag];
        licenseType    : LicenseType;
        price          : Nat64;
        currencyType   : CurrencyType;
        creatorAddress : Principal;
        category       : Category;
        fontVersion    : Text;
        fontMetadata   : Text;
        fontOfTheDay   : Bool;
        created        : Nat64;
        updated        : Nat64;
        status         : Status;
    };
    public type AssetPreview = {
        id             : Nat;
        name           : Text;
        description    : Text;
        fileFree       : ?Blob;
        preview        : [Blob];
        tags           : [Tag];
        licenseType    : LicenseType;
        price          : Nat64;
        currencyType   : CurrencyType;
        creatorAddress : Principal;
        category       : Category;
        fontVersion    : Text;
        fontMetadata   : Text;
        fontOfTheDay   : Bool;
        created        : Nat64;
        updated        : Nat64;
        status         : Status;
    };
    public type Image = {
        id          : Text;
        file        : Blob;
    };
    public type Tag = {
        id          : Text;
        name        : Text;
        description : Text;
    };
    public type LicenseType   = { #FreePersonalUse; #CommercialUse; #Licensed; };
    public type CurrencyType  = { #ICP; #DFONT; #CKETH; #CKBTC; #FIAT; };
    public type Category      = { #Serif; #SansSerif; #Script; #Display; #Handwritten; };
    public type Status        = { #Active; #Inactive; };
    public type PaymentResult = { #Success; #InsufficientBalance; #UnknownAsset; #UnknownUser; #PaymentFailed; #UnknownError; };
};