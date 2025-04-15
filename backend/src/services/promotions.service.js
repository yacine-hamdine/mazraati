const Product = require("../models/Product");

const findPromotionalProducts = async () => {
    const now = new Date();

    const products = await Product.find({
        'sellers.discounts.expiresAt': { $gt: now }
    }).lean();

    const promotionalItems = [];

    for (const product of products) {
        const matchingSellers = product.sellers.filter(seller => 
            seller.discounts && seller.discounts.expiresAt > now
        );

        for (const seller of matchingSellers) {
            promotionalItems.push({
                productId: product._id,
                name: product.name,
                category: product.category,
                seller: {
                    _id: seller._id, // Include seller ID here
                    price: seller.price,
                    image: seller.image,
                    stock: seller.stock,
                    discount: seller.discounts,
                    ratings: seller.ratings,
                    reviews: seller.reviews,
                    createdAt: seller.createdAt
                }
            });
        }
    }

    return promotionalItems;
};

module.exports = { findPromotionalProducts };
