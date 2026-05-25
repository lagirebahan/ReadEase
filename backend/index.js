const express = require('express');
const cors = require('cors');
const path = require('path');

const notesRouter = require('./routes/notes');
const groupsRouter = require('./routes/groups');
const uploadRouter = require('./routes/upload');

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname,'uploads'))); 

app.use('/api/notes', notesRouter);
app.use('/api/groups', groupsRouter);
app.use('/upload', uploadRouter);

app.listen(port, () => console.log(`Backend API sudah menyala di http://localhost:${port}`));