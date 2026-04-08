"""
Pydantic schemas for Asset operations.
"""
from datetime import datetime
from typing import Optional
from pydantic import BaseModel


class AssetBase(BaseModel):
    # base fields for all asset schemas
    filename: str
    original_filename: str
    file_size: int
    content_type: str


class AssetCreate(AssetBase):
    pass  # includes file_path


class AssetUpdate(BaseModel):
    """Schema for updating an Asset filename."""
    filename: str


class AssetResponse(AssetBase):
    # what we return to the client
    id: int
    file_path: str
    created_at: datetime
    updated_at: Optional[datetime] = None
    image_url: Optional[str] = None
    
    class Config:
        from_attributes = True


class AssetList(BaseModel):
    # paginated asset list
    assets: list[AssetResponse]
    total: int


class HealthCheck(BaseModel):
    """Schema for health check response."""
    status: str
    service: str
    version: str
    timestamp: datetime
