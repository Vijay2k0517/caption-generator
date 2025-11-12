import sqlite3
import hashlib
import secrets
from datetime import datetime, timedelta
from typing import Optional, List, Dict, Any
import logging

logger = logging.getLogger(__name__)

class Database:
    def __init__(self, db_path: str = "caption_maker.db"):
        self.db_path = db_path
        self.init_database()
    
    def get_connection(self):
        """Get database connection."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn
    
    def init_database(self):
        """Initialize database tables."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        # Users table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE NOT NULL,
                email TEXT UNIQUE NOT NULL,
                password_hash TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        # Sessions table for authentication tokens
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                token TEXT UNIQUE NOT NULL,
                expires_at TIMESTAMP NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        """)
        
        # Conversations table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS conversations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                title TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        """)
        
        # Messages table for conversation history
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS messages (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                conversation_id INTEGER NOT NULL,
                role TEXT NOT NULL,
                content TEXT NOT NULL,
                captions TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE
            )
        """)
        
        # Saved captions table
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS saved_captions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER NOT NULL,
                caption TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
            )
        """)
        
        conn.commit()
        conn.close()
        logger.info("Database initialized successfully")
    
    def hash_password(self, password: str) -> str:
        """Hash password with SHA-256."""
        return hashlib.sha256(password.encode()).hexdigest()
    
    def create_user(self, username: str, email: str, password: str) -> Optional[int]:
        """Create a new user."""
        try:
            conn = self.get_connection()
            cursor = conn.cursor()
            
            password_hash = self.hash_password(password)
            cursor.execute(
                "INSERT INTO users (username, email, password_hash) VALUES (?, ?, ?)",
                (username, email, password_hash)
            )
            user_id = cursor.lastrowid
            
            conn.commit()
            conn.close()
            
            logger.info(f"User created: {username}")
            return user_id
        except sqlite3.IntegrityError as e:
            logger.error(f"User creation failed: {e}")
            return None
    
    def verify_user(self, username: str, password: str) -> Optional[Dict[str, Any]]:
        """Verify user credentials."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        password_hash = self.hash_password(password)
        cursor.execute(
            "SELECT id, username, email FROM users WHERE username = ? AND password_hash = ?",
            (username, password_hash)
        )
        
        user = cursor.fetchone()
        conn.close()
        
        if user:
            return dict(user)
        return None
    
    def create_session(self, user_id: int) -> str:
        """Create a session token for user."""
        token = secrets.token_urlsafe(32)
        expires_at = datetime.now() + timedelta(days=30)
        
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO sessions (user_id, token, expires_at) VALUES (?, ?, ?)",
            (user_id, token, expires_at)
        )
        
        conn.commit()
        conn.close()
        
        return token
    
    def verify_session(self, token: str) -> Optional[int]:
        """Verify session token and return user_id."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            """SELECT user_id FROM sessions 
               WHERE token = ? AND expires_at > ?""",
            (token, datetime.now())
        )
        
        result = cursor.fetchone()
        conn.close()
        
        if result:
            return result[0]
        return None
    
    def delete_session(self, token: str):
        """Delete a session (logout)."""
        conn = self.get_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM sessions WHERE token = ?", (token,))
        conn.commit()
        conn.close()
    
    def create_conversation(self, user_id: int, title: str = "New Conversation") -> int:
        """Create a new conversation."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO conversations (user_id, title) VALUES (?, ?)",
            (user_id, title)
        )
        conversation_id = cursor.lastrowid
        
        conn.commit()
        conn.close()
        
        return conversation_id
    
    def get_user_conversations(self, user_id: int) -> List[Dict[str, Any]]:
        """Get all conversations for a user."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            """SELECT id, title, created_at, updated_at 
               FROM conversations 
               WHERE user_id = ? 
               ORDER BY updated_at DESC""",
            (user_id,)
        )
        
        conversations = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return conversations
    
    def add_message(
        self, 
        conversation_id: int, 
        role: str, 
        content: str, 
        captions: Optional[List[str]] = None
    ) -> int:
        """Add a message to a conversation."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        # Convert captions list to JSON string
        import json
        captions_json = json.dumps(captions) if captions else None
        
        cursor.execute(
            """INSERT INTO messages (conversation_id, role, content, captions) 
               VALUES (?, ?, ?, ?)""",
            (conversation_id, role, content, captions_json)
        )
        message_id = cursor.lastrowid
        
        # Update conversation timestamp
        cursor.execute(
            "UPDATE conversations SET updated_at = CURRENT_TIMESTAMP WHERE id = ?",
            (conversation_id,)
        )
        
        conn.commit()
        conn.close()
        
        return message_id
    
    def get_conversation_messages(self, conversation_id: int) -> List[Dict[str, Any]]:
        """Get all messages in a conversation."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            """SELECT id, role, content, captions, created_at 
               FROM messages 
               WHERE conversation_id = ? 
               ORDER BY created_at ASC""",
            (conversation_id,)
        )
        
        messages = []
        for row in cursor.fetchall():
            msg = dict(row)
            # Parse captions JSON
            import json
            if msg['captions']:
                msg['captions'] = json.loads(msg['captions'])
            messages.append(msg)
        
        conn.close()
        return messages
    
    def save_caption(self, user_id: int, caption: str) -> int:
        """Save a caption for a user."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "INSERT INTO saved_captions (user_id, caption) VALUES (?, ?)",
            (user_id, caption)
        )
        caption_id = cursor.lastrowid
        
        conn.commit()
        conn.close()
        
        return caption_id
    
    def get_saved_captions(self, user_id: int) -> List[Dict[str, Any]]:
        """Get all saved captions for a user."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            """SELECT id, caption, created_at 
               FROM saved_captions 
               WHERE user_id = ? 
               ORDER BY created_at DESC""",
            (user_id,)
        )
        
        captions = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return captions
    
    def delete_caption(self, caption_id: int, user_id: int) -> bool:
        """Delete a saved caption."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "DELETE FROM saved_captions WHERE id = ? AND user_id = ?",
            (caption_id, user_id)
        )
        
        deleted = cursor.rowcount > 0
        conn.commit()
        conn.close()
        
        return deleted
    
    def get_user_info(self, user_id: int) -> Optional[Dict[str, Any]]:
        """Get user information."""
        conn = self.get_connection()
        cursor = conn.cursor()
        
        cursor.execute(
            "SELECT id, username, email, created_at FROM users WHERE id = ?",
            (user_id,)
        )
        
        user = cursor.fetchone()
        conn.close()
        
        if user:
            return dict(user)
        return None
