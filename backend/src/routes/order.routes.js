const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/auth.middleware");
const orderController = require("../controllers/order.controller");

// Create an order
router.post("/", authMiddleware, orderController.createOrder);

// Get all my orders
router.get("/my", authMiddleware, orderController.getMyOrders);

// Get all my orders
router.get("/mine", authMiddleware, orderController.getMyOrdered);

// Get single order by ID (if buyer or seller)
router.get("/:id", authMiddleware, orderController.getOrderById);

// (optional) Update order status (e.g., for seller/admin)
router.patch("/:id/status", authMiddleware, orderController.updateOrderStatus);

// Cancel Order by Buyer
router.delete("/:id", authMiddleware, orderController.deleteOrder);

module.exports = router;
