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

// Helper to resolve note_group string to folder_id for a given user
function resolveFolderId(userId, noteGroup, callback) {
    if (!noteGroup || noteGroup === 'Uncategorized' || noteGroup === '__temp__' || !noteGroup.trim()) {
        return callback(null, null);
    }
    const trimmed = noteGroup.trim();
    db.query(
        'SELECT folder_id FROM folders WHERE user_id = ? AND name = ?',
        [userId, trimmed],
        (err, results) => {
            if (err) return callback(err);
            if (results.length > 0) {
                return callback(null, results[0].folder_id);
            }
            // Create the folder if it doesn't exist
            db.query(
                'INSERT INTO folders (user_id, name) VALUES (?, ?)',
                [userId, trimmed],
                (errInsert, insertRes) => {
                    if (errInsert) return callback(errInsert);
                    callback(null, insertRes.insertId);
                }
            );
        }
    );
}

router.post('/', upload.single('image'), async (req, res) => {
    try {
        const userId = req.headers['x-user-id'];
        if (!userId) {
            if (req.file) {
                fs.unlinkSync(req.file.path);
            }
            return res.status(401).json({ message: 'Unauthorized: missing user ID' });
        }

        const title = req.body.title || 'temp';
        const noteGroup = req.body.note_group || 'Uncategorized';
        const isPinned = req.body.is_pinned === '1' ? 1 : 0;

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

        resolveFolderId(userId, noteGroup, (err, folderId) => {
            if (err) return res.status(500).json({ message: err.message });

            const sql = `INSERT INTO notes(user_id, title, image_path, extracted_text, folder_id, is_pinned) VALUES (?,?,?,?,?,?)`;
            db.query(sql, [userId, title, imagePath, extractedText, folderId, isPinned], (err2, results) => {
                if (err2) return res.status(500).json({ message: err2.message });
                res.json({
                    success: true,
                    note: {
                        note_id: results.insertId,
                        user_id: userId,
                        title,
                        image_path: imagePath,
                        extracted_text: extractedText,
                        note_group: noteGroup,
                        is_pinned: isPinned
                    }
                });
            });
        });

    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;