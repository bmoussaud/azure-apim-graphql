#!/bin/bash
# Test script for Orders REST API

set -e

API_BASE_URL="${API_BASE_URL:-http://localhost:8000}"

echo "Testing Orders REST API at ${API_BASE_URL}"
echo "=========================================="

# Test health endpoint
echo ""
echo "1. Testing health check..."
curl -s "${API_BASE_URL}/health" | python -m json.tool

# Test root endpoint
echo ""
echo "2. Testing root endpoint..."
curl -s "${API_BASE_URL}/" | python -m json.tool

# Test list all orders
echo ""
echo "3. Testing list all orders..."
curl -s "${API_BASE_URL}/orders" | python -m json.tool | head -50

# Test list orders with status filter
echo ""
echo "4. Testing list orders with status filter (pending)..."
curl -s "${API_BASE_URL}/orders?status_filter=pending&limit=3" | python -m json.tool

# Test get specific order
echo ""
echo "5. Testing get specific order (ORD-2024-001)..."
curl -s "${API_BASE_URL}/orders/ORD-2024-001" | python -m json.tool

# Test create order
echo ""
echo "6. Testing create new order..."
NEW_ORDER=$(curl -s -X POST "${API_BASE_URL}/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "customer_id": "CUST-999",
    "customer_name": "Test Customer",
    "customer_email": "test@example.com",
    "items": [
      {
        "product_id": "PROD-001",
        "product_name": "Test Product",
        "quantity": 2,
        "unit_price": 50.00,
        "total_price": 100.00
      }
    ],
    "shipping_address": "123 Test St, Test City, TS 12345",
    "notes": "Test order from API test script"
  }')

echo "$NEW_ORDER" | python -m json.tool
ORDER_ID=$(echo "$NEW_ORDER" | python -c "import sys, json; print(json.load(sys.stdin)['order_id'])")
echo "Created order ID: $ORDER_ID"

# Test update order
echo ""
echo "7. Testing update order status..."
curl -s -X PUT "${API_BASE_URL}/orders/${ORDER_ID}" \
  -H "Content-Type: application/json" \
  -d '{"status": "processing", "notes": "Updated from test script"}' | python -m json.tool

# Test get updated order
echo ""
echo "8. Verifying order was updated..."
curl -s "${API_BASE_URL}/orders/${ORDER_ID}" | python -m json.tool

# Test delete order
echo ""
echo "9. Testing delete order..."
curl -s -X DELETE "${API_BASE_URL}/orders/${ORDER_ID}" -w "\nHTTP Status: %{http_code}\n"

# Verify order was deleted
echo ""
echo "10. Verifying order was deleted (should return 404)..."
curl -s "${API_BASE_URL}/orders/${ORDER_ID}" -w "\nHTTP Status: %{http_code}\n" | python -m json.tool || true

echo ""
echo "=========================================="
echo "All tests completed!"
