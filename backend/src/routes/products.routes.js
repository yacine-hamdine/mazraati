const express = require('express');
const router = express.Router();
const { getProducts, setProduct, putProduct, deleteProduct } = require('../controllers/products.controller');
const validateRequest = require('../middlewares/validateRequest');
const authMiddleware = require('../middlewares/auth.middleware');
const productAccessMiddleware = require('../middlewares/products.middleware');

// Register
router.get('/', productAccessMiddleware, getProducts);
router.post('/create/', validateRequest, authMiddleware, productAccessMiddleware, setProduct);
router.put('/update/:id', validateRequest, authMiddleware, productAccessMiddleware, putProduct);
router.delete('/delete/:id', validateRequest, authMiddleware, productAccessMiddleware, deleteProduct);

module.exports = router;
