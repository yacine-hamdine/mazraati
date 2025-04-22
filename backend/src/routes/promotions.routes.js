const express = require('express');
const router = express.Router();
const { getPromotions } = require('../controllers/promotions.controller');
const validateRequest = require('../middlewares/validateRequest');
const authMiddleware = require('../middlewares/auth.middleware');

// Reading Promotion Offers
router.get('/', getPromotions);

module.exports = router;
