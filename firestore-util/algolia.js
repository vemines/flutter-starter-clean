// client.js
const admin = require("firebase-admin");
const { algoliasearch } = require("algoliasearch");
require("dotenv").config(); // Load environment variables

// --- Configuration (from .env or your environment) ---
const ALGOLIA_APP_ID = process.env.ALGOLIA_APP_ID;
const ALGOLIA_ADMIN_KEY = process.env.ALGOLIA_ADMIN_KEY;
const ALGOLIA_INDEX_NAME = process.env.ALGOLIA_INDEX_NAME;

// --- Configuration for remote firebase

// const FIREBASE_SERVICE_ACCOUNT_PATH = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;
// var serviceAccount = require(FIREBASE_SERVICE_ACCOUNT_PATH);
// admin.initializeApp({
//   credential: admin.credential.cert(serviceAccount),
// });

admin.initializeApp();
const db = admin.firestore();
db.settings({
  host: "localhost",
  port: 8080,
  ssl: false,
});

// --- Initialize Algolia Client ---
const client = algoliasearch(ALGOLIA_APP_ID, ALGOLIA_ADMIN_KEY);

// --- Indexing Function ---
async function indexPost(postData, postId) {
  try {
    // 1. Prepare the Algolia record
    const algoliaRecord = {
      objectID: postId, // Use Firestore document ID
      title: postData.title,
      body: postData.body,
      userId: postData.userId,
      imageUrl: postData.imageUrl,
      createdAt: Math.floor(postData.createdAt.toDate().getTime() / 1000), // Unix timestamp (seconds)
      updatedAt: Math.floor(postData.updatedAt.toDate().getTime() / 1000), // Unix timestamp (seconds)
    };

    // 2. Index the record into Algolia
    await client.saveObject({
      indexName: ALGOLIA_INDEX_NAME,
      body: algoliaRecord,
    });
    console.log(`Indexed post to Algolia: ${postId}`);
  } catch (error) {
    console.error(`Error indexing post ${postId} to Algolia:`, error);
    throw error; // Re-throw to prevent moving on to next operations
  }
}

// --- Deletion Function ---
async function deletePost(postId) {
  try {
    await client.deleteObject(postId);
    console.log(`Deleted post from Algolia: ${postId}`);
  } catch (error) {
    console.error(`Error deleting post ${postId} from Algolia:`, error);
    throw error;
  }
}

// --- Firestore Listener ---
const postsRef = db.collection("posts");
postsRef.onSnapshot(
  async (snapshot) => {
    try {
      for (const change of snapshot.docChanges()) {
        console.log(
          `Change detected - Type: ${change.type}, ID: ${change.doc.id}`
        );

        // if (change.type === "added" || change.type === "modified") {
        //   await indexPost(change.doc.data(), change.doc.id);
        // } else if (change.type === "removed") {
        //   await deletePost(change.doc.id);
        // }
      }
    } catch (error) {
      console.error("Error processing Firestore snapshot:", error);
    }
  },
  (error) => {
    console.error("Error listening to Firestore changes:", error);
  }
);

console.log(
  `Listening for Firestore changes on collection '${postsRef.path}' to update Algolia ...`
);
