const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
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

module.exports = router;