const {
    fetchUserProfile,
    updateUserProfileData,
    fetchUserAccount,
    updateUserAccountData
  } = require('../services/user.service');
  
  // Profile
  exports.getProfile = async (req, res) => {
    try {
      const result = await fetchUserProfile(req.user.id);
      res.status(200).json(result);
    } catch (err) {
      res.status(500).json({ message: err.message || 'Server error' });
    }
  };
  
  exports.updateProfile = async (req, res) => {
    try {
      const result = await updateUserProfileData(req.user.id, req.body);
      res.status(200).json(result);
    } catch (err) {
      res.status(500).json({ message: err.message || 'Server error' });
    }
  };
  
  // Account
  exports.getAccount = async (req, res) => {
    try {
      const result = await fetchUserAccount(req.user.id);
      res.status(200).json(result);
    } catch (err) {
      res.status(500).json({ message: err.message || 'Server error' });
    }
  };
  
  exports.updateAccount = async (req, res) => {
    try {
      const result = await updateUserAccountData(req.user.id, req.body);
      res.status(200).json(result);
    } catch (err) {
      res.status(500).json({ message: err.message || 'Server error' });
    }
  };
  