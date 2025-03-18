const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const morgan = require("morgan");

const authRoutes = require("./routes/auth");
// const productRoutes = require("./routes/product");
// const orderRoutes = require("./routes/order");
// const userRoutes = require("./routes/user");

// const errorMiddleware = require("./middlewares/error.middleware");

const app = express();

// 🔒 Security Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan("dev")); // Logger

// 📌 Routes
app.use("/api/auth", authRoutes);
// app.use("/api/products", productRoutes);
// app.use("/api/orders", orderRoutes);
// app.use("/api/users", userRoutes);

// 🛑 Error Handling Middleware
// app.use(errorMiddleware);

module.exports = app;
