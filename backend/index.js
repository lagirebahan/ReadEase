const express = require('express');
const Tesseract = require('tesseract.js');
const multer = require('multer');
const mysql = require('mysql2');
const cors = require('cors');
const path = require('path');
const sharp = require('sharp');
const fs = require('fs')

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
// app.get('/api/notes', (req, res) => {

// })

// app.post('/upload', upload.single('image'), async (req, res) => {
//     try {
//         const title = req.body.title;
//         const noteGroup = req.body.note_group || 'Uncategorized';

//         if (!req.file) {
//             return res.status(400).json({ message: 'no image uploaded' });
//         }

//         const imagePath = `/uploads/${req.file.filename}`;

//         // Preprocess image with sharp
//         const processedPath = `uploads/processed_${req.file.filename}`;
//         const metadata = await sharp(req.file.path).metadata();
//         await sharp(req.file.path)
//             .resize({
//                 width: Math.max(metadata.width * 3, 1000),
//                 height: Math.max(metadata.height * 3, 1000),
//                 fit:'inside',
//                 withoutEnlargement:false,
//             })
//             .grayscale()
//             .normalize()
//             .sharpen()
//             .toFile(processedPath);

//         // Use processed image for OCR
//         const result = await Tesseract.recognize(processedPath, 'eng');
//         const extractedText = result.data.text;

//         // Clean up processed file after OCR
//         fs.unlinkSync(processedPath);

//         const sql = `INSERT INTO notes(title, image_path, extracted_text, note_group) VALUES (?,?,?,?)`;
//         db.query(sql, [title, imagePath, extractedText, noteGroup], (err, results) => {
//             if (err) return res.status(500).json({ message: err.message });
//             res.json({
//                 success: true,
//                 note: {
//                     id: results.insertId,
//                     title,
//                     image_path: imagePath,
//                     extracted_text: extractedText,
//                     note_group: noteGroup,
//                 }
//             });
//         });

//     } catch (error) {
//         res.status(500).json({ error: error.message });
//     }
// });

app.post('/upload', upload.single('image'), async (req, res) => {
    try {
        const title = req.body.title || 'temp';
        const noteGroup = req.body.note_group || 'Uncategorized';
        const isPinned = req.body.is_pinned === '1' ? 1:0;

        if (!req.file) {
            return res.status(400).json({ message: 'no image uploaded' });
        }

        const imagePath = `/uploads/${req.file.filename}`;
        const processedPath = `uploads/processed_${req.file.filename}`;

        const metadata = await sharp(req.file.path).metadata();
        const isTooSmall = metadata.width < 100 || metadata.height < 100;

        let pipeline = sharp(req.file.path)
            .resize({
                width: 1500,
                fit: 'contain',
                withoutEnlargement: false,
                background: { r: 255, g: 255, b: 255, alpha: 1 }
            })
            .grayscale()
            .normalize();

        if (!isTooSmall) {
            pipeline = pipeline.sharpen();
        }

        await pipeline.toFile(processedPath);

        const result = await Tesseract.recognize(processedPath, 'eng');
        const extractedText = result.data.text;

        fs.unlinkSync(processedPath);

        const sql = `INSERT INTO notes(title, image_path, extracted_text, note_group, is_pinned) VALUES (?,?,?,?,?)`;
        db.query(sql, [title, imagePath, extractedText, noteGroup, isPinned], (err, results) => {
            if (err) return res.status(500).json({ message: err.message });
            res.json({
                success: true,
                note: {
                    id: results.insertId,
                    title,
                    image_path: imagePath,
                    extracted_text: extractedText,
                    note_group: noteGroup,
                    is_pinned: isPinned
                }
            });
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/notes', (req, res) => {
    const tag = req.query.tag;

    let sql = `SELECT * FROM notes ORDER BY updated_at DESC`;
    const params = [];

    if(tag) {
        sql = `SELECT * FROM notes WHERE note_group = ? ORDER BY is_pinned DESC, updated_at DESC`;
        params.push(tag);
    }

    db.query(sql, params, (err, results) => {

        if (err) {
            return res.status(500).json({
                error: err.message
            });
        }

        res.json(results);
    });
});

app.get('/api/groups', (req, res) => {
    db.query(
        `SELECT DISTINCT note_group FROM notes
         WHERE note_group IS NOT NULL
           AND note_group != 'Uncategorized'
           AND note_group != '__temp__'
         ORDER BY note_group ASC`,
        (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results.map(r => r.note_group));
        }
    );
});

app.get('/api/notes/:id', (req, res) => {

    const sql = `
        SELECT *
        FROM notes
        WHERE note_id = ?
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
        note_group,
        is_pinned
    } = req.body;

    const sql = `
        UPDATE notes
        SET
            title = ?,
            extracted_text = ?,
            note_group = ?,
            is_pinned = ?
        WHERE note_id = ?
    `;

    db.query(
        sql,
        [
            title,
            extracted_text,
            note_group,
            is_pinned ?? 0,
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
        WHERE note_id = ?
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


app.listen(port, () =>console.log(`Backend API sudah menyala di http://localhost:${port}`));