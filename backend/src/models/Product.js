const mongoose = require('mongoose');

const categories = ['legumes', 'fruits', 'cereales', 'produits_laitiers', 'viande', 'volaille', 'oeufs', 'miel', 'noix', 'herbes', 'plantes', 'boissons', 'produits_de_boulangerie', 'huiles'];

const products = [
    // Legumes
    'tomates', 'pommes_de_terre', 'oignons', 'carottes', 'concombres', 'laitue', 'epinards', 'brocoli', 'poivrons', 'courgettes',
  
    // Fruits
    'pommes', 'oranges', 'bananes', 'raisins', 'poires', 'fraises', 'myrtilles', 'citrons', 'mangues', 'pasteques',
  
    // Cereales
    'ble', 'orge', 'mais', 'riz', 'avoine',
  
    // Produits Laitiers
    'lait', 'fromage', 'beurre', 'yaourt',
  
    // Viande
    'boeuf', 'agneau', 'chevre', 'chameau',
  
    // Volaille
    'poulet', 'canard', 'dinde',
  
    // oeufs
    'oeufs_de_poule', 'oeufs_de_canard',
  
    // Miel
    'miel_sauvage', 'miel_bio', 'cire_d_abeille',
  
    // Noix
    'amandes', 'noix', 'cacahuetes', 'pistaches',
  
    // Herbes
    'menthe', 'persil', 'basilic', 'origan', 'thym',
  
    // Plantes
    'succulentes', 'plants_de_basilic', 'plants_de_tomates', 'aloe_vera',
  
    // Boissons
    'the_au_lait', 'tisane', 'jus_frais',
  
    // Produits de Boulangerie
    'pain', 'patisseries', 'gateaux',
  
    // Huiles
    'huile_d_olive', 'huile_de_tournesol', 'huile_d_argan'
];

const productSchema = new mongoose.Schema({
    category: { type: String, enum: categories, required: true },
    name: { type: String, enum: products, required: true },
    sellers: [{
        name: { type: String, required: true, default: '' },
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