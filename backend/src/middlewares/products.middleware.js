const Product = require('../models/Product'); // Adjust the path to your Product model
const mongoose = require('mongoose');

/**
 * Middleware to check product ownership for PUT and DELETE requests.
 * Allows all users to GET any product.
 *
 * @param {express.Request} req The Express request object.
 * @param {express.Response} res The Express response object.
 * @param {express.NextFunction} next The next middleware function in the chain.
 */
const productAccessMiddleware = async (req, res, next) => {
  // Allow all users to GET any product
  if (req.method === 'GET') {
    return next(); // No ownership check needed for GET requests
  }

  // Check for PUT and DELETE methods
  if (req.method === 'PUT' || req.method === 'DELETE') {
    try {
      // 1. Get the product ID from the request parameters.  Handles both string and ObjectId
      const productId = req.params.id;

        // Check if productId is a valid mongoose ObjectId
        if (!mongoose.Types.ObjectId.isValid(productId)) {
            return res.status(400).json({ message: 'Invalid product ID format' });
        }

      // 2. Fetch the product from the database *including* the seller information.
      const product = await Product.findById(productId);

      // 3. Handle the case where the product does not exist.
      if (!product) {
        return res.status(404).json({ message: 'Product not found' });
      }

      // 4. Extract the user ID from the request.  This assumes your authentication
      //    middleware has already populated req.user with the authenticated user's data.
      //    The property name might be different (e.g., req.user.id, req.user._id, req.user.userId).
      const userId = req.user.id; //  <-- Adjust this line as necessary to get the user ID

      if (!userId) {
        return res.status(401).json({ message: 'Unauthorized: User ID not found in request' });
      }

      // 5. Check if the user is a seller of the product.  We need to check if *any* of the sellers match.
      const isOwner = product.sellers.some(seller => {
        // console.log(seller._id.toString(), userId.toString()); // Debugging line to check the IDs
        return seller._id.toString() === userId.toString(); // Convert to string for comparison
      });

      // 6. Authorize the user.
      if (isOwner) {
        // The user is a seller of this product, so allow the operation.
        return next();
      } else {
        // The user is not a seller of this product, so deny the operation.
        return res.status(403).json({ message: 'Unauthorized: You are not a seller of this product' });
      }
    } catch (error) {
      // 7. Handle any errors that occurred during the database query or other processing.
      console.error('Error in productAccessMiddleware:', error);
      return res.status(500).json({ message: 'Internal server error' });
    }
  }
  // If the method is not GET, PUT, or DELETE, you might want to deny it by default
  // or handle it in another middleware.  This depends on your application's requirements.
  return next(); //  Or, you could do:  res.status(405).json({ message: 'Method not allowed' });
};

module.exports = productAccessMiddleware;
