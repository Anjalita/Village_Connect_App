const express = require('express');
const mysql = require('mysql2');
const bodyParser = require('body-parser');
const cors = require('cors');
const bcrypt = require('bcrypt');

const app = express();
const port = 3000;
const saltRounds = 10;

app.use(cors());
app.use(bodyParser.json());

// MySQL connection
const db = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '', //password here
  database: 'village_app'
});

db.connect(err => {
  if (err) {
    console.error('Database connection error:', err);
  } else {
    console.log('Connected to the database');
  }
});

// Login endpoint
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  const query = 'SELECT * FROM users WHERE username = ?';

  db.query(query, [username], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else if (results.length > 0) {
      const user = results[0];
      bcrypt.compare(password, user.password, (err, match) => {
        if (err) {
          console.error('Error comparing passwords:', err);
          res.status(500).json({ error: 'Internal server error' });
        } else if (match) {
          if (user.activation === 0) {
            console.log('Account not activated');
            res.status(200).json({ success: false, message: 'Account not activated' });
          } else {
            console.log('Login successful');
            res.status(200).json({ success: true, userType: user.user_type });
          }
        } else {
          console.log('Invalid credentials - password mismatch');
          res.status(401).json({ success: false, message: 'Invalid credentials' });
        }
      });
    } else {
      console.log('Invalid credentials - user not found');
      res.status(401).json({ success: false, message: 'Invalid credentials' });
    }
  });
});

// Signup endpoint
app.post('/signup', (req, res) => {
  const { username, name, phone, address, jobTitle, email, password } = req.body;
  const activation = 0; // Default activation status
  const userType = 'user'; // Default user type

  // Check if the username already exists
  const checkQuery = 'SELECT * FROM users WHERE username = ?';
  db.query(checkQuery, [username], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else if (results.length > 0) {
      // Username already exists
      res.status(400).json({ error: 'Username already exists' });
    } else {
      // Proceed with registration
      bcrypt.hash(password, saltRounds, (err, hashedPassword) => {
        if (err) {
          console.error('Error hashing password:', err);
          res.status(500).json({ error: 'Internal server error' });
        } else {
          const query = `
            INSERT INTO users (username, name, phone, address, job_title, email, password, activation, user_type)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          `;

          db.query(query, [username, name, phone, address, jobTitle, email, hashedPassword, activation, userType], (err, result) => {
            if (err) {
              console.error('Database query error:', err);
              res.status(500).json({ error: 'Database error' });
            } else {
              res.status(200).json({ message: 'User registered successfully. Awaiting activation.' });
            }
          });
        }
      });
    }
  });
});


// Create announcement endpoint
app.post('/createAnnouncement', (req, res) => {
  const { title, content } = req.body;

  const query = 'INSERT INTO announcements (title, content) VALUES (?, ?)';

  db.query(query, [title, content], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Announcement created successfully' });
    }
  });
});

// Retrieve announcements endpoint
app.get('/announcements', (req, res) => {
  const query = 'SELECT id, title, content, created_at FROM announcements ORDER BY created_at DESC';
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});


// Delete announcement endpoint
app.delete('/deleteAnnouncement/:id', (req, res) => {
  const { id } = req.params;

  const query = 'DELETE FROM announcements WHERE id = ?';

  db.query(query, [id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Announcement deleted successfully' });
    }
  });
});

// Update announcement endpoint
app.put('/updateAnnouncement/:id', (req, res) => {
  const { id } = req.params;
  const { title, content } = req.body;

  const query = 'UPDATE announcements SET title = ?, content = ? WHERE id = ?';

  db.query(query, [title, content, id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Announcement updated successfully' });
    }
  });
});
// Activate user endpoint
app.post('/activate-user', (req, res) => {
  const { user_id } = req.body;

  const query = 'UPDATE users SET activation = 1 WHERE id = ?';
  
  db.query(query, [user_id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'User activated successfully' });
    }
  });
});

// Deactivate user endpoint
app.post('/deactivate-user', (req, res) => {
  const { user_id } = req.body;

  const query = 'DELETE FROM users WHERE id = ?';
  
  db.query(query, [user_id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'User deactivated successfully' });
    }
  });
});

// Endpoint to get pending users
app.get('/pending-users', (req, res) => {
  const query = 'SELECT id, username, name, phone, email, address, job_title FROM users WHERE activation = 0';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Respond to suggestion endpoint
app.post('/respondSuggestion', (req, res) => {
  const { id, response } = req.body;

  const query = 'UPDATE suggestions SET response = ? WHERE id = ?';

  db.query(query, [response, id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Suggestion responded successfully' });
    }
  });
});

// Get all queries
app.get('/admin/queries', (req, res) => {
  const query = `SELECT * FROM queries ORDER BY time DESC`;
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Respond to a query
app.put('/admin/respondQuery/:id', (req, res) => {
  const { id } = req.params;
  const { response } = req.body;

  const query = 'UPDATE queries SET admin_response = ? WHERE id = ?';

  db.query(query, [response, id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Query responded successfully' });
    }
  });
});

// Get all admin users
app.get('/admin/users', (req, res) => {
  const query = 'SELECT id, username, name, phone, address, job_title, email FROM users WHERE user_type = "admin" AND id != 19';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Remove an admin user
app.post('/remove-admin', (req, res) => {
  const { user_id } = req.body;

  const query = 'DELETE FROM users WHERE id = ? AND user_type = "admin"';

  db.query(query, [user_id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Admin removed successfully' });
    }
  });
});

// Add a new admin user
app.post('/add-admin', (req, res) => {
  const { username, password, name, phone, address, job_title, email } = req.body;
  const activation = 1; // Activation status for new admins
  const userType = 'admin'; // User type for new admins

  // Check if the username already exists
  const checkQuery = 'SELECT * FROM users WHERE username = ?';
  db.query(checkQuery, [username], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else if (results.length > 0) {
      // Username already exists
      res.status(400).json({ error: 'Username already exists' });
    } else {
      // Proceed with registration
      bcrypt.hash(password, saltRounds, (err, hashedPassword) => {
        if (err) {
          console.error('Error hashing password:', err);
          res.status(500).json({ error: 'Internal server error' });
        } else {
          const query = `
            INSERT INTO users (username, password, name, phone, address, job_title, email, activation, user_type)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          `;

          db.query(query, [username, hashedPassword, name, phone, address, job_title, email, activation, userType], (err, result) => {
            if (err) {
              console.error('Database query error:', err);
              res.status(500).json({ error: 'Database error' });
            } else {
              res.status(200).json({ message: 'Admin added successfully' });
            }
          });
        }
      });
    }
  });
});

// Get all users
app.get('/users', (req, res) => {
  const query = 'SELECT id, username, name, phone, address, job_title, email FROM users WHERE user_type = "user" AND activation = 1';

  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Remove an user
app.post('/remove-user', (req, res) => {
  const { user_id } = req.body;

  const query = 'DELETE FROM users WHERE id = ? AND user_type = "user"';

  db.query(query, [user_id], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Admin removed successfully' });
    }
  });
});

// User screen 

// Create suggestion endpoint
app.post('/createSuggestion', (req, res) => {
  const { title, content, username } = req.body;

  const query = 'INSERT INTO suggestions (title, content, username, created_at) VALUES (?, ?, ?, NOW())';

  db.query(query, [title, content, username], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else {
      res.status(200).json({ message: 'Suggestion submitted successfully' });
    }
  });
});

// Retrieve all suggestions endpoint
app.get('/suggestions', (req, res) => {
  const query = 'SELECT id, title, content, username, created_at, response FROM suggestions ORDER BY created_at DESC';
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Fetch locations endpoint
app.get('/locations', (req, res) => {
  const query = 'SELECT id, place_name FROM places';
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Endpoint to get crops and their prices for a specific location
app.get('/crops', (req, res) => {
  const placeId = req.query.place_id;

  if (!placeId) {
    return res.status(400).json({ error: 'place_id is required' });
  }

  // Query to fetch crops with their prices and average prices
  const query = `
    SELECT c.crop_name, p.price, p.month_year, c.avg_price
    FROM price p
    JOIN crop c ON p.crop_id = c.id
    WHERE p.place_id = ?
  `;

  db.query(query, [placeId], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Database error' });
    } else if (results.length === 0) {
      // No crops available for the selected location
      res.status(404).json({ message: 'Database not updated' });
    } else {
      // Send the list of crops and their prices
      res.status(200).json(results);
    }
  });
});

// Create a new query
app.post('/createQuery', (req, res) => {
  const { username, matter, time } = req.body;
  const query = `INSERT INTO queries (username, matter, time) VALUES (?, ?, ?)`;
  db.query(query, [username, matter, time], (err, result) => {
    if (err) {
      res.status(500).send('Failed to create query');
      return;
    }
    res.sendStatus(200);
  });
});

// Get all queries for a user
app.get('/queries', (req, res) => {
  const { username } = req.query;
  const query = `SELECT * FROM queries WHERE username = ? ORDER BY time DESC`;
  db.query(query, [username], (err, results) => {
    if (err) {
      res.status(500).send('Failed to fetch queries');
      return;
    }
    res.json(results);
  });
});

// Fetch user profile
app.get('/user/profile', (req, res) => {
  const username = req.query.username; // Assume username is passed as a query parameter

  const query = 'SELECT * FROM users WHERE username = ?';

  db.query(query, [username], (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else if (results.length === 0) {
      res.status(404).json({ error: 'User not found' });
    } else {
      const user = results[0];
      res.status(200).json(user);
    }
  });
});

// Update user profile
app.put('/user/profile/update', (req, res) => {
  const { username, name, phone, address, job_title, email } = req.body;

  if (!username) {
    return res.status(400).json({ error: 'Username is required' });
  }

  const query = 'UPDATE users SET name = ?, phone = ?, address = ?, job_title = ?, email = ? WHERE username = ?';
  
  db.query(query, [name, phone, address, job_title, email, username], (err, result) => {
    if (err) {
      console.error('Database query error:', err);
      return res.status(500).json({ error: 'Database error' });
    }
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.status(200).json({ message: 'User profile updated successfully' });
  });
});

// Fetch all places
app.get('/places', (req, res) => {
  db.query('SELECT * FROM places ORDER BY place_name ASC', (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to fetch places' });
    }
    res.json(results);
  });
});

// Fetch crops by place ID
app.get('/crops/:placeId', (req, res) => {
  const placeId = parseInt(req.params.placeId, 10);

  db.query(`
    SELECT c.crop_name, p.price, p.month_year, p.id, c.avg_price
    FROM price p
    JOIN crop c ON p.crop_id = c.id
    WHERE p.place_id = ?
  `, [placeId], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to fetch crops' });
    }
    res.json(results);
  });
});

// Fetch all crops with their average prices
app.get('/all-crops', (req, res) => {
  const query = 'SELECT id,crop_name, avg_price FROM crop';
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('Database query error:', err);
      res.status(500).json({ error: 'Internal server error' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Update crop price
app.post('/update-price', (req, res) => {
  const { crop_id, price, month_year } = req.body;

  db.query(`
    UPDATE price
    SET price = ?, month_year = ?
    WHERE id = ?
  `, [price, month_year, crop_id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to update crop price' });
    }
    res.json({ message: 'Price updated successfully' });
  });
});

// Add new price
app.post('/add-price', (req, res) => {
  const { place_id, crop_id, price, month_year } = req.body;

  // Check if the combination of crop_id and place_id exists in the database
  db.query(`
    SELECT * FROM price
    WHERE place_id = ? AND crop_id = ?
  `, [place_id, crop_id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to check existing price' });
    }
    
    if (results.length > 0) {
      return res.status(400).json({ error: 'Crop is already available in the location ' });
    }

    // If the combination doesn't exist, proceed to insert the new price
    db.query(`
      INSERT INTO price (place_id, crop_id, price, month_year)
      VALUES (?, ?, ?, ?)
    `, [place_id, crop_id, price, month_year], (err, results) => {
      if (err) {
        return res.status(500).json({ error: 'Failed to add new price' });
      }
      res.json({ message: 'Price added successfully' });
    });
  });
});


// Update crop average price
app.post('/update-crop', (req, res) => {
  const { crop_id, avg_price } = req.body;

  db.query(`
    UPDATE crop
    SET avg_price = ?
    WHERE id = ?
  `, [avg_price, crop_id], (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to update crop average price' });
    }
    res.json({ message: 'Crop average price updated successfully' });
  });
});

// Add new crop
app.post('/add-crop', (req, res) => {
  const { crop_name, avg_price } = req.body;

  // Check if crop_name already exists
  db.query('SELECT * FROM crop WHERE crop_name = ?', crop_name, (err, results) => {
    if (err) {
      return res.status(500).json({ error: 'Failed to check crop existence' });
    }
    if (results.length > 0) {
      return res.status(400).json({ error: 'Crop already exists' });
    }

    // If crop_name does not exist, proceed to insert
    db.query(
      'INSERT INTO crop (crop_name, avg_price) VALUES (?, ?)',
      [crop_name, avg_price],
      (err, results) => {
        if (err) {
          return res.status(500).json({ error: 'Failed to add new crop' });
        }
        res.json({ message: 'Crop added successfully' });
      }
    );
  });
});

app.get('/admins', (req, res) => {
  const query = `
    SELECT name, phone, job_title
    FROM users
    WHERE user_type = 'admin'
  `;
  
  db.query(query, (err, results) => {
    if (err) {
      console.error('Error fetching admin contacts:', err);
      res.status(500).send('Server error');
      return;
    }
    res.json(results);
  });
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});