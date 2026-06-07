const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'readease',
});

db.connect((err) => {
    if (err) throw err;
    console.log('Database connected!');

    db.query(`
        CREATE TABLE IF NOT EXISTS users (
            user_id  INT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(100) NOT NULL UNIQUE,
            email    VARCHAR(255) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `, (err1) => {
        if (err1) {
            console.error('Error creating users table:', err1.message);
            return;
        }
        console.log('Users table verified/created successfully.');

        db.query(`
            CREATE TABLE IF NOT EXISTS folders (
                folder_id  INT AUTO_INCREMENT PRIMARY KEY,
                user_id    INT NOT NULL,
                name       VARCHAR(100) NOT NULL,
                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                UNIQUE KEY user_folder_unique (user_id, name),
                FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
            )
        `, (err2) => {
            if (err2) {
                console.error('Error creating folders table:', err2.message);
                return;
            }
            console.log('Folders table verified/created successfully.');

            db.query(`
                CREATE TABLE IF NOT EXISTS notes (
                    note_id        INT AUTO_INCREMENT PRIMARY KEY,
                    user_id        INT NOT NULL,
                    title          VARCHAR(255) NOT NULL DEFAULT 'Untitled',
                    image_path     VARCHAR(255) NOT NULL DEFAULT '',
                    extracted_text TEXT,
                    folder_id      INT DEFAULT NULL,
                    is_pinned      TINYINT DEFAULT 0,
                    created_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
                    updated_at     DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
                    FOREIGN KEY (folder_id) REFERENCES folders(folder_id) ON DELETE SET NULL
                )
            `, (err3) => {
                if (err3) {
                    console.error('Error creating notes table:', err3.message);
                    return;
                }
                console.log('Notes table verified/created successfully.');
            });
        });
    });
});

module.exports = db;
