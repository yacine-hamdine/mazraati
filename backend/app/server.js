const express = require('express');
const authRoute = require('./routes/auth');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});
app.use('/api/user', authRoute);
app.listen(3000, () => {
  console.log('Server is running on http://localhost:3000');
});