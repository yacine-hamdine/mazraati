require("dotenv").config(); // Load environment variables

const app = require("./src/app"); // Import the Express app
const connectDB = require("./src/config/db"); // Database connection function

const PORT = process.env.PORT || 5000;

// Connect to database (if using MongoDB or another DB)
connectDB().then(() => {
  app.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}).catch(err => {
  console.error("❌ Database connection failed", err);
  process.exit(1);
});