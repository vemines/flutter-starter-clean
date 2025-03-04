const { faker } = require('@faker-js/faker');
const fs = require('fs');

function generateData() {
  let users = [];
  let posts = [];
  let comments = [];

  for (let i = 0; i < 10; i++) {
    const userDate = faker.date.past();
    const user = {
      id: faker.database.mongodbObjectId(),
      fullName: faker.person.fullName(),
      username: faker.internet.username(),
      password: faker.internet.password(),
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

  return {
    users: users,
    posts: posts,
    comments: comments,
  };
}

fs.writeFileSync('db.json', JSON.stringify(generateData(), null), 'utf-8');

console.log('db.json file has been generated');
