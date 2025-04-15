const jwt = require("jsonwebtoken");

const SECRET_KEY = process.env.JWT_SECRET || "tiriiii berk";

// Genrate JWT
exports.generateToken = (payload) => {
    return jwt.sign(payload, SECRET_KEY, {
        expiresIn: "7d"
    });
};

exports.verifyToken = (token) => {
    return jwt.verify(token, SECRET_KEY);
}