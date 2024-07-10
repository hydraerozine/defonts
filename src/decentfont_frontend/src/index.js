import { Actor, HttpAgent } from "@dfinity/agent";
import { AuthClient } from "@dfinity/auth-client";
import { idlFactory as decentfontIdlFactory } from "../../declarations/decentfont_backend/decentfont_backend.did.js";

const agent = new HttpAgent();
let canisterId = process.env.CANISTER_ID_DECENTFONT_BACKEND;

// Fetch the root key for the local replica
if (process.env.NODE_ENV !== "production") {
  agent.fetchRootKey().catch(err => {
    console.warn("Unable to fetch root key. Check to ensure that your local replica is running");
    console.error(err);
  });
}

let authClient;
let actor;

async function initializeAuthClient() {
  authClient = await AuthClient.create();
  if (await authClient.isAuthenticated()) {
    handleAuthenticated();
  }
}

async function handleAuthenticated() {
  const identity = await authClient.getIdentity();
  actor = Actor.createActor(decentfontIdlFactory, {
    agent: new HttpAgent({ identity }),
    canisterId,
  });
  document.getElementById('login-btn').textContent = 'Logout';
  document.getElementById('user-info').textContent = `Logged in as: ${identity.getPrincipal().toText()}`;
}

async function login() {
  const identityProviderUrl = process.env.DFX_NETWORK === "ic" 
    ? "https://identity.ic0.app" 
    : `http://${process.env.CANISTER_ID_INTERNET_IDENTITY}.localhost:4943`;

  authClient.login({
    identityProvider: identityProviderUrl,
    onSuccess: handleAuthenticated,
  });
}

async function logout() {
  await authClient.logout();
  actor = null;
  document.getElementById('login-btn').textContent = 'Login with Internet Identity';
  document.getElementById('user-info').textContent = '';
}

// Initialize auth client and set up event listeners
document.addEventListener('DOMContentLoaded', async () => {
  await initializeAuthClient();

  const loginButton = document.getElementById('login-btn');
  if (loginButton) {
    loginButton.addEventListener('click', async () => {
      if (await authClient.isAuthenticated()) {
        logout();
      } else {
        login();
      }
    });
  } else {
    console.error("Login button not found in the DOM");
  }
});

// Create an actor for the DecentFont canister
export const decentfontActor = actor || Actor.createActor(decentfontIdlFactory, {
  agent,
  canisterId,
});

// Import and initialize main.js
import { initMain } from "../assets/main.js";
document.addEventListener('DOMContentLoaded', () => {
  initMain(decentfontActor);
});

// Log environment variables for debugging
console.log("Environment variables:", {
  NODE_ENV: process.env.NODE_ENV,
  DFX_NETWORK: process.env.DFX_NETWORK,
  CANISTER_ID_INTERNET_IDENTITY: process.env.CANISTER_ID_INTERNET_IDENTITY,
  CANISTER_ID_DECENTFONT_BACKEND: process.env.CANISTER_ID_DECENTFONT_BACKEND,
});