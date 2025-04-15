const mongoose = require('mongoose');

const categories = ['vegetables', 'fruits', 'grains', 'dairy', 'meat', 'poultry', 'eggs', 'honey', 'nuts', 'herbs', 'plants', 'beverages', 'baked', 'oils'];

const products = [
    // Vegetables
    'tomatoes', 'potatoes', 'onions', 'carrots', 'cucumbers', 'lettuce', 'spinach', 'broccoli', 'peppers', 'zucchini',
  
    // Fruits
    'apples', 'oranges', 'bananas', 'grapes', 'pears', 'strawberries', 'blueberries', 'lemons', 'mangoes', 'watermelons',
  
    // Grains
    'wheat', 'barley', 'corn', 'rice', 'oats',
  
    // Dairy
    'milk', 'cheese', 'butter', 'yogurt',
  
    // Meat
    'beef', 'lamb', 'goat', 'camel',
  
    // Poultry
    'chicken', 'duck', 'turkey',
  
    // Eggs
    'chicken_eggs', 'duck_eggs',
  
    // Honey
    'wild_honey', 'organic_honey', 'beeswax',
  
    // Nuts
    'almonds', 'walnuts', 'peanuts', 'pistachios',
  
    // Herbs
    'mint', 'parsley', 'basil', 'oregano', 'thyme',
  
    // Plants
    'succulents', 'basil_plants', 'tomato_seedlings', 'aloe_vera',
  
    // Beverages
    'milk_tea', 'herbal_tea', 'fresh_juice',
  
    // Baked
    'bread', 'pastries', 'cakes',
  
    // Oils
    'olive_oil', 'sunflower_oil', 'argan_oil'
];

const productSchema = new mongoose.Schema({
    category: { type: String, enum: categories, required: true },
    name: { type: String, enum: products, required: true },
    sellers: [{
        image: { type: String, default: '' },
        price: { type: Number, required: true },
        stock: { type: Number, required: true },
        discounts: {
            type: new mongoose.Schema({
                percentage: { type: Number, min: 0, max: 100 },
                expiresAt: { 
                    type: Date,
                    validate: {
                        validator: function (value) {
                            return !value || value > Date.now();
                        },
                        message: 'Discount expiry must be in the future.'
                    }
                }
            }, { _id: false }),
            default: undefined
        },
        ratings: { type: Number, default: 0 },
        reviews: { type: Number, default: 0 },
        createdAt: { type: Date, default: Date.now },
    }]
});

productSchema.methods.isDiscountActive = function (sellerIndex = 0) {
    const discount = this.sellers[sellerIndex]?.discounts;
    return discount && discount.expiresAt > Date.now();
};

const Product = mongoose.model('Product', productSchema);
module.exports = Product;