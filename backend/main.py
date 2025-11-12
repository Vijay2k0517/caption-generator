from __future__ import annotations

import os
import re
import time
import logging
from typing import List, Optional
from PIL import Image
import io

from fastapi import FastAPI, File, HTTPException, UploadFile, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from database import Database

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Loading environment variables
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    logger.warning("python-dotenv not installed")

# Import Gemini
try:
    import google.generativeai as genai
    HAS_GEMINI = True
except ImportError:
    HAS_GEMINI = False
    logger.error("Google Generative AI not installed. Run: pip install google-generativeai")

APP_NAME = "smart-caption-generator-backend"

class GeminiFreeCaptionGenerator:
    def __init__(self):
        self.api_key = None
        self.model = None
        self.initialized = False
        self.last_request_time = 0
        self.request_delay = 2
        
    def initialize(self) -> bool:
        """Initialize Gemini with correct model names."""
        if not HAS_GEMINI:
            logger.error("Gemini library not available")
            return False
            
        try:
            self.api_key = os.environ.get("GEMINI_API_KEY", "").strip()
            if not self.api_key:
                logger.warning("GEMINI_API_KEY not found in environment variables")
                return False
            
            genai.configure(api_key=self.api_key)
            
            # Get available models first
            try:
                available_models = list(genai.list_models())
                model_names = [model.name for model in available_models]
                logger.info(f"Available models: {model_names}")
                
                # Filter for models that support generateContent
                supported_models = []
                for model in available_models:
                    if 'generateContent' in model.supported_generation_methods:
                        supported_models.append(model.name)
                        logger.info(f"Supported model: {model.name}")
                
            except Exception as e:
                logger.warning(f"Could not list models: {e}")
                supported_models = []
            
            # Try known working model names for the current API
            model_names_to_try = [
                "gemini-1.5-flash-001",  # Current stable flash model
                "gemini-1.5-pro-001",    # Current stable pro model
                "gemini-1.0-pro",        # Original pro model
                "gemini-pro",            # Legacy name
                "gemini-1.5-flash",      # Try without version
                "gemini-1.5-pro",        # Try without version
            ]
            
            # Add supported models from the API to our try list
            if supported_models:
                model_names_to_try = supported_models + model_names_to_try
            
            for model_name in model_names_to_try:
                try:
                    logger.info(f"Trying model: {model_name}")
                    self.model = genai.GenerativeModel(model_name)
                    # Test the model with a simple prompt
                    test_response = self.model.generate_content("Say 'OK'")
                    if test_response and test_response.text:
                        logger.info(f"✅ Gemini model initialized: {model_name}")
                        self.initialized = True
                        return True
                except Exception as e:
                    logger.warning(f"Model {model_name} failed: {str(e)[:100]}...")
                    continue
            
            logger.error("No working Gemini model found")
            return False
            
        except Exception as e:
            logger.error(f"Gemini initialization failed: {e}")
            return False
    
    def wait_for_rate_limit(self):
        """Wait to avoid rate limiting."""
        current_time = time.time()
        time_since_last = current_time - self.last_request_time
        if time_since_last < self.request_delay:
            time.sleep(self.request_delay - time_since_last)
        self.last_request_time = time.time()
    
    def generate_captions(self, image_bytes: bytes) -> Optional[List[str]]:
        """Generate captions using Gemini free tier."""
        if not self.initialized or not self.model:
            logger.error("Gemini not initialized")
            return None
        
        self.wait_for_rate_limit()
        
        try:
            # Prepare the image
            image = Image.open(io.BytesIO(image_bytes))
            
            # Convert to RGB if needed
            if image.mode != 'RGB':
                image = image.convert('RGB')
            
            # Optimized prompt for better results
            prompt = prompt = """Generate 3 short, engaging Instagram captions for this photo. 
                Each caption should follow a different style:
                1. The first caption should be aesthetic and visually pleasing ✨
                2. The second caption should be poetic or quote-like, inspired by the mood or meaning of the photo 📝
                3. The third caption should be modern, trendy, or relatable — something that connects with today's social media vibe 🔥
                
                Each caption must be:
                - Under 10 words
                - Creative and original
                - Include relevant emojis
                - Suitable for Instagram posts
                
                Return exactly 3 captions, one per line, without any numbers or bullets.
                
                Example:
                Golden hour whispers through the waves 🌅
                Even silence tells a story 🌻
                Chasing moments, not things 💫"""

            
            # Generate content
            response = self.model.generate_content([prompt, image])
            
            if response and response.text:
                logger.info(f"Gemini response received")
                return self.parse_gemini_response(response.text)
            else:
                logger.warning("Gemini returned empty response")
                return None
                
        except Exception as e:
            logger.error(f"Gemini generation error: {e}")
            if "429" in str(e) or "quota" in str(e).lower():
                logger.warning("Rate limit hit, increasing delay")
                self.request_delay += 2
            return None
    
    def parse_gemini_response(self, text: str) -> List[str]:
        """Parse Gemini response into clean captions."""
        lines = [line.strip() for line in text.split('\n') if line.strip()]
        captions = []
        
        for line in lines:
            # Clean the line
            clean_line = self.clean_caption_line(line)
            if clean_line and self.is_valid_caption(clean_line):
                captions.append(clean_line)
            if len(captions) >= 3:
                break
        
        # If we don't have 3 captions, create variations
        if captions:
            return self.ensure_three_captions(captions)
        else:
            logger.warning("No valid captions parsed from Gemini response")
            return None
    
    def clean_caption_line(self, line: str) -> str:
        """Clean a single caption line."""
        # Remove numbering (1., 2., 3., etc.)
        line = re.sub(r'^\d+[\.\)]\s*', '', line)
        # Remove bullets (-, •, *, etc.)
        line = re.sub(r'^[•\-*]\s*', '', line)
        # Remove quotes
        line = re.sub(r'^["\']|["\']$', '', line)
        
        line = line.strip()
        
        # Capitalize first letter
        if line and line[0].isalpha():
            line = line[0].upper() + line[1:]
        
        return line
    
    def is_valid_caption(self, caption: str) -> bool:
        """Check if caption is valid for Instagram."""
        if len(caption) < 10 or len(caption) > 150:
            return False
        if caption.lower().startswith(('sorry', 'error', 'i cannot', 'i am unable')):
            return False
        # Remove lines that are too generic
        if caption.lower() in ['instagram caption', 'caption', 'photo caption']:
            return False
        return True
    
    def ensure_three_captions(self, captions: List[str]) -> List[str]:
        """Ensure we have exactly 3 good captions."""
        if not captions:
            return self.get_fallback_captions()
        
        final_captions = []
        used_texts = set()
        
        # Add original captions first
        for caption in captions:
            if caption and caption not in used_texts:
                final_captions.append(caption)
                used_texts.add(caption)
            if len(final_captions) == 3:
                return final_captions
        
        # Create variations if needed
        if final_captions:
            base_caption = final_captions[0]
            variations = self.create_caption_variations(base_caption)
            for var in variations:
                if var not in used_texts and len(final_captions) < 3:
                    final_captions.append(var)
                    used_texts.add(var)
        
        # Fill remaining slots with fallbacks
        while len(final_captions) < 3:
            fallback = self.get_fallback_captions()[len(final_captions)]
            if fallback not in used_texts:
                final_captions.append(fallback)
        
        return final_captions[:3]
    
    def create_caption_variations(self, base_caption: str) -> List[str]:
        """Create creative variations of a caption."""
        # Remove emojis from base for variation
        base_text = re.sub(r'[^\w\s]', '', base_caption).strip()
        
        variations = [
            f"📸 {base_caption}",
            f"✨ {base_text}",
            f"🌟 {base_text} 🌟",
            f"Living the moment: {base_text}",
        ]
        
        return variations
    
    def get_fallback_captions(self) -> List[str]:
        """Get high-quality fallback captions."""
        return [
            "Creating memories that will last a lifetime 📸✨",
            "Living life one beautiful moment at a time 🌟",
            "This is what happiness looks like 💫"
        ]

# Initialize Gemini generator
gemini_generator = GeminiFreeCaptionGenerator()

# Initialize Database
db = Database()

# Pydantic models for requests
class RegisterRequest(BaseModel):
    username: str
    email: str
    password: str

class LoginRequest(BaseModel):
    username: str
    password: str

class MessageRequest(BaseModel):
    conversation_id: int
    content: str

class SaveCaptionRequest(BaseModel):
    caption: str

# Dependency to verify authentication
async def get_current_user(authorization: str = Header(None)) -> int:
    """Verify token and return user_id."""
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Not authenticated")
    
    token = authorization.replace("Bearer ", "")
    user_id = db.verify_session(token)
    
    if not user_id:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    
    return user_id

app = FastAPI(title=APP_NAME)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    """Initialize Gemini on startup."""
    logger.info("Starting Gemini Caption Generator...")
    if gemini_generator.initialize():
        logger.info("✅ Gemini Free Tier initialized successfully")
    else:
        logger.warning("❌ Gemini initialization failed - using fallback mode")

@app.get("/")
async def root():
    return {
        "message": "Smart Caption Generator with Gemini Free Tier",
        "status": "running",
        "gemini_initialized": gemini_generator.initialized,
        "service": "gemini-free"
    }

@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "gemini_available": gemini_generator.initialized,
        "has_gemini_library": HAS_GEMINI,
        "rate_limit_delay": gemini_generator.request_delay
    }

# ============ Authentication Endpoints ============

@app.post("/register")
async def register(request: RegisterRequest):
    """Register a new user."""
    user_id = db.create_user(request.username, request.email, request.password)
    
    if not user_id:
        raise HTTPException(status_code=400, detail="Username or email already exists")
    
    # Create session token
    token = db.create_session(user_id)
    
    return {
        "message": "User registered successfully",
        "user_id": user_id,
        "username": request.username,
        "token": token
    }

@app.post("/login")
async def login(request: LoginRequest):
    """Login user and return token."""
    user = db.verify_user(request.username, request.password)
    
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    # Create session token
    token = db.create_session(user['id'])
    
    return {
        "message": "Login successful",
        "user_id": user['id'],
        "username": user['username'],
        "email": user['email'],
        "token": token
    }

@app.post("/logout")
async def logout(authorization: str = Header(None)):
    """Logout user."""
    if authorization and authorization.startswith("Bearer "):
        token = authorization.replace("Bearer ", "")
        db.delete_session(token)
    
    return {"message": "Logout successful"}

@app.get("/me")
async def get_current_user_info(user_id: int = Depends(get_current_user)):
    """Get current user information."""
    user = db.get_user_info(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

# ============ Conversation Endpoints ============

@app.post("/conversations")
async def create_conversation(user_id: int = Depends(get_current_user)):
    """Create a new conversation."""
    conversation_id = db.create_conversation(user_id)
    return {
        "conversation_id": conversation_id,
        "title": "New Conversation"
    }

@app.get("/conversations")
async def get_conversations(user_id: int = Depends(get_current_user)):
    """Get all conversations for current user."""
    conversations = db.get_user_conversations(user_id)
    return {"conversations": conversations}

@app.get("/conversations/{conversation_id}/messages")
async def get_conversation_messages(
    conversation_id: int,
    user_id: int = Depends(get_current_user)
):
    """Get all messages in a conversation."""
    messages = db.get_conversation_messages(conversation_id)
    return {"messages": messages}

@app.post("/conversations/{conversation_id}/messages")
async def add_message_to_conversation(
    conversation_id: int,
    request: MessageRequest,
    user_id: int = Depends(get_current_user)
):
    """Add a message to a conversation."""
    # Add user message
    message_id = db.add_message(
        conversation_id=conversation_id,
        role="user",
        content=request.content,
        captions=None
    )
    
    return {
        "message_id": message_id,
        "conversation_id": conversation_id
    }

# ============ Saved Captions Endpoints ============

@app.post("/saved-captions")
async def save_caption(
    request: SaveCaptionRequest,
    user_id: int = Depends(get_current_user)
):
    """Save a caption for the user."""
    caption_id = db.save_caption(user_id, request.caption)
    return {
        "caption_id": caption_id,
        "message": "Caption saved successfully"
    }

@app.get("/saved-captions")
async def get_saved_captions(user_id: int = Depends(get_current_user)):
    """Get all saved captions for the user."""
    captions = db.get_saved_captions(user_id)
    return {"captions": captions}

@app.delete("/saved-captions/{caption_id}")
async def delete_saved_caption(
    caption_id: int,
    user_id: int = Depends(get_current_user)
):
    """Delete a saved caption."""
    deleted = db.delete_caption(caption_id, user_id)
    if not deleted:
        raise HTTPException(status_code=404, detail="Caption not found")
    return {"message": "Caption deleted successfully"}

@app.get("/available-models")
async def available_models():
    """List all available Gemini models."""
    if not HAS_GEMINI:
        return {"error": "Gemini library not installed"}
    
    try:
        genai.configure(api_key=os.environ.get("GEMINI_API_KEY", ""))
        models = list(genai.list_models())
        
        available_models = []
        for model in models:
            model_info = {
                "name": model.name,
                "display_name": model.display_name,
                "supported_methods": model.supported_generation_methods,
                "description": model.description
            }
            available_models.append(model_info)
        
        return {
            "available_models": available_models,
            "total_models": len(available_models)
        }
    except Exception as e:
        return {"error": str(e)}

@app.post("/generate-captions")
async def generate_captions(
    file: UploadFile = File(...),
    conversation_id: int = None,
    authorization: str = Header(None)
) -> JSONResponse:
    """Generate 3 creative Instagram captions."""
    
    # Optional authentication: if token provided, verify and use user_id
    user_id = None
    if authorization and authorization.startswith("Bearer "):
        token = authorization.replace("Bearer ", "")
        user_id = db.verify_session(token)
    
    # Basic validation
    if file is None or not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded.")
    
    MAX_FILE_SIZE = 10 * 1024 * 1024
    file.file.seek(0, 2)
    file_size = file.file.tell()
    file.file.seek(0)

    logger.info(
        "Upload received: filename=%s content_type=%s size=%s bytes",
        getattr(file, "filename", None), getattr(file, "content_type", None), file_size,
    )
    
    if file_size > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="File too large. Maximum size is 10MB.")
    
    if not (file.content_type and file.content_type.startswith("image/")):
        raise HTTPException(status_code=400, detail="Unsupported file type. Please upload an image.")

    try:
        image_bytes = await file.read()
        logger.info("Read %s bytes from upload", len(image_bytes) if image_bytes else 0)
        if not image_bytes:
            raise HTTPException(status_code=400, detail="Empty file provided.")

        # Analyze image for fallback
        img = Image.open(io.BytesIO(image_bytes))
        image_info = {
            "format": img.format,
            "size": img.size,
            "mode": img.mode
        }

        # Try Gemini first
        gemini_captions = None
        if gemini_generator.initialized:
            gemini_captions = gemini_generator.generate_captions(image_bytes)
        
        if gemini_captions:
            logger.info("Successfully generated Gemini captions")
            
            # Save to database if conversation_id and user_id provided
            if conversation_id and user_id:
                db.add_message(
                    conversation_id=conversation_id,
                    role="bot",
                    content="Generated captions for your image",
                    captions=gemini_captions
                )
            
            return JSONResponse({"captions": gemini_captions})
        
        # Fallback to smart mock captions
        logger.info("Using fallback captions")
        fallback_captions = generate_smart_fallback_captions(image_info)
        
        # Save to database if conversation_id and user_id provided
        if conversation_id and user_id:
            db.add_message(
                conversation_id=conversation_id,
                role="bot",
                content="Generated captions for your image",
                captions=fallback_captions
            )
        
        return JSONResponse({"captions": fallback_captions})

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        basic_captions = [
            "Making memories that last forever 📸",
            "Living life one adventure at a time 🌟", 
            "This moment, forever cherished 💫"
        ]
        
        return JSONResponse({"captions": basic_captions})

@app.get("/debug-models")
async def debug_models():
    """Debug endpoint to see what models are available."""
    if not HAS_GEMINI:
        return {"error": "Gemini not installed"}
    
    try:
        api_key = os.environ.get("GEMINI_API_KEY", "").strip()
        if not api_key:
            return {"error": "GEMINI_API_KEY not set"}
        
        genai.configure(api_key=api_key)
        models = list(genai.list_models())
        
        # Filter models that support generateContent
        supported_models = []
        for model in models:
            if 'generateContent' in model.supported_generation_methods:
                supported_models.append({
                    "name": model.name,
                    "display_name": model.display_name,
                    "description": model.description
                })
        
        return {
            "total_models": len(models),
            "supported_models": supported_models,
            "note": "Use the 'name' field for model initialization"
        }
        
    except Exception as e:
        return {"error": str(e)}
    

def generate_smart_fallback_captions(image_info: dict) -> List[str]:
    """Generate smart fallback captions based on image properties."""
    width, height = image_info["size"]
    
    if width > height * 1.5:
        captions = [
            "Exploring wide open spaces 🌅",
            "Adventure awaits around every corner 🗺️", 
            "Nature's beauty on full display 🎨"
        ]
    elif height > width * 1.5:
        captions = [
            "Living life in portrait mode 📱✨",
            "Standing tall, living fully 🌟",
            "Vertical dreams and memories 📸"
        ]
    else:
        captions = [
            "Perfectly framed moments 📸",
            "Life in perfect balance ⚖️", 
            "Square memories, infinite joy 💫"
        ]
    
    return captions

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")