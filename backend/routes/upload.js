const express = require('express');
const router = express.Router();
const Tesseract = require('tesseract.js');
const multer = require('multer');
const sharp = require('sharp');
const path = require('path');
const fs = require('fs');
const db = require('../db');

const storage = multer.diskStorage({
    destination: (req, file, cb) => cb(null, 'uploads/'),
    filename: (req, file, cb) => cb(null, Date.now()+path.extname(file.originalname)),
});
const upload = multer({storage: storage});

router.post('/', upload.single('image'), async (req, res) => {
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
                    note_id: results.insertId,
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

module.exports = router;