const { register, login } = require('../services/auth.service');

// Register Controller
exports.registerUser = async (req, res) => {
  try {
    const { username, email, password } = req.body;
    const result = await register({ username, email, password });
    res.status(201).json(result);
  } catch (error) {
    res.status(error.status || 500).json({ message: error.message || 'Server error' });
  }
};

// Login Controller
exports.loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;
    const result = await login({ email, password });
    res.status(200).json(result);
  } catch (error) {
    res.status(error.status || 500).json({ message: error.message || 'Server error' });
  }
};
