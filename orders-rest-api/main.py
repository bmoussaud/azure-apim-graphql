"""
Orders REST API - CRUD operations for order management
"""
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import JSONResponse
from typing import List, Optional
from datetime import datetime
import uvicorn
from models import Order, OrderCreate, OrderUpdate
from fake_data import get_orders, get_order_by_id, create_order, update_order, delete_order

app = FastAPI(
    title="Orders REST API",
    description="REST API for managing orders (CRUD operations)",
    version="1.0.0"
)


@app.get("/")
async def root():
    """Root endpoint - API information"""
    return {
        "name": "Orders REST API",
        "version": "1.0.0",
        "description": "REST API for managing orders (CRUD operations)",
        "endpoints": {
            "GET /orders": "List all orders",
            "GET /orders/{order_id}": "Get order by ID",
            "POST /orders": "Create a new order",
            "PUT /orders/{order_id}": "Update an existing order",
            "DELETE /orders/{order_id}": "Delete an order"
        }
    }


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.utcnow().isoformat()}


@app.get("/orders", response_model=List[Order])
async def list_orders(
    status_filter: Optional[str] = None,
    limit: Optional[int] = None
):
    """
    List all orders with optional filtering
    
    Args:
        status_filter: Filter by order status (pending, processing, shipped, delivered, cancelled)
        limit: Limit the number of results
    """
    orders = get_orders()
    
    # Filter by status if provided
    if status_filter:
        orders = [o for o in orders if o.status.lower() == status_filter.lower()]
    
    # Apply limit if provided
    if limit and limit > 0:
        orders = orders[:limit]
    
    return orders


@app.get("/orders/{order_id}", response_model=Order)
async def get_order(order_id: str):
    """
    Get a specific order by ID
    
    Args:
        order_id: The unique order identifier
    """
    order = get_order_by_id(order_id)
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order with ID {order_id} not found"
        )
    return order


@app.post("/orders", response_model=Order, status_code=status.HTTP_201_CREATED)
async def create_new_order(order: OrderCreate):
    """
    Create a new order
    
    Args:
        order: Order creation data
    """
    new_order = create_order(order)
    return new_order


@app.put("/orders/{order_id}", response_model=Order)
async def update_existing_order(order_id: str, order: OrderUpdate):
    """
    Update an existing order
    
    Args:
        order_id: The unique order identifier
        order: Order update data
    """
    updated_order = update_order(order_id, order)
    if not updated_order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order with ID {order_id} not found"
        )
    return updated_order


@app.delete("/orders/{order_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_existing_order(order_id: str):
    """
    Delete an order
    
    Args:
        order_id: The unique order identifier
    """
    success = delete_order(order_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order with ID {order_id} not found"
        )
    return None


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
