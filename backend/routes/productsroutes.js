const express = require("express");
const router = express.Router();

const {
  getAllProducts,
  addProduct,
} = require("../controller/productsController");

router.get("/products", getAllProducts);
router.post("/products", addProduct);

module.exports = router;