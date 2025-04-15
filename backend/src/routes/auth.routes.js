const express = require('express');
const router = express.Router();
const { registerUser, loginUser } = require('../controllers/auth.controller');
const { registerValidator, loginValidator } = require('../middlewares/authValidators');
const validateRequest = require('../middlewares/validateRequest');

// Register
router.post('/register', registerValidator, validateRequest, registerUser);

// Login
router.post('/login', loginValidator, validateRequest, loginUser);

module.exports = router;
