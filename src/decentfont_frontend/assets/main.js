import { Principal } from '@dfinity/principal';

export function initMain(decentfontActor) {
    let currentPage = 0;
    const pageSize = 10;
  
    async function addUser() {
        if (!decentfontActor) {
          alert("Please login first");
          return;
        }
      
        const user = {
          id: Principal.fromText("aaaaa-aa"),  // Placeholder Principal
          username: "testuser",
          displayName: "Test User",
          email: "test@example.com",
          password: "testpassword",
          profileImg: "",
          bio: "Test bio",
          website: "",
          socialMedia: [],
          walletAddr: "",
          location: "",
          portfolioUrl: "",
          notificationPrefs: [],
          languagePref: "en",
          termsAccepted: true
        };
        
        try {
          const result = await decentfontActor.addUser(user);
          document.getElementById('user-info').textContent = `User added: ${result}`;
        } catch (error) {
          console.error("Error adding user:", error);
          document.getElementById('user-info').textContent = `Error: ${error.message}`;
        }
      }
  
    async function getUser() {
      if (!decentfontActor) {
        alert("Please login first");
        return;
      }
  
      try {
        const user = await decentfontActor.getUser();
        document.getElementById('user-info').textContent = user ? JSON.stringify(user) : "No user found";
      } catch (error) {
        console.error("Error getting user:", error);
        document.getElementById('user-info').textContent = `Error: ${error.message}`;
      }
    }
  
    async function addAsset() {
      if (!decentfontActor) {
        alert("Please login first");
        return;
      }
  
      const asset = {
        name: "Test Font",
        description: "A test font asset",
        file: new Uint8Array([]).buffer,  // Empty Blob
        fileFree: [],  // Optional Blob
        preview: [],  // Array of Blobs
        tags: [],  // Array of Tags
        licenseType: { FreePersonalUse: null },
        price: 0,
        currencyType: { ICP: null },
        royaltyPercentage: 0,
        communityPercentage: 0,
        cocreators: "",
        category: { Serif: null },
        fontVersion: "1.0",
        fontLicenceFile: [],  // Optional Blob
        fontMetadata: "",
        fontOfTheDay: false,
        termsAndConditions: true,
        created: BigInt(Date.now()),
        updated: BigInt(Date.now()),
        status: { Active: null }
      };
      
      try {
        const [success, assetId] = await decentfontActor.addAsset(asset);
        document.getElementById('asset-list').innerHTML += `<p>Asset added: ${success}, ID: ${assetId}</p>`;
      } catch (error) {
        console.error("Error adding asset:", error);
        document.getElementById('asset-list').innerHTML += `<p>Error adding asset: ${error.message}</p>`;
      }
    }
  
    async function getAssetsList() {
      if (!decentfontActor) {
        alert("Please login first");
        return;
      }
  
      try {
        const assets = await decentfontActor.getListAssets(currentPage, pageSize);
        const assetListElement = document.getElementById('asset-list');
        assets.forEach(asset => {
          assetListElement.innerHTML += `<p>Asset: ${asset.name}, ID: ${asset.id}</p>`;
        });
        currentPage++;
      } catch (error) {
        console.error("Error getting assets list:", error);
        document.getElementById('asset-list').innerHTML += `<p>Error getting assets list: ${error.message}</p>`;
      }
    }
  
    async function getAssetPreview() {
      if (!decentfontActor) {
        alert("Please login first");
        return;
      }
  
      const assetId = document.getElementById('preview-asset-id').value;
      if (!assetId) {
        document.getElementById('preview-info').textContent = "Please enter an asset ID";
        return;
      }
      try {
        const preview = await decentfontActor.getAssetPreview(BigInt(assetId));
        document.getElementById('preview-info').textContent = preview ? JSON.stringify(preview) : "No preview found";
      } catch (error) {
        console.error("Error getting asset preview:", error);
        document.getElementById('preview-info').textContent = `Error: ${error.message}`;
      }
    }
  
    async function getFullAsset() {
      if (!decentfontActor) {
        alert("Please login first");
        return;
      }
  
      const assetId = document.getElementById('full-asset-id').value;
      if (!assetId) {
        document.getElementById('full-asset-info').textContent = "Please enter an asset ID";
        return;
      }
      try {
        const asset = await decentfontActor.getAsset(BigInt(assetId));
        document.getElementById('full-asset-info').textContent = asset ? JSON.stringify(asset) : "No asset found or not authorized";
      } catch (error) {
        console.error("Error getting full asset:", error);
        document.getElementById('full-asset-info').textContent = `Error: ${error.message}`;
      }
    }
  
    // Event Listeners
    document.getElementById('add-user-btn').addEventListener('click', addUser);
    document.getElementById('get-user-btn').addEventListener('click', getUser);
    document.getElementById('add-asset-btn').addEventListener('click', addAsset);
    document.getElementById('load-more-btn').addEventListener('click', getAssetsList);
    document.getElementById('get-preview-btn').addEventListener('click', getAssetPreview);
    document.getElementById('get-full-asset-btn').addEventListener('click', getFullAsset);
  
    // Initial load of assets
    getAssetsList();
  }