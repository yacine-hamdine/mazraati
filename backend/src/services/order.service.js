const Order = require("../models/Order");
const Product = require("../models/Product");

// Helper to get seller index by sellerId
const findSellerIndex = (product, sellerId) => {
  return product.sellers.findIndex(s => s._id.toString() === sellerId.toString());
};

exports.createOrder = async (buyerId, data) => {
  const { items, deliveryInfo } = data;
  if (!Array.isArray(items) || items.length === 0) {
    throw new Error("Order must contain at least one item");
  }

  let totalOrderPrice = 0;
  const orderItems = [];

  for (const item of items) {
    const { productId, seller, weight, unit, price } = item;
    const product = await Product.findById(productId);
    if (!product) throw new Error(`Product not found: ${productId}`);

    const sellerIndex = findSellerIndex(product, seller);
    if (sellerIndex === -1) throw new Error(`Seller not found for product ${productId}`);

    const sellerObj = product.sellers[sellerIndex];
    if (weight > sellerObj.stock) throw new Error(`Not enough stock for product ${productId}`);

    // Calculate discount if any
    let discount = 0;
    if (sellerObj.discounts && sellerObj.discounts.expiresAt > Date.now()) {
      discount = sellerObj.discounts.percentage;
    }

    const pricePerUnit = price || sellerObj.price;
    const totalPrice = weight * pricePerUnit * (1 - discount / 100);

    // Update stock
    sellerObj.stock -= weight;
    await product.save();

    totalOrderPrice += totalPrice;

    orderItems.push({
      product: productId,
      seller: seller,
      sellerIndex,
      weight,
      unit,
      pricePerUnit,
      discountPercentage: discount,
      totalPrice
    });
  }

  const order = await Order.create({
    buyer: buyerId,
    items: orderItems,
    totalPrice: totalOrderPrice,
    deliveryInfo
  });

  return { "success": true, "order": order };
};

exports.getOrdersByBuyer = async (buyerId) => {
  const orders = await Order.find({ buyer: buyerId })
    .populate("items.product", "name category sellers")
    .sort({ createdAt: -1 });

  // Enrich each order's items with productName, sellerName, and price
  return orders.map(order => {
    const orderObj = order.toObject();
    orderObj.items = orderObj.items.map(item => {
      let productName = '';
      let sellerName = '';
      let price = item.pricePerUnit;

      if (item.product) {
        productName = item.product.name || '';
        // Find the seller in the product's sellers array
        if (item.product.sellers && Array.isArray(item.product.sellers)) {
          const sellerObj = item.product.sellers.find(s => s._id.toString() === item.seller.toString());
          if (sellerObj) {
            sellerName = sellerObj.name || '';
            // Optionally, you could use sellerObj.price if you want the latest price
          }
        }
      }

      return {
        ...item,
        productName,
        sellerName,
        price
      };
    });
    return orderObj;
  });
};

exports.getOrdersBySeller = async (sellerId) => {
  // Find orders where any item has seller == sellerId
  const orders = await Order.find({ "items.seller": sellerId })
    .populate("items.product", "name category sellers")
    .sort({ createdAt: -1 });

  // Enrich each order's items with productName, sellerName, and price
  return orders.map(order => {
    const orderObj = order.toObject();
    orderObj.items = orderObj.items
      .filter(item => item.seller.toString() === sellerId.toString()) // Only include items for this seller
      .map(item => {
        let productName = '';
        let sellerName = '';
        let price = item.pricePerUnit;

        if (item.product) {
          productName = item.product.name || '';
          // Find the seller in the product's sellers array
          if (item.product.sellers && Array.isArray(item.product.sellers)) {
            const sellerObj = item.product.sellers.find(s => s._id.toString() === sellerId.toString());
            if (sellerObj) {
              sellerName = sellerObj.name || '';
              // Optionally, you could use sellerObj.price if you want the latest price
            }
          }
        }

        return {
          ...item,
          productName,
          sellerName,
          price
        };
      });
    return orderObj;
  });
};

exports.deleteOrder = async (userId, orderId) => {
  const order = await Order.findById(orderId);
  if (!order) {
    throw new Error("Order not found");
  }
  if (order.buyer.toString() !== userId.toString()) {
    throw new Error("Unauthorized: Only the buyer can delete this order");
  }
  await Order.deleteOne({ _id: orderId });
  return { success: true, message: "Order deleted successfully" };
};