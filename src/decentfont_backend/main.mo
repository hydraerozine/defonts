import Array     "mo:base/Array";
import Hash      "mo:base/Hash";
import HashMap   "mo:base/HashMap";
import Principal "mo:base/Principal";
import Nat       "mo:base/Nat";

import Types "/types";

shared(msg) actor class DecentFont() {

    private var NULL_PRINCIPAL: Principal = Principal.fromText("aaaaa-aa");
    private var ANON_PRINCIPAL: Principal = Principal.fromText("2vxsx-fae");
    private stable var idAsset : Nat = 1;

    func _idEqualNat( a : Nat, b : Nat) : Bool {
        return a == b;
    };
    func _idHashNat( a : Nat) : Hash.Hash {
        return Hash.hash(a);
    };

    private stable var _users : [(Principal, Types.User)] = [];
    var users : HashMap.HashMap<Principal, Types.User> = HashMap.fromIter(_users.vals(), 0, Principal.equal, Principal.hash);

    private stable var _assets : [(Nat, Types.Asset)] = [];
    var assets : HashMap.HashMap<Nat, Types.Asset> = HashMap.fromIter(_assets.vals(), 0, _idEqualNat, _idHashNat);

    private stable var _userAssets : [(Principal, [Nat])] = [];
    var userAssets : HashMap.HashMap<Principal, [Nat]> = HashMap.fromIter(_userAssets.vals(), 0, Principal.equal, Principal.hash);

    private stable var _userPurchases : [(Principal, [Nat])] = [];
    var userPurchases : HashMap.HashMap<Principal, [Nat]> = HashMap.fromIter(_userPurchases.vals(), 0, Principal.equal, Principal.hash);

    /// Get User Data
    /// If the user does not exist it will return null
    public shared query(msg) func getUser() : async ?Types.User {
        return users.get(msg.caller);
    };

    /// Add new user
    /// If the user already exists it will return false
    /// If the user is added successfully it will return true
    /// Social media is an array of tuples with the social network (Check supported types) and the username
    /// Notification prefs is an array of tuples with the notification type (Check supported types) and a boolean to enable or disable it
    public shared(msg) func addUser(user : Types.User) : async Bool {
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        var _u = users.get(msg.caller);
        switch(_u) {
            case (null){
                users.put(msg.caller, user);
                return true;
            };
            case (?_){
                return false;
            };
        };
    };

    /// Update user data
    /// If the user does not exist it will return false
    /// If the user is updated successfully it will return true
    public shared(msg) func updateUser(user : Types.User) : async Bool {
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        var _u = users.get(msg.caller);
        switch(_u) {
            case (null){
                return false;
            };
            case (?_nu){
                users.put(msg.caller, user);
                return true;
            };
        };
    };

    /// Add new asset and link it to user
    /// The function receives the asset data and returns the asset id
    /// The asset file must be a Blob
    /// The asset free file (if any) must be a Blob or null if there is no free file
    /// The images (if any) must be an array of Blobs
    /// The tags (if any) must be an array of Tags
    /// LicenseType must be one of the supported types
    /// CurrencyType must be one of the supported types
    /// Category must be one of the supported types
    /// Status must be one of the supported types
    public shared(msg) func addAsset(asset : Types.Asset) : async (Bool, Nat) {
        assert(msg.caller != NULL_PRINCIPAL and msg.caller != ANON_PRINCIPAL);
        assets.put(idAsset, asset);
        var _ua = userAssets.get(msg.caller);
        switch(_ua){
            case (null){
                userAssets.put(msg.caller, [idAsset]);
            };
            case (?_ua){
                userAssets.put(msg.caller, Array.append(_ua, [idAsset]));
            };
        };
        idAsset := idAsset + 1;
        return (true, idAsset - 1);
    };

    /// Get full asset data
    /// If the asset does not exist it will return null
    /// If the asset exists and the caller is the creator it will return the asset
    /// If the asset exists and the caller is not the creator it will return the asset if it is active and free
    /// If the asset exists and the caller is not the creator it will return the asset if it is active and the user has purchased it
    public shared query(msg) func getAsset(assetId : Nat) : async ?Types.Asset {
        switch(assets.get(assetId)){
            case (null){
                return null;
            };
            case (?_a){
                if(_a.creatorAddress == msg.caller){
                    return ?_a;
                };
                switch(_a.status){
                    case (#Active){
                        if(_a.price == 0){
                            return ?_a;
                        };
                        var _userPurchased = userPurchases.get(msg.caller);
                        switch(_userPurchased){
                            case (null){
                                return null;
                            };
                            case (?_p){
                                for(p in _p.vals()){
                                    if(p == assetId){
                                        return ?_a;
                                    };
                                };
                            };
                        };
                        return ?_a;
                    };
                    case (#Inactive){
                        return null;
                    };
                };
            };
        };
    };

    /// Get all my assets
    public shared query(msg) func getMyAssets() : async [Types.Asset] {
        var _userAssets = userAssets.get(msg.caller);
        switch(_userAssets){
            case (null){
                return [];
            };
            case (?_ua){
                var _assets : [Types.Asset] = [];
                for(a in _ua.vals()){
                    var _asset = assets.get(a);
                    switch(_asset){
                        case (null){
                            
                        };
                        case (?_a){
                            _assets := Array.append(_assets, [_a]);
                        };
                    };
                };
                return _assets;
            };
        };
    };

    /// Get a paginated list of assets
    /// The asset list is filtered by active status
    /// The asset list returns only part of the data. The asset file is not included
    public query func getListAssets(page : Nat, pageSize : Nat) : async [Types.AssetList] {
        var _start = page * pageSize;
        var _end = _start + pageSize;
        if(_end > assets.size()){
            _end := assets.size();
        };
        var _assets : [Types.AssetList] = [];
        var i = 0;
        for(a in _assets.vals()){
            if(i >= _start and i < _end){
                switch(a.status){
                    case (#Active){
                        let _assetListing : Types.AssetList = {
                            id             = a.id;
                            name           = a.name;
                            description    = a.description;
                            preview        = a.preview;
                            tags           = a.tags;
                            licenseType    = a.licenseType;
                            price          = a.price;
                            currencyType   = a.currencyType;
                            creatorAddress = a.creatorAddress;
                            category       = a.category;
                            fontVersion    = a.fontVersion;
                            fontMetadata   = a.fontMetadata;
                            fontOfTheDay   = a.fontOfTheDay;
                            created        = a.created;
                            updated        = a.updated;
                            status         = a.status;
                        };
                        _assets := Array.append(_assets, [a]);
                        i := i + 1;
                    };
                    case (#Inactive){};
                };
            };
        };
        return _assets;
    };

    /// Get asset preview
    /// If the asset does not exist it will return null
    /// If the asset exists it will return some data. The asset file is not included. The free file is included if it exists
    public query func getAssetPreview(assetId : Nat) : async ?Types.AssetPreview {
        switch(assets.get(assetId)){
            case (null){
                return null;
            };
            case (?a){
                switch(a.status){
                    case (#Active){
                        let _assetPreview : Types.AssetPreview = {
                            id             = a.id;
                            name           = a.name;
                            description    = a.description;
                            fileFree       = a.fileFree;
                            preview        = a.preview;
                            tags           = a.tags;
                            licenseType    = a.licenseType;
                            price          = a.price;
                            currencyType   = a.currencyType;
                            creatorAddress = a.creatorAddress;
                            category       = a.category;
                            fontVersion    = a.fontVersion;
                            fontMetadata   = a.fontMetadata;
                            fontOfTheDay   = a.fontOfTheDay;
                            created        = a.created;
                            updated        = a.updated;
                            status         = a.status;
                        };
                        return ?_assetPreview;
                    };
                    case (#Inactive){
                        return null;
                    };
                };
            };
        };
    };

};