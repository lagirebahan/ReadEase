const express = require('express');
const router = express.Router();
const db = require('../db');
const bcrypt = require('bcryptjs');

// Auth routes

const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

const lowercaseRegex = /[a-z]/;
const uppercaseRegex = /[A-Z]/;
const numberRegex = /[0-9]/;
const specialCharRegex = /[!@#$%^&*(),.?":{}|<>_+\-=\[\]{};'\\\/|`~]/;

// POST /api/auth/register
router.post('/register', (req, res) => {
  const { username, email, password } = req.body;

  // 1. Check if empty
  if (!username || !email || !password) {
    return res.status(400).json({ error: 'All fields are required.' });
  }

  const trimmedUsername = username.trim();
  const trimmedEmail = email.trim();
  const trimmedPassword = password; // do not trim passwords to preserve spaces

  if (trimmedUsername === '' || trimmedEmail === '' || trimmedPassword === '') {
    return res.status(400).json({ error: 'All fields are required and cannot be empty.' });
  }

  // 2. Validate email format
  if (!emailRegex.test(trimmedEmail)) {
    return res.status(400).json({ error: 'Invalid email address format.' });
  }

  // 3. Validate password strength
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

  // 4. Check if username or email already exists
  db.query(
    'SELECT * FROM users WHERE username = ? OR email = ?',
    [trimmedUsername, trimmedEmail],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Database query error.' });
      }

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

      // 5. Hash password and insert
      bcrypt.hash(trimmedPassword, 10, (hashErr, hashedPassword) => {
        if (hashErr) {
          return res.status(500).json({ error: 'Error processing password.' });
        }

        db.query(
          'INSERT INTO users (username, email, password) VALUES (?, ?, ?)',
          [trimmedUsername, trimmedEmail, hashedPassword],
          (insertErr, insertResults) => {
            if (insertErr) {
              return res.status(500).json({ error: 'Failed to register user.' });
            }

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

// POST /api/auth/login
router.post('/login', (req, res) => {
  const { usernameOrEmail, password } = req.body;

  // 1. Check if empty
  if (!usernameOrEmail || !password) {
    return res.status(400).json({ error: 'Username/Email and Password are required.' });
  }

  const trimmedIdentifier = usernameOrEmail.trim();
  const trimmedPassword = password;

  if (trimmedIdentifier === '' || trimmedPassword === '') {
    return res.status(400).json({ error: 'Fields cannot be empty.' });
  }

  // 2. Query user by username or email
  db.query(
    'SELECT * FROM users WHERE username = ? OR email = ?',
    [trimmedIdentifier, trimmedIdentifier],
    (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Database query error.' });
      }

      if (results.length === 0) {
        return res.status(401).json({ error: 'Invalid credentials.' });
      }

      const user = results[0];

      // 3. Compare hashed password
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
