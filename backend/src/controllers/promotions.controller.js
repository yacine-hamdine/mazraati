const { findPromotionalProducts  } = require('../services/promotions.service');

const getPromotions = async (res) => {
    try {
        const productsWithPromotions = await findPromotionalProducts();
        res.status(200).json(productsWithPromotions);
    } catch (error) {
        console.error("Error fetching promotions:", error);
        res.status(500).json({ message: "Failed to fetch promotions" });
    }
};

module.exports = { getPromotions };
