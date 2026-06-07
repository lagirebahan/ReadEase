const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');


const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const lowercaseRegex = /[a-z]/;
const uppercaseRegex = /[A-Z]/;
const numberRegex = /[0-9]/;
const specialCharRegex = /[!@#$%^&*(),.?":{}|<>_+\-=\[\]{};'\\\/|`~]/;

router.post('/register', (req, res) => {
  const { username, email, password } = req.body;

  if (!username || !email || !password) return res.status(400).json({ error: 'All fields are required.' });

  const trimmedUsername = username.trim();
  const trimmedEmail = email.trim();
  const trimmedPassword = password;

  if (trimmedUsername === '' || trimmedEmail === '' || trimmedPassword === '') {
    return res.status(400).json({ error: 'All fields are required and cannot be empty.' });
  }

  if (!emailRegex.test(trimmedEmail)) {
    return res.status(400).json({ error: 'Invalid email address format.' });
  }

  if (!lowercaseRegex.test(trimmedPassword)) {
    return res.status(400).json({ error: 'Password must contain at least one lowercase letter.' });
  }
  if (!uppercaseRegex.test(trimmedPassword)) {
    return res.status(400).json({ error: 'Password must contain at least one uppercase letter.' });
  }
  if (!numberRegex.test(trimmedPassword)) {
    return res.status(400).json({ error: 'Password must contain at least one number.' });
  }
  if (!specialCharRegex.test(trimmedPassword)) {
    return res.status(400).json({ error: 'Password must contain at least one special character.' });
  }
  if (trimmedPassword.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters long.' });
  }

  db.query(
    'SELECT * FROM users WHERE username = ? OR email = ?',
    [trimmedUsername, trimmedEmail],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Database query error.' });

      if (results.length > 0) {
        const existsUsername = results.some(u => u.username.toLowerCase() === trimmedUsername.toLowerCase());
        const existsEmail = results.some(u => u.email.toLowerCase() === trimmedEmail.toLowerCase());
        if (existsUsername && existsEmail) {
          return res.status(400).json({ error: 'Username and Email are already registered.' });
        } else if (existsUsername) {
          return res.status(400).json({ error: 'Username is already taken.' });
        } else {
          return res.status(400).json({ error: 'Email is already registered.' });
        }
      }

      bcrypt.hash(trimmedPassword, 10, (hashErr, hashedPassword) => {
        if (hashErr) {
          return res.status(500).json({ error: 'Error processing password.' });
        }

        db.query(
          'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
          [trimmedUsername, trimmedEmail, hashedPassword],
          (insertErr, insertResults) => {
            if (insertErr) return res.status(500).json({ error: 'Failed to register user.' });

            res.status(201).json({
              success: true,
              message: 'User registered successfully!',
              user: {
                user_id: insertResults.insertId,
                username: trimmedUsername,
                email: trimmedEmail
              }
            });
          }
        );
      });
    }
  );
});

router.post('/login', (req, res) => {
  const { usernameOrEmail, password } = req.body;

  if (!usernameOrEmail || !password) return res.status(400).json({ error: 'Username/Email and Password are required.' });

  const trimmedIdentifier = usernameOrEmail.trim();
  const trimmedPassword = password;

  if (trimmedIdentifier === '' || trimmedPassword === '') {
    return res.status(400).json({ error: 'Fields cannot be empty.' });
  }

  db.query(
    'SELECT * FROM users WHERE username = ? OR email = ?',
    [trimmedIdentifier, trimmedIdentifier],
    (err, results) => {
      if (err) return res.status(500).json({ error: 'Database query error.' });

      if (results.length === 0) return res.status(401).json({ error: 'Invalid credentials.' });

      const user = results[0];

      bcrypt.compare(trimmedPassword, user.password, (compErr, isMatch) => {
        if (compErr) {
          return res.status(500).json({ error: 'Error verifying credentials.' });
        }

        if (!isMatch) {
          return res.status(401).json({ error: 'Invalid credentials.' });
        }

        res.status(200).json({
          success: true,
          message: 'Login successful!',
          user: {
            user_id: user.user_id,
            username: user.username,
            email: user.email
          }
        });
      });
    }
  );
});

module.exports = router;
