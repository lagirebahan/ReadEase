const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/', (req, res) => {
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

router.get('/:id', (req, res) => {
    const sql = `SELECT * FROM notes WHERE note_id = ?`;

    db.query(sql, [req.params.id], (err, results) => {
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
    const {title, extracted_text, note_group, is_pinned} = req.body;

    const sql = `UPDATE notes SET title = ?, extracted_text = ?, note_group = ?, is_pinned = ? WHERE note_id = ?`;

    db.query(sql,[title, extracted_text, note_group, is_pinned ?? 0, req.params.id],(err) => {
        if (err) {
            return res.status(500).json({error: err.message});
        }
        res.json({success: true});
    });
});

router.delete('/:id', (req, res) => {
    const sql = `DELETE FROM notes WHERE note_id = ?`;

    db.query(
        sql,
        [req.params.id],
        (err) => {
            if (err) {return res.status(500).json({error: err.message});}
            res.json({success: true});
        }
    );
});

module.exports = router;