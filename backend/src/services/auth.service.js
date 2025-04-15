const bcrypt = require('bcrypt');
const User = require('../models/User');
const { generateToken } = require("../utils/jwt");

exports.register = async ({ username, email, password }) => {
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    const error = new Error('Email already in use');
    error.status = 400;
    throw error;
  }

  const hashedPassword = await bcrypt.hash(password, 10);
  const newUser = new User({ username, email, password: hashedPassword });
  await newUser.save();

  return { message: 'User registered successfully' };
};

exports.login = async ({ email, password }) => {
  const user = await User.findOne({ email });
  if (!user) {
    const error = new Error('User not found');
    error.status = 404;
    throw error;
  }

  const isMatch = await bcrypt.compare(password, user.password);
  if (!isMatch) {
    const error = new Error('Invalid credentials');
    error.status = 400;
    throw error;
  }

  const token = generateToken({ id: user._id, email: user.email });

  return {
    message: 'Login successful',
    user: { ...user._doc, password: undefined},
    token
  };
};
