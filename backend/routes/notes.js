const express = require('express');
const router = express.Router();
const db = require('../db');

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

router.get('/', (req, res) => {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const tag = req.query.tag;

    let sql = `
        SELECT n.*, f.name AS note_group 
        FROM notes n
        LEFT JOIN folders f ON n.folder_id = f.folder_id
        WHERE n.user_id = ?
        ORDER BY n.updated_at DESC
    `;
    const params = [userId];

    if (tag) {
        if (tag === 'Uncategorized') {
            sql = `
                SELECT n.*, f.name AS note_group 
                FROM notes n
                LEFT JOIN folders f ON n.folder_id = f.folder_id
                WHERE n.user_id = ? AND n.folder_id IS NULL
                ORDER BY n.is_pinned DESC, n.updated_at DESC
            `;
        } else {
            sql = `
                SELECT n.*, f.name AS note_group 
                FROM notes n
                LEFT JOIN folders f ON n.folder_id = f.folder_id
                WHERE n.user_id = ? AND f.name = ?
                ORDER BY n.is_pinned DESC, n.updated_at DESC
            `;
            params.push(tag);
        }
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

// Create a brand-new blank note (no image, no OCR)
router.post('/', (req, res) => {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const { title, note_group, is_pinned } = req.body;
    resolveFolderId(userId, note_group, (err, folderId) => {
        if (err) return res.status(500).json({ error: err.message });

        const sql = `INSERT INTO notes (user_id, title, image_path, extracted_text, folder_id, is_pinned) VALUES (?, ?, '', '', ?, ?)`;
        db.query(sql, [userId, title || 'Untitled', folderId, is_pinned ? 1 : 0], (err2, results) => {
            if (err2) return res.status(500).json({ error: err2.message });
            res.json({
                success: true,
                note: {
                    note_id: results.insertId,
                    user_id: userId,
                    title: title || 'Untitled',
                    image_path: '',
                    extracted_text: '',
                    note_group: note_group || 'Uncategorized',
                    is_pinned: is_pinned ? 1 : 0,
                }
            });
        });
    });
});

router.get('/:id', (req, res) => {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const sql = `
        SELECT n.*, f.name AS note_group 
        FROM notes n
        LEFT JOIN folders f ON n.folder_id = f.folder_id
        WHERE n.user_id = ? AND n.note_id = ?
    `;

    db.query(sql, [userId, req.params.id], (err, results) => {
        if (err) {
            return res.status(500).json({error: err.message});
        }

        if (results.length === 0) {
            return res.status(404).json({error: 'Note not found'});
        }
        res.json(results[0]);
    });
});

router.put('/:id', (req, res) => {
    const userId = req.headers['x-user-id'];
    console.log(`[notes.js] PUT /${req.params.id} called with user_id: ${userId}`);
    console.log('[notes.js] Body:', req.body);
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const {title, extracted_text, note_group, is_pinned} = req.body;

    resolveFolderId(userId, note_group, (err, folderId) => {
        if (err) {
            console.error('[notes.js] Error resolving folder:', err);
            return res.status(500).json({ error: err.message });
        }

        const sql = `UPDATE notes SET title = ?, extracted_text = ?, folder_id = ?, is_pinned = ? WHERE user_id = ? AND note_id = ?`;

        db.query(sql, [title, extracted_text, folderId, is_pinned ?? 0, userId, req.params.id], (err2, results) => {
            if (err2) {
                console.error('[notes.js] Error updating note:', err2);
                return res.status(500).json({error: err2.message});
            }
            console.log('[notes.js] Update results:', results);
            res.json({success: true});
        });
    });
});

router.delete('/:id', (req, res) => {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    const sql = `DELETE FROM notes WHERE user_id = ? AND note_id = ?`;

    db.query(
        sql,
        [userId, req.params.id],
        (err) => {
            if (err) {return res.status(500).json({error: err.message});}
            res.json({success: true});
        }
    );
});

module.exports = router;