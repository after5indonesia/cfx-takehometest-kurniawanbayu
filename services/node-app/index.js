const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from the Node.js Backend Service!');
});

app.listen(PORT, () => {
  console.log(`Node server running on port ${PORT}`);
});