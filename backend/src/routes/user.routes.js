const express = require('express');
const router = express.Router();
const { getProfile, updateProfile, getAccount, updateAccount } = require('../controllers/user.controller');
const authMiddleware = require('../middlewares/auth.middleware'); // Your JWT/Session auth middleware

// All routes below are protected
router.use(authMiddleware);

// Profile Routes
router.get('/profile', getProfile);
router.put('/profile', updateProfile);

// Account Routes
router.get('/account', getAccount);
router.put('/account', updateAccount);

module.exports = router;
