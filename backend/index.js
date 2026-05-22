const express = require('express');
const Tesseract = require('tesseract.js');
const multer = require('multer');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');

const app = express();
const port = 3001;

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static(path.join(__dirname,'uploads'))); 

const db = mysql.createConnection({
    host:'localhost',
    user:'root',
    password:'',
    database:'readease',
});
db.connect((err)=>{
    if(err) throw err;
    console.log('Database connected!');
});

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now()+path.extname(file.originalname)),
});
const upload = multer({storage: storage});


//Home Page
// Purpose:
// gallery of notes
// filter/search
// tag/group management

// Features:
// note cards
// search bar
// filter by tags
// floating upload button

// GET /notes
// GET /notes?tag=School
app.get('/api/notes', (req, res) => {

})

app.post('/upload', upload.single('image'), async (req, res) => {
    try {
        const title = req.body.title;
        const noteGroup = req.body.note_group || 'Uncategorized';

        if(!req.file){
            return res.status(400).json({
                message: 'no image uploaded'
            });
        }
        const imagePath = `/uploads/${req.file.filename}`;

        const result = await Tesseract.recognize(
            req.file.path,
            'eng'
        );

        const extractedText = result.data.text;

        const sql = `INSERT INTO notes(title, image_path, extracted_text, note_group) VALUES (?,?,?,?)`;
        db.query(sql,[title,imagePath,extractedText,noteGroup], (err, results) => {
            if(err) return res.status(500).json({message:err.message});
            res.json({success:true, note: {
                note: {
                        id: results.insertId,
                        title,
                        image_path: imagePath,
                        extracted_text: extractedText,
                        note_group: noteGroup,
                    }
            }});
        }
        );
        
    } catch (error) {
        res.status(500).json({
            error: error.message
        });
    }
});

app.get('/api/notes', (req, res) => {

    const sql = `
        SELECT *
        FROM notes
        ORDER BY updated_at DESC
    `;

    db.query(sql, (err, results) => {

        if (err) {
            return res.status(500).json({
                error: err.message
            });
        }

        res.json(results);
    });
});

app.get('/api/notes/:id', (req, res) => {

    const sql = `
        SELECT *
        FROM notes
        WHERE id = ?
    `;

    db.query(
        sql,
        [req.params.id],
        (err, results) => {

            if (err) {
                return res.status(500).json({
                    error: err.message
                });
            }

            if (results.length === 0) {
                return res.status(404).json({
                    error: 'Note not found'
                });
            }

            res.json(results[0]);
        }
    );
});

app.put('/api/notes/:id', (req, res) => {

    const {
        title,
        extracted_text,
        note_group
    } = req.body;

    const sql = `
        UPDATE notes
        SET
            title = ?,
            extracted_text = ?,
            note_group = ?
        WHERE id = ?
    `;

    db.query(
        sql,
        [
            title,
            extracted_text,
            note_group,
            req.params.id
        ],
        (err) => {

            if (err) {
                return res.status(500).json({
                    error: err.message
                });
            }

            res.json({
                success: true
            });
        }
    );
});

app.delete('/api/notes/:id', (req, res) => {

    const sql = `
        DELETE FROM notes
        WHERE id = ?
    `;

    db.query(
        sql,
        [req.params.id],
        (err) => {

            if (err) {
                return res.status(500).json({
                    error: err.message
                });
            }

            res.json({
                success: true
            });
        }
    );
});

// Upload Page
// Pick image
// → Send to backend
// → Backend OCR extracts text
// → Save note
// → Return extracted text
// → Navigate to Reader Page
// POST /upload


app.listen(port, () => console.log(`Server running on port ${port}`));