const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const authRoutes = require("./routes/auth.routes");
const productRoutes = require("./routes/product.routes");
const orderRoutes = require("./routes/order.routes");
const userRoutes = require("./routes/user.routes");

const errorMiddleware = require("./middlewares/error.middleware");

const app = express();

// 🔒 Security Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev")); // Logger

// 📌 Routes
app.use("/api/auth", authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/orders", orderRoutes);
app.use("/api/users", userRoutes);

// 🛑 Error Handling Middleware
app.use(errorMiddleware);

module.exports = app;
