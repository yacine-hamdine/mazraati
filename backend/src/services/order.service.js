const Order = require("../models/Order");
const Product = require("../models/Product");

exports.createOrder = async (buyerId, data) => {
  const { product: productId, sellerIndex, quantity, deliveryInfo } = data;

  const product = await Product.findById(productId);
  if (!product) throw new Error("Product not found");

  const seller = product.sellers[sellerIndex];
  if (!seller) throw new Error("Seller not found for given index");
  if (quantity > seller.stock) throw new Error("Not enough stock");

  const pricePerUnit = seller.price;
  const discount = seller.discounts && seller.discounts.expiresAt > Date.now()
    ? seller.discounts.percentage
    : 0;

  const totalPrice = quantity * pricePerUnit * (1 - discount / 100);

  // Update stock
  seller.stock -= quantity;
  await product.save();

  const order = await Order.create({
    buyer: buyerId,
    product: productId,
    sellerIndex,
    quantity,
    pricePerUnit,
    discountPercentage: discount,
    totalPrice,
    deliveryInfo
  });

  return order;
};

exports.getOrdersByBuyer = async (buyerId) => {
  return await Order.find({ buyer: buyerId })
    .populate("product", "name category")
    .sort({ createdAt: -1 });
};

exports.getOrderById = async (orderId, userId) => {
  const order = await Order.findById(orderId).populate("product", "name category sellers");
  if (!order) throw new Error("Order not found");

  const sellerUser = order.product.sellers[order.sellerIndex]._id?.toString();
  if (order.buyer.toString() !== userId && sellerUser !== userId) {
    throw new Error("Access denied");
  }

  return order;
};

exports.updateOrderStatus = async (orderId, newStatus, userId) => {
  const order = await Order.findById(orderId).populate("product");
  if (!order) throw new Error("Order not found");

  const sellerUser = order.product.sellers[order.sellerIndex]._id?.toString();
  if (sellerUser !== userId) throw new Error("Unauthorized");

  order.status = newStatus;
  return await order.save();
};
