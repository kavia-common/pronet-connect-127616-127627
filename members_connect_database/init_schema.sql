-- MySQL database schema for the Members Connect platform
-- Entities: users, profiles, connections, referrals, meetings, notifications

-- Drop tables if they exist (for repeatability in dev/test environments)
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS meetings;
DROP TABLE IF EXISTS referrals;
DROP TABLE IF EXISTS connections;
DROP TABLE IF EXISTS profiles;
DROP TABLE IF EXISTS users;

-- USERS: base authentication entity
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('member', 'admin') NOT NULL DEFAULT 'member',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_users_email (email),
    INDEX idx_users_email (email)
);

-- Sample user
INSERT INTO users (email, password_hash, role) VALUES
('alice@example.com', 'hashedpassword123', 'member');

-- PROFILES: extended info for users
CREATE TABLE profiles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    company VARCHAR(150),
    title VARCHAR(150),
    phone VARCHAR(30),
    address VARCHAR(255),
    bio TEXT,
    website VARCHAR(255),
    linkedin VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_profiles_user (user_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Sample profile
INSERT INTO profiles (user_id, first_name, last_name, company, title)
VALUES (1, 'Alice', 'Nguyen', 'Acme Corp', 'Business Consultant');

-- CONNECTIONS: member-to-member connection requests/links
CREATE TABLE connections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    requester_id INT NOT NULL,
    addressee_id INT NOT NULL,
    status ENUM('pending', 'accepted', 'declined', 'blocked') NOT NULL DEFAULT 'pending',
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    responded_at TIMESTAMP NULL,
    UNIQUE KEY uq_connection_pair (requester_id, addressee_id),
    FOREIGN KEY (requester_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (addressee_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_connection_status (status)
);

-- Sample connection (pending)
INSERT INTO connections (requester_id, addressee_id, status)
VALUES (1, 1, 'accepted');

-- REFERRALS: tracks business leads passed between users
CREATE TABLE referrals (
    id INT AUTO_INCREMENT PRIMARY KEY,
    from_user_id INT NOT NULL,
    to_user_id INT NOT NULL,
    contact_name VARCHAR(150),
    contact_email VARCHAR(255),
    description TEXT,
    status ENUM('sent', 'accepted', 'rejected', 'completed') NOT NULL DEFAULT 'sent',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (from_user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (to_user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_referrals_status (status),
    INDEX idx_referrals_from_to (from_user_id, to_user_id)
);

-- Sample referral
INSERT INTO referrals (from_user_id, to_user_id, contact_name, contact_email, description, status)
VALUES (1, 1, 'Bob Example', 'bob@example.com', 'Potential client for coaching services', 'sent');

-- MEETINGS: tracks member meetings (one-on-one or group)
CREATE TABLE meetings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    organizer_id INT NOT NULL,
    topic VARCHAR(255) NOT NULL,
    description TEXT,
    scheduled_at DATETIME NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (organizer_id) REFERENCES users(id) ON DELETE SET NULL ON UPDATE CASCADE,
    INDEX idx_meetings_organizer (organizer_id),
    INDEX idx_meetings_scheduled (scheduled_at)
);

-- Sample meeting
INSERT INTO meetings (organizer_id, topic, description, scheduled_at, location)
VALUES (1, 'Weekly Chapter Meeting', 'Regular BNI-style networking session', '2024-07-12 09:00:00', 'Conference Room 2');

-- NOTIFICATIONS: in-app or email alerts to users
CREATE TABLE notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message VARCHAR(500) NOT NULL,
    type ENUM('info', 'alert', 'reminder') NOT NULL DEFAULT 'info',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_notifications_user (user_id),
    INDEX idx_notifications_read (is_read)
);

-- Sample notification
INSERT INTO notifications (user_id, message, type)
VALUES (1, 'You have a new connection request!', 'info');
