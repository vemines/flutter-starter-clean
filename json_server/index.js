// index.js
const { faker } = require('@faker-js/faker');
const jsonServer = require('@wll8/json-server');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();
const _ = require('lodash');

server.use(middlewares);
server.use(jsonServer.bodyParser);

const delayMiddleware = (delay) => (req, res, next) => {
  setTimeout(next, delay);
};

const DELAY_MS = 500;
server.use(delayMiddleware(DELAY_MS));

// Custom middleware for request modification
server.use((req, res, next) => {
  if (req.method === 'POST') {
    req.body.createdAt = new Date().toISOString();
    req.body.updatedAt = new Date().toISOString();
  } else if (req.method === 'PATCH' || req.method === 'PUT') {
    req.body.updatedAt = new Date().toISOString();
  }
  next();
});

// Handle CORS preflight requests
server.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.sendStatus(200);
});

const secretText = 'some secret text';

server.post('/api/v1/verify', (req, res) => {
  const { secret } = req.body;
  if (secret === secretText) {
    return res.status(200).jsonp({
      message: 'Verified.',
    });
  }
  return res.status(403).jsonp({
    error: 'Unauthentication',
  });
});

// Custom Login Endpoint (POST /api/v1/login)
server.post('/api/v1/login', (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    return res.status(400).jsonp({
      error: 'Email and password are required.',
    });
  }

  const users = router.db.get('users').value(); // Access the 'users' array
  const user = users.find((u) => u.username === username && u.password === password);

  if (user) {
    const { password, ...userWithoutPassword } = user; // Remove password
    res.jsonp({ secret: secretText, ...userWithoutPassword });
  } else {
    res.status(401).jsonp({ error: 'Login failure!' });
  }
});

// Custom Register Endpoint (POST /api/v1/register)
server.post('/api/v1/register', (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) {
    return res.status(400).jsonp({ error: 'Missing required fields.' });
  }

  const users = router.db.get('users').value();
  if (users.find((u) => u.email === email)) {
    return res.status(409).jsonp({ error: 'Email already registered.' });
  }
  if (users.find((u) => u.username === username)) {
    return res.status(409).jsonp({ error: 'username already registered.' });
  }

  const newUser = {
    id: faker.database.mongodbObjectId(),
    fullName: username,
    username,
    email,
    password,
    about: faker.lorem.paragraphs(),
    avatar: `https://picsum.photos/300/300?random=${users.length + 2}`,
    cover: `https://picsum.photos/800/450?random=${users.length + 2}`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    friendIds: [],
    bookmarkedPosts: [],
  };

  router.db.get('users').push(newUser).write(); // Add the new user

  const { password: _, ...userWithoutPassword } = newUser;
  res.status(201).jsonp({ secret: secretText, ...userWithoutPassword }); // 201 Created
});

// Update bookmarked posts (NOW ON THE USER)
server.patch('/api/v1/users/:id/bookmark', (req, res) => {
  const userId = req.params.id;
  const { postId } = req.body;

  if (!postId) {
    return res.status(400).jsonp({ error: 'postId is required' });
  }

  const user = router.db.get('users').find({ id: userId }).value();
  if (!user) {
    return res.status(404).jsonp({ error: 'User not found' });
  }

  const post = router.db.get('posts').find({ id: postId }).value();
  if (!post) {
    return res.status(404).jsonp({ error: 'Post not found' });
  }

  let bookmarkedPosts = user.bookmarkedPosts || [];
  if (bookmarkedPosts.includes(postId)) {
    bookmarkedPosts = bookmarkedPosts.filter((id) => id !== postId); // Remove if already bookmarked
  } else {
    bookmarkedPosts.push(postId); // Add if not bookmarked
  }

  router.db.get('users').find({ id: userId }).assign({ bookmarkedPosts }).write();
  res.jsonp(router.db.get('users').find({ id: userId }).value());
});

// Update friend list
server.patch('/api/v1/users/:id/friends', (req, res) => {
  const userId = req.params.id;
  const { friendIds } = req.body; // Expect an array of friend IDs

  if (!Array.isArray(friendIds)) {
    return res.status(400).jsonp({ error: 'friendIds must be an array' });
  }

  const user = router.db.get('users').find({ id: userId }).value();
  if (!user) {
    return res.status(404).jsonp({ error: 'User not found' });
  }

  // Basic validation: Check if all friend IDs are valid users
  const users = router.db.get('users').value();
  const allUserIds = users.map((u) => u.id);
  if (!friendIds.every((friendId) => allUserIds.includes(friendId))) {
    return res.status(400).jsonp({ error: 'Invalid friendId(s) provided' });
  }

  router.db.get('users').find({ id: userId }).assign({ friendIds }).write();
  res.jsonp(router.db.get('users').find({ id: userId }).value());
});

// Get user + posts + comments + bookmarked posts
server.get('/api/v1/users/:id/details', (req, res) => {
  const userId = req.params.id;
  const user = router.db.get('users').find({ id: userId }).value();

  if (!user) {
    return res.status(404).jsonp({ error: 'User not found' });
  }

  const posts = router.db.get('posts').filter({ userId: userId }).value();
  const comments = router.db.get('comments').filter({ userId: userId }).value();
  const { friendIds } = user;

  res.jsonp({ friends: friendIds.length, posts: posts.length, comments: comments.length });
});

// Add comment to post (with user details)
server.post('/api/v1/posts/:postId/comments', (req, res) => {
  const postId = req.params.postId;
  const { userId, body } = req.body;
  console.log(postId, userId, body);

  if (!userId || !body) {
    return res.status(400).jsonp({ error: 'userId and body are required' });
  }

  const post = router.db.get('posts').find({ id: postId }).value();
  if (!post) {
    return res.status(404).jsonp({ error: 'Post not found' });
  }
  const user = router.db.get('users').find({ id: userId }).value();

  if (!user) {
    console.log('no user');
    return res.status(404).jsonp({ error: 'User not found' });
  }

  const { password, ...userWithoutPassword } = user;

  const newComment = {
    id: faker.database.mongodbObjectId(),
    postId,
    userId,
    body,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  router.db.get('comments').push(newComment).write();
  res.status(201).jsonp({ ...newComment, user: userWithoutPassword });
});

// Get comments for a post with user details (reload post comments)
server.get('/api/v1/posts/:id/comments', (req, res) => {
  const postId = req.params.id;
  const page = parseInt(req.query._page) || 1;
  const limit = parseInt(req.query._limit) || 10;
  const sortField = req.query._sort || 'updatedAt';
  const sortOrder = req.query._order || 'desc';

  let comments = router.db.get('comments').filter({ postId }).value();

  // Sorting
  comments = _.orderBy(comments, [sortField], [sortOrder]);

  // Pagination
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  comments = comments.slice(startIndex, endIndex);

  const commentsWithUserDetails = comments.map((comment) => {
    const user = router.db.get('users').find({ id: comment.userId }).value();
    if (!user) return { ...comment, user: null };
    const { password, ...userWithoutPassword } = user;
    return {
      ...comment,
      user: userWithoutPassword,
    };
  });

  res.jsonp(commentsWithUserDetails);
});

// Edit comment (check if author)
server.patch('/api/v1/comments/:id', (req, res) => {
  const commentId = req.params.id;
  const { userId, body } = req.body;

  const comment = router.db.get('comments').find({ id: commentId }).value();
  console.log(commentId, userId, comment);
  if (!comment) {
    return res.status(404).jsonp({ error: 'Comment not found' });
  }

  if (comment.userId !== userId) {
    console.log(comment.userId, userId);
    return res.status(403).jsonp({ error: 'Unauthorized: You can only edit your own comments' });
  }

  const user = router.db.get('users').find({ id: userId }).value();

  if (!user) {
    console.log('no user');
    return res.status(404).jsonp({ error: 'User not found' });
  }
  const { password, ...userWithoutPassword } = user;

  if (body) {
    router.db
      .get('comments')
      .find({ id: commentId })
      .assign({ body, updatedAt: new Date().toISOString() })
      .write();
  }

  res.jsonp({
    ...router.db.get('comments').find({ id: commentId }).value(),
    user: userWithoutPassword,
  });
});

// Delete comment (check if author)
server.delete('/api/v1/comments/:id', (req, res) => {
  const commentId = req.params.id;
  const { userId } = req.body; // Send userId in the body for delete too

  const comment = router.db.get('comments').find({ id: commentId }).value();
  if (!comment) {
    return res.status(404).jsonp({ error: 'Comment not found' });
  }

  if (comment.userId !== userId) {
    return res.status(403).jsonp({ error: 'Unauthorized: You can only delete your own comments' });
  }

  router.db.get('comments').remove({ id: commentId }).write();
  res.jsonp({ message: 'Comment deleted' });
});

// Get all users (excluding a specific user) with pagination
server.get('/api/v1/users', (req, res) => {
  const excludeUserId = req.query.exclude; // Get the user ID to exclude
  const page = parseInt(req.query._page) || 1; // Get page number (default 1)
  const limit = parseInt(req.query._limit) || 10; // Get items per page (default 10)
  const sortField = req.query._sort || 'id'; // Get sort field (default 'id')
  const sortOrder = req.query._order || 'desc'; // Get sort order (default 'asc')

  let users = router.db.get('users').value();

  // Exclude the specified user
  if (excludeUserId !== '') {
    // important check, make it robust
    users = users.filter((user) => user.id !== excludeUserId);
  }

  // Sort users (using lodash for consistent sorting)
  users = _.orderBy(users, [sortField], [sortOrder]);

  // Paginate
  const startIndex = (page - 1) * limit;
  const endIndex = page * limit;
  const paginatedUsers = users.slice(startIndex, endIndex);

  // Remove passwords before sending the response
  const usersWithoutPasswords = paginatedUsers.map((user) => {
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  });

  res.jsonp(usersWithoutPasswords);
});

server.post('/api/v1/posts', (req, res) => {
  const { userId, title, body } = req.body;

  if (!userId || !title || !body) {
    return res.status(400).jsonp({ error: 'userId, title, and body are required' });
  }

  // Check if the user exists
  const user = router.db.get('users').find({ id: userId }).value();
  if (!user) {
    return res.status(404).jsonp({ error: 'User not found' });
  }

  const newPost = {
    id: faker.database.mongodbObjectId(), // Generate a MongoDB-like ID
    userId,
    title,
    body,
    imageUrl: `https://picsum.photos/800/450?random=${faker.number.int({
      min: 1000,
      max: 9000000,
    })}`,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  router.db.get('posts').push(newPost).write();
  res.status(201).jsonp(newPost); // Return the newly created post
});

server.use('/api/v1', router);

server.listen(3000, () => {
  console.log('JSON Server is running on http://localhost:3000');
});
