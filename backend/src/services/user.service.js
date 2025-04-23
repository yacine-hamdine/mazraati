const User = require('../models/User');

// PROFILE SERVICE
exports.fetchUserProfile = async (userId) => {
  const user = await User.findById(userId).select('firstName lastName photo');
  if (!user) throw new Error('User not found');
  return user;
};

exports.updateUserProfileData = async (userId, data) => {
  const allowedFields = ['firstName', 'lastName', 'photo'];
  const updates = {};
  for (let key of allowedFields) {
    if (data[key] !== undefined) updates[key] = data[key];
  }

  const user = await User.findByIdAndUpdate(userId, updates, { new: true, runValidators: true }).select('firstName lastName photo');
  if (!user) throw new Error('User not found or update failed');
  return user;
};

// ACCOUNT SERVICE
exports.fetchUserAccount = async (userId) => {
  const user = await User.findById(userId).select('email username');
  if (!user) throw new Error('User not found');
  return user;
};

exports.updateUserAccountData = async (userId, data) => {
  const allowedFields = ['email', 'username', 'password'];
  const updates = {};
  for (let key of allowedFields) {
    if (data[key] !== undefined) updates[key] = data[key];
  }

  // If password is included, you should hash it (if you use bcrypt or similar)
  if (updates.password) {
    const bcrypt = require('bcrypt');
    updates.password = await bcrypt.hash(updates.password, 10);
  }

  const user = await User.findByIdAndUpdate(userId, updates, { new: true, runValidators: true }).select('email username');
  if (!user) throw new Error('User not found or update failed');
  return user;
};


// PREFERENCES SERVICE
exports.fetchUserPreferences = async (userId) => {
  const user = await User.findById(userId).select('location favorites');
  if (!user) throw new Error('User not found');
  return user;
};

exports.updateUserPreferencesData = async (userId, data) => {
  const allowedFields = ['lcoation', 'favorites'];
  const updates = {};
  for (let key of allowedFields) {
    if (data[key] !== undefined) updates[key] = data[key];
  }

  const user = await User.findByIdAndUpdate(userId, updates, { new: true, runValidators: true }).select('location favorites');
  if (!user) throw new Error('User not found or update failed');
  return user;
};
