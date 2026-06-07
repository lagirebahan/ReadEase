const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
    const userId = req.headers['x-user-id'];
    if (!userId) return res.status(401).json({ error: 'Unauthorized' });

    db.query(
        `SELECT DISTINCT f.name AS note_group 
         FROM notes n
         INNER JOIN folders f ON n.folder_id = f.folder_id
         WHERE n.user_id = ?
         ORDER BY note_group ASC`,
        [userId],
        (err, results) => {
            if (err) return res.status(500).json({ error: err.message });
            res.json(results.map(r => r.note_group));
        }
    );
});

module.exports = router;