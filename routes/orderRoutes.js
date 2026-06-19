const express = require("express");

const router = express.Router();

const authMiddleware = require("../middleware/authmiddleware");

const {
  createOrder,
  getOrders
} = require("../controller/orderController");

router.post("/orders", authMiddleware, createOrder);

router.get("/orders", authMiddleware, getOrders);

module.exports = router;