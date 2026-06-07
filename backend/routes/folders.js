const express = require('express');
const router = express.Router();
const db = require('../db');

// GET /api/folders — all folders for user
router.get('/', (req, res) => {
  const userId = req.headers['x-user-id'];
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });

  const sql = `SELECT name FROM folders WHERE user_id = ? ORDER BY name ASC`;
  db.query(sql, [userId], (err, results) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json(results.map(r => r.name));
  });
});

// POST /api/folders — create a new empty folder
router.post('/', (req, res) => {
  const userId = req.headers['x-user-id'];
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });

  const { name } = req.body;
  if (!name || !name.trim()) return res.status(400).json({ error: 'Folder name is required' });

  db.query(
    `INSERT IGNORE INTO folders (user_id, name) VALUES (?, ?)`,
    [userId, name.trim()],
    (err) => {
      if (err) return res.status(500).json({ error: err.message });
      res.json({ success: true, name: name.trim() });
    }
  );
});

// DELETE /api/folders/:name — delete folder (moves its notes to Uncategorized via FK ON DELETE SET NULL)
router.delete('/:name', (req, res) => {
  const userId = req.headers['x-user-id'];
  if (!userId) return res.status(401).json({ error: 'Unauthorized' });

  const name = decodeURIComponent(req.params.name);
  db.query(`DELETE FROM folders WHERE user_id = ? AND name = ?`, [userId, name], (err) => {
    if (err) return res.status(500).json({ error: err.message });
    res.json({ success: true });
  });
});

module.exports = router;
