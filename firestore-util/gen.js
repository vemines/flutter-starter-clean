// gen.js
const { faker } = require("@faker-js/faker");
const admin = require("firebase-admin");

const FIRESTORE_EMULATOR_HOST = "localhost:8080"; // Firestore emulator host
const AUTH_EMULATOR_HOST = "localhost:9099"; // auth emulator host

process.env.FIRESTORE_EMULATOR_HOST = FIRESTORE_EMULATOR_HOST;
process.env.FIREBASE_AUTH_EMULATOR_HOST = AUTH_EMULATOR_HOST;

// Initialize the Firebase Admin SDK (for emulators)
admin.initializeApp({
  // No credential needed for emulator.
  projectId: "local-firebase-7698b", // Use a placeholder, it won't affect the emulators
});

const db = admin.firestore();
// --- End Emulator Configuration ---

async function generateData() {
  let users = [];
  let posts = [];
  let comments = [];

  for (let i = 0; i < 10; i++) {
    const userDate = faker.date.past();
    const user = {
      id: faker.database.mongodbObjectId(),
      fullName: faker.person.fullName(),
      email: faker.internet.email(),
      about: faker.lorem.paragraphs(2),
      avatar: `https://picsum.photos/300/300?random=${i}`,
      cover: `https://picsum.photos/800/450?random=${i}`,
      createdAt: userDate,
      updatedAt: userDate,
      friendIds: [],
      bookmarkedPosts: [],
    };
    users.push(user);
  }

  let postCounter = 0;

  for (let i = 0; i < users.length; i++) {
    const user = users[i];
    for (let j = 0; j < 10; j++) {
      const postDate = faker.date.past();
      const post = {
        id: faker.database.mongodbObjectId(),
        userId: user.id,
        title: faker.lorem.sentence(),
        body: faker.lorem.paragraphs() + faker.lorem.paragraphs(),
        imageUrl: `https://picsum.photos/800/450?random=${postCounter}`,
        createdAt: postDate,
        updatedAt: postDate,
      };
      posts.push(post);

      postCounter++;

      for (let k = 0; k < 3; k++) {
        const commentDate = faker.date.past();
        const comment = {
          id: faker.database.mongodbObjectId(),
          postId: post.id,
          userId: faker.helpers.arrayElement(users).id,
          body: faker.lorem.sentence(),
          createdAt: commentDate,
          updatedAt: commentDate,
        };
        comments.push(comment);
      }
    }
  }

  // --- Write to Firestore ---
  const batch = db.batch(); // Use batched writes for efficiency

  users.forEach((user) => {
    const userRef = db.collection("users").doc(user.id);
    batch.set(userRef, user);
  });

  posts.forEach((post) => {
    const postRef = db.collection("posts").doc(post.id);
    batch.set(postRef, post);
  });

  comments.forEach((comment) => {
    const commentRef = db.collection("comments").doc(comment.id);
    batch.set(commentRef, comment);
  });

  await batch.commit(); // Commit the batched writes
  console.log("Data generated and written to Firestore Emulator!");
}

generateData().catch(console.error); // Call the function and handle errors
