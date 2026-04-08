"""
Custom exceptions for CAMP backend.
"""
from typing import Any, Dict, Optional
from fastapi import HTTPException


class CampException(Exception):
    # custom base exception for app errors
    
    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        self.message = message
        self.details = details or {}
        super().__init__(self.message)


class StorageException(CampException):
    pass  # storage-related errors


class DatabaseException(CampException):
    pass  # db errors


class AssetNotFoundException(HTTPException):
    # when we can't find the asset
    
    def __init__(self, asset_id: int):
        super().__init__(
            status_code=404,
            detail=f"Asset with ID {asset_id} not found"
        )


class InvalidFileException(HTTPException):
    """Exception raised for invalid file uploads."""
    
    def __init__(self, reason: str):
        super().__init__(
            status_code=400,
            detail=f"Invalid file: {reason}"
        )


class StorageOperationException(HTTPException):
    """Exception raised for storage operation failures."""
    
    def __init__(self, operation: str, reason: str):
        super().__init__(
            status_code=500,
            detail=f"Storage {operation} failed: {reason}"
        )


class FileSizeExceededException(HTTPException):
    """Exception raised when file size exceeds limit."""
    # might want to increase this limit at some point
    
    def __init__(self, max_size: int, actual_size: int):
        super().__init__(
            status_code=413,
            detail=f"File size {actual_size} bytes exceeds maximum allowed size {max_size} bytes"
        )


class UnsupportedFileTypeException(HTTPException):
    """Exception raised for unsupported file types."""
    
    def __init__(self, file_type: str, allowed_types: list[str]):
        super().__init__(
            status_code=415,
            detail=f"File type '{file_type}' is not supported. Allowed types: {', '.join(allowed_types)}"
        )
