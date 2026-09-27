"""Utility functions for text processing."""
import re

_ARABIC_REGEX = re.compile(r'[\u0600-\u06FF]')


def normalize_arabic_text(text: str) -> str:
    """
    Normalize Arabic text using pyarabic library.
    Falls back to manual normalization if library functions are unavailable.
    """
    if not text:
        return ""
    
    cleaned = text.strip()
    
    try:
        from pyarabic.araby import strip_tashkeel, normalize
        
        cleaned = strip_tashkeel(cleaned)
        cleaned = normalize(cleaned)
    except ImportError:
        cleaned = _manual_normalize_arabic(cleaned)
    except AttributeError:
        cleaned = _manual_normalize_arabic(cleaned)
    
    return cleaned


def _manual_normalize_arabic(text: str) -> str:
    """Manual Arabic normalization as fallback."""
    # إزالة التشكيل
    text = re.sub(r'[\u064B-\u065F\u0670\u0640]', '', text)
    
    # توحيد الهمزات والألف
    text = text.replace('أ', 'ا')
    text = text.replace('إ', 'ا')
    text = text.replace('آ', 'ا')
    text = text.replace('ٱ', 'ا')
    
    # توحيد التاء المربوطة
    text = text.replace('ة', 'ه')
    
    # توحيد الياء
    text = text.replace('ى', 'ي')
    
    return text


def normalize_if_arabic(text: str) -> str:
    """
    Normalize text only if it contains Arabic characters.
    English/numeric text is returned unchanged.
    """
    if not text:
        return text
    
    if _ARABIC_REGEX.search(text):
        return normalize_arabic_text(text)
    
    return text.strip()